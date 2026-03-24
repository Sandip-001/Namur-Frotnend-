import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/custom_appbar.dart';
import '../utils/api_url.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  List<LandMapModel> landMaps = [];
  LatLng? userLocation;
  bool isLoading = true;

  double _currentZoom = 13; // 👈 track zoom
  static const double _surveyBadgeZoomLevel = 13.0; // show badges from zoom 13
  static const double _productMarkerZoomLevel = 14.0; // show logos from zoom 14

  @override
  void initState() {
    super.initState();
    fetchLandMaps();
  }

  // ================= API =================
  Future<void> fetchLandMaps() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/land-maps/match-land"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = (data['data'] as List)
            .map((e) => LandMapModel.fromJson(e))
            .toList();

        setState(() {
          landMaps = list;
          isLoading = false;
        });

        if (landMaps.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitAllLands();
          });
        } else {
          _getUserLocation();
        }
      } else {
        _getUserLocation();
      }
    } catch (e) {
      debugPrint("API Error in map: $e");
      _getUserLocation();
    }
  }

  // ================= LOCATION =================
  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

      _mapController.move(userLocation!, 14);
    } catch (e) {
      debugPrint("Location error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= MAP HELPERS =================
  void _fitAllLands() {
    final allPoints = <LatLng>[];

    for (final land in landMaps) {
      for (final c in land.coordinates) {
        allPoints.add(LatLng(c[0], c[1]));
      }
    }

    final bounds = LatLngBounds.fromPoints(allPoints);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60.0),
        maxZoom: 18,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final camera = _mapController.camera;
      setState(() {
        _currentZoom = camera.zoom;
      });
    });
  }

  void _zoomToLand(LandMapModel land) {
    final points = land.coordinates.map((c) => LatLng(c[0], c[1])).toList();

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  Color getRandomColor() {
    final r = Random();
    return Color.fromARGB(255, r.nextInt(180), r.nextInt(180), r.nextInt(180));
  }

  LatLng getPolygonCenter(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  // ================= BOTTOM SHEET =================
  void _showLandDetailsBottomSheet(BuildContext context, LandMapModel land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LandDetailsBottomSheet(
        land: land, // pass LandMapModel here
      ),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        userLocation = latLng;
      });

      _mapController.move(latLng, 16); // zoom nicely to user
    } catch (e) {
      debugPrint("❌ Current location error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Land Map Overview"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        userLocation ?? const LatLng(12.9716, 77.5946),
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onPositionChanged: (position, _) {
                      setState(() {
                        _currentZoom = position.zoom;
                      });
                    },
                  ),
                  children: [
                    /// 🌍 MAP TILES (PRODUCTION SAFE)
                    TileLayer(
                      urlTemplate:
                          "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=S0f7IIApbUygwf1Rq4EG",
                      userAgentPackageName: 'com.yourcompany.yourapp',
                    ),

                    /// 🟩 LAND POLYGONS
                    if (landMaps.isNotEmpty)
                      PolygonLayer(
                        polygons: landMaps.map((land) {
                          final points = land.coordinates
                              .map((c) => LatLng(c[0], c[1]))
                              .toList();

                          return Polygon(
                            points: points,
                            borderColor: Colors.black,
                            borderStrokeWidth: 1,
                            color: land.matchedLands.isEmpty
                                ? getRandomColor().withOpacity(0.4)
                                : Colors.transparent,
                          );
                        }).toList(),
                      ),

                    /// 🧺 PRODUCT MARKERS
                    if (landMaps.isNotEmpty)
                      MarkerLayer(
                        markers: landMaps
                            .expand((land) => _buildProductMarkers(land))
                            .toList(),
                      ),

                    /// 🏷️ SURVEY BADGES (ZOOM BASED)
                    if (_currentZoom >= _surveyBadgeZoomLevel)
                      MarkerLayer(
                        markers: landMaps.map((land) {
                          final center = getPolygonCenter(
                            land.coordinates
                                .map((c) => LatLng(c[0], c[1]))
                                .toList(),
                          );

                          return Marker(
                            point: center,
                            width: 56,
                            height: 32,
                            child: GestureDetector(
                              onTap: () {
                                _zoomToLand(land);
                                _showLandDetailsBottomSheet(context, land);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: land.matchedLands.isEmpty
                                        ? Colors.grey
                                        : Colors.green,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${land.surveyNo}/${land.hissaNo}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),

                Positioned(
                  bottom: 20,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "currentLocation",
                    backgroundColor: Colors.white,
                    onPressed: _moveToCurrentLocation,
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
              ],
            ),
    );
  }

  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      final intersect =
          ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude <
              (xj - xi) * (point.longitude - yi) / (yj - yi + 0.0) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  List<Marker> _buildProductMarkers(LandMapModel land) {
    if (_currentZoom < _productMarkerZoomLevel) return [];
    if (land.matchedLands.isEmpty) return [];

    // Combine all product types (food + any others stored in foodProducts)
    final allProducts = land.matchedLands
        .expand((m) => m.foodProducts)
        .toList();
    if (allProducts.isEmpty) return [];

    final polygon = land.coordinates.map((c) => LatLng(c[0], c[1])).toList();

    double minLat = polygon.first.latitude;
    double maxLat = polygon.first.latitude;
    double minLng = polygon.first.longitude;
    double maxLng = polygon.first.longitude;

    for (final p in polygon) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final double spacing = (_currentZoom >= 17) ? 0.00015 : 0.0003;

    final markers = <Marker>[];
    int productIndex = 0;

    for (double lat = minLat; lat <= maxLat; lat += spacing) {
      for (double lng = minLng; lng <= maxLng; lng += spacing) {
        final point = LatLng(lat, lng);

        if (!isPointInsidePolygon(point, polygon)) continue;

        final product = allProducts[productIndex % allProducts.length];
        productIndex++;

        markers.add(
          Marker(
            width: 28,
            height: 28,
            point: point,
            child: product.productImage.isNotEmpty
                ? Image.network(
                    product.productImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.eco,
                      size: 20,
                      color: Colors.green,
                    ),
                  )
                : const Icon(Icons.eco, size: 20, color: Colors.green),
          ),
        );
      }
    }

    return markers;
  }
}

// ================= MODELS =================

class LandMapModel {
  final int mapId;
  final String district;
  final String taluk;
  final String village;
  final String? hobli;

  final String surveyNo;
  final String hissaNo;
  final String areaAcres;

  final String? soilPh;
  final String? irrigationType;

  final String? fidCode;
  final String? farmerId;
  final String? crop;
  final DateTime? startDate;

  final List<List<double>> coordinates;
  final List<MatchedLand> matchedLands;

  LandMapModel({
    required this.mapId,
    required this.district,
    required this.taluk,
    required this.village,
    this.hobli,
    required this.surveyNo,
    required this.hissaNo,
    required this.areaAcres,
    this.soilPh,
    this.irrigationType,
    this.fidCode,
    this.farmerId,
    this.crop,
    this.startDate,
    required this.coordinates,
    required this.matchedLands,
  });

  factory LandMapModel.fromJson(Map<String, dynamic> json) {
    return LandMapModel(
      mapId: json["map_id"] ?? 0,
      district: json["district"]?.toString() ?? "",
      taluk: json["taluk"]?.toString() ?? "",
      village: json["village"]?.toString() ?? "",
      hobli: json["hobli"]?.toString(),

      surveyNo: json["survey_no"]?.toString() ?? "",
      hissaNo: json["hissa_no"]?.toString() ?? "",
      areaAcres: json["area_acres"]?.toString() ?? "",

      soilPh: json["soil_ph"]?.toString(),
      irrigationType: json["irrigation_type"]?.toString(),

      fidCode: json["fid_code"]?.toString(),
      farmerId: json["farmer_id"]?.toString(),
      crop: json["crop"]?.toString(),

      startDate: json["start_date"] != null
          ? DateTime.tryParse(json["start_date"])
          : null,

      coordinates: (json["coordinates"] as List? ?? [])
          .map<List<double>>(
            (c) => [(c[0] as num).toDouble(), (c[1] as num).toDouble()],
          )
          .toList(),

      matchedLands: (json["matched_lands"] as List? ?? [])
          .map((e) => MatchedLand.fromJson(e))
          .toList(),
    );
  }
}

class MatchedLand {
  final int userId; // new
  final String username; // new
  final String email; // new
  final String mobile; // new
  final String profileImageUrl; // new
  final int landId; // new
  final String landName;
  final String farmSize;
  final List<LandProductModel> foodProducts;

  MatchedLand({
    required this.userId,
    required this.username,
    required this.email,
    required this.mobile,
    required this.profileImageUrl,
    required this.landId,
    required this.landName,
    required this.farmSize,
    required this.foodProducts,
  });

  factory MatchedLand.fromJson(Map<String, dynamic> json) {
    return MatchedLand(
      userId: json["user_id"] ?? 0,
      username: json["username"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      mobile: json["mobile"]?.toString() ?? "",
      profileImageUrl: json["profile_image_url"]?.toString() ?? "",
      landId: json["land_id"] ?? 0,
      landName: json["land_name"]?.toString() ?? "",
      farmSize: json["farm_size"]?.toString() ?? "",
      foodProducts: (json["food_products"] as List? ?? [])
          .map((e) => LandProductModel.fromJson(e))
          .toList(),
    );
  }
}

class LandDetailsBottomSheet extends StatelessWidget {
  final LandMapModel land;

  const LandDetailsBottomSheet({super.key, required this.land});

  String valueOrNA(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'N/A';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final matchedLand = land.matchedLands.isNotEmpty
        ? land.matchedLands.first
        : null;

    // Aggregate products from ALL matched lands, not just the first
    final products = land.matchedLands
        .expand((m) => m.foodProducts)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT SIDE (Avatar + Name + Phone)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          matchedLand?.profileImageUrl.isNotEmpty == true
                          ? NetworkImage(matchedLand!.profileImageUrl)
                          : const AssetImage('assets/profile_image.png')
                                as ImageProvider,
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrNA(matchedLand?.username),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.call, size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              valueOrNA(matchedLand?.mobile),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// RIGHT SIDE (Warning + Close)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (matchedLand != null) {
                        _showComplaintDialog(context, land, matchedLand);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28, // 🔥 more visible
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          /// TITLE / LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                valueOrNA(matchedLand?.landName),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// DETAILS GRID
          Row(
            children: [
              _InfoItem(
                icon: Icons.apartment,
                title: 'District',
                value: valueOrNA(land.district),
                color: Colors.red,
              ),
              _InfoItem(
                icon: Icons.home_work,
                title: 'Village',
                value: valueOrNA(land.village),
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _InfoItem(
                icon: Icons.description,
                title: 'Survey',
                value: surveyWithHissa(land.surveyNo, land.hissaNo),
                color: Colors.brown,
              ),
              _InfoItem(
                icon: Icons.straighten,
                title: 'Size',
                value: valueOrNA(
                  matchedLand?.farmSize.isNotEmpty == true
                      ? matchedLand!.farmSize
                      : land.areaAcres,
                ),
                color: Colors.blueGrey,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _InfoItem(
                icon: Icons.landscape_sharp,
                title: 'Soil pH',
                value: valueOrNA(land.soilPh),
                color: Colors.green,
              ),
              _InfoItem(
                icon: Icons.water_drop,
                title: 'Irrigation',
                value: valueOrNA(land.irrigationType),
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _InfoItem(
                icon: Icons.grass,
                title: 'Crop',
                value: valueOrNA(land.crop),
                color: Colors.green,
              ),
              _InfoItem(
                icon: Icons.date_range,
                title: 'Starting Date',
                value: formatDateDDMMYYYY(land.startDate),
                color: Colors.blue,
              ),
            ],
          ),
          const Divider(),

          /// PRODUCTS SECTION
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Products '
                '(${products.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// PRODUCTS LIST OR EMPTY
          products.isEmpty
              ? _emptyProductCard()
              : Column(
                  children: products.map((product) {
                    return productCard(product);
                  }).toList(),
                ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String formatDateDDMMYYYY(dynamic date) {
    if (date == null) return 'N/A';

    try {
      final DateTime parsed = date is DateTime
          ? date
          : DateTime.parse(date.toString());

      return '${parsed.day.toString().padLeft(2, '0')}/'
          '${parsed.month.toString().padLeft(2, '0')}/'
          '${parsed.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  void _showComplaintDialog(
    BuildContext context,
    LandMapModel land,
    MatchedLand matchedLand,
  ) {
    final TextEditingController complaintController = TextEditingController();

    // Get the root context from the overlay (ensures SnackBar is visible above bottom sheet)
    final rootContext = Navigator.of(context).overlay!.context;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final words = _wordCount(complaintController.text);
            final isLimitExceeded = words > 1000;

            return AlertDialog(
              title: const Text("File a Complaint"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: complaintController,
                    maxLines: 5,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "Enter complaint details...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// WORD COUNT
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Words: $words / 1000",
                      style: TextStyle(
                        fontSize: 12,
                        color: isLimitExceeded ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),

                  if (isLimitExceeded)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "Maximum 1000 words allowed",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLimitExceeded
                      ? null
                      : () async {
                          final description = complaintController.text.trim();

                          if (description.isEmpty) {
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter complaint details"),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          Navigator.pop(context);

                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString("uid") ?? '';

                          await _sendComplaint(
                            landId: matchedLand.landId,
                            againstUserId: matchedLand.userId,
                            complainByUserId: userId,
                            description: description,
                            context: rootContext,
                          );
                        },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _wordCount(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  // ================= API CALL =================
  Future<void> _sendComplaint({
    required int landId,
    required String complainByUserId,
    required int againstUserId,
    required String description,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.inkaanalysis.com/api/landDispute/create",
      );
      print(url);
      final body = {
        "complain_by_user_id": complainByUserId,
        "against_user_id": againstUserId,
        "land_id": landId,
        "description": description,
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      // Try to parse the API message
      String message;
      try {
        final data = json.decode(res.body);
        message = data['message']?.toString() ?? "No message from server";
      } catch (_) {
        message = "Unexpected response: ${res.body}";
      }

      // Show message from API in SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting complaint: $e")));
    }
  }

  /// EMPTY CARD
  Widget _emptyProductCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image_not_supported),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('N/A', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('N/A', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('N/A', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// PRODUCT CARD
  Widget productCard(LandProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.productImage,
              height: 46,
              width: 46,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 46,
                  width: 46,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          /// NAME + CATEGORY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.categoryName} - ${product.subcategoryName}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          /// ACRES BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${product.acres.toStringAsFixed(2)} Acres",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String surveyWithHissa(String? surveyNo, String? hissaNo) {
    final survey = surveyNo?.trim();
    final hissa = hissaNo?.trim();

    if ((survey == null || survey.isEmpty) &&
        (hissa == null || hissa.isEmpty)) {
      return 'N/A';
    }

    // show even if hissa is "0"
    if (survey != null &&
        survey.isNotEmpty &&
        hissa != null &&
        hissa.isNotEmpty) {
      return '$survey/$hissa';
    }

    // fallback cases
    return survey ?? hissa ?? 'N/A';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title:',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class LandProductModel {
  final String productName;
  final String productImage;
  final double acres;
  final String categoryName;
  final String subcategoryName;

  LandProductModel({
    required this.productName,
    required this.productImage,
    required this.acres,
    required this.categoryName,
    required this.subcategoryName,
  });

  factory LandProductModel.fromJson(Map<String, dynamic> json) {
    return LandProductModel(
      productName: json['product_name']?.toString() ?? 'N/A',
      productImage: json['product_image']?.toString() ?? '',
      acres: double.tryParse(json['acres'].toString()) ?? 0.0,
      categoryName: json['category_name']?.toString() ?? 'N/A',
      subcategoryName: json['subcategory_name']?.toString() ?? 'N/A',
    );
  }
}
