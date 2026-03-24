import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_namur_frontend/seller_profile_screen.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../Widgets/whatsapp_fab.dart';
import '../models/machinery_ad_model.dart';
import '../utils/api_url.dart';
import 'booking_process_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MachineryDescriptionScreen extends StatefulWidget {
  final MachineryAdModel ad;
  final bool isBooking;
  const MachineryDescriptionScreen({
    super.key,
    required this.ad,
    required this.isBooking,
  });

  @override
  State<MachineryDescriptionScreen> createState() =>
      _MachineryDescriptionScreenState();
}

class _MachineryDescriptionScreenState
    extends State<MachineryDescriptionScreen> {
  double userRating = 0.0;
  int activeIndex = 0;
  bool isFav = false;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  String location = '';
  String displayLocation = "";
  late MachineryAdModel ad;
  @override
  void initState() {
    super.initState();
    ad = widget.ad;
    print("booking state");
    print(widget.isBooking);
    fetchWishlistStatus(); // 👈 PREFILL HEART
    print(ad.adType);
    displayLocation = _buildLocation(ad);
  }

  /// Returns a clean, comma-separated location string
  String _buildLocation(MachineryAdModel ad) {
    print('user location');
    print(ad.userVillage);
    print(ad.userTaluk);
    print(ad.userDistrict);
    final rawParts = [ad.userTaluk, ad.userVillage, ad.userDistrict];

    final validParts = rawParts.map((e) => e?.trim() ?? "").where((e) {
      // ignore empty or placeholder values
      if (e.isEmpty) return false;
      final lower = e.toLowerCase();
      return !(["null", "dist", "taluk", "village"].contains(lower));
    }).toList();

    return validParts.join(', ');
  }

  Future<void> pickTime() async {
    final result = await showTimeRangePicker(
      context: context,
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 0),
      interval: const Duration(hours: 1),
      use24HourFormat: false,
      ticks: 24,
      strokeWidth: 8,
      ticksColor: Colors.grey,
      ticksLength: 12,
      ticksOffset: -7,

      // ✅ FIX: ClockLabel instead of String
      labels: [
        ClockLabel.fromIndex(idx: 0, length: 24, text: "12 am"),
        ClockLabel.fromIndex(idx: 3, length: 24, text: "3 am"),
        ClockLabel.fromIndex(idx: 6, length: 24, text: "6 am"),
        ClockLabel.fromIndex(idx: 9, length: 24, text: "9 am"),
        ClockLabel.fromIndex(idx: 12, length: 24, text: "12 pm"),
        ClockLabel.fromIndex(idx: 15, length: 24, text: "3 pm"),
        ClockLabel.fromIndex(idx: 18, length: 24, text: "6 pm"),
        ClockLabel.fromIndex(idx: 21, length: 24, text: "9 pm"),
      ],

      labelStyle: const TextStyle(fontSize: 12),
      rotateLabels: false,
      fromText: "From",
      toText: "To",
      backgroundColor: Colors.white,
      handlerColor: Colors.green,
      selectedColor: Colors.green,

      snap: true,
    );

    if (result != null) {
      setState(() {
        fromTime = result.startTime;
        toTime = result.endTime;
      });
    }
  }

  Future<void> fetchWishlistStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");

    if (userId == null) return;

    final url = Uri.parse(
      'https://api.inkaanalysis.com/api/wishlist/user/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List wishlist = decoded['data'] ?? [];

        final alreadyWishlisted = wishlist.any(
          (item) => item['ad_uid'] == widget.ad.adUid,
        );

        setState(() {
          isFav = alreadyWishlisted;
        });
      }
    } catch (e) {
      debugPrint("Wishlist fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff107B28), // top gradient
                Color(0xff4C7B10), // bottom gradient
              ],
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1E7A3F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "description".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareAd();
            },
            tooltip: "Share",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------------- CAROUSEL ----------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildCarousel(ad),
              ),

              /// ---------------------- TITLE + PRICE ----------------------
              const SizedBox(height: 10),
              // 🔹 Title (Auto-wrapping)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    ad.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),

              const SizedBox(height: 8),

              /// ---------------------- INFO BOXES ----------------------
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InfoBox(
                        label: "Running Hrs",
                        value: "${ad.extraFields!.drivenHours} Hrs",
                        bgColor: const Color.fromRGBO(243, 13, 13, 0.23),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InfoBox(
                        label: "rating_label".tr(),
                        value: "",
                        bgColor: const Color.fromRGBO(243, 206, 13, 0.56),
                        child: RatingBar.builder(
                          initialRating: userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 15,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          unratedColor: Colors.white,
                          onRatingUpdate: (rating) {
                            userRating = rating;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InfoBox(
                        label: "Price",
                        value:
                            "₹${ad.price}${ad.unit != null ? ' / ${ad.unit}' : ''}",
                        bgColor: const Color.fromRGBO(238, 13, 243, 0.41),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              /// ------------------ OWNER SECTION ------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 240, 10, 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerProfileScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (ad.userProfileImage != null)
                                ? NetworkImage(ad.userProfileImage!)
                                : const AssetImage(
                                    'assets/images/profile_image.png',
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.creatorName ?? "unknown".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              displayLocation,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WhatsAppButton(
                        phoneNumber: (ad.userMobile.isNotEmpty)
                            ? ad.userMobile
                            : '9945278914',
                        message: 'whatsapp_message'.tr(),
                        imagePath: 'assets/images/whatsapp.png',
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /* /// ---------------------- RATING BOX ----------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 240, 10, 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "rating_label".tr(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 26,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      unratedColor: Colors.grey.shade400,
                      onRatingUpdate: (rating) {
                        setState(() => userRating = rating);
                      },
                    ),
                  ],
                ),
              ),
*/
              const SizedBox(height: 10),

              /// ---------------------- SPECIFICATIONS ----------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 229, 229, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "specifications".tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (ad.extraFields != null &&
                        ad.extraFields!.brand.isNotEmpty &&
                        ad.extraFields!.brand.toLowerCase() != 'null')
                      specRow("brand".tr(), ad.extraFields!.brand),

                    if (ad.extraFields != null &&
                        ad.extraFields!.model.isNotEmpty &&
                        ad.extraFields!.model.toLowerCase() != 'null')
                      specRow("model".tr(), ad.extraFields!.model),

                    if (ad.extraFields != null &&
                        ad.extraFields!.registrationNo.isNotEmpty &&
                        ad.extraFields!.registrationNo.toLowerCase() != 'null')
                      specRow(
                        "registration_no".tr(),
                        ad.extraFields!.registrationNo,
                      ),

                    const SizedBox(height: 15),

                    Text(
                      "description".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16, // matching size
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _truncateWords(ad.description, 1000),
                      style: TextStyle(
                        fontSize: 15, // matching size
                        height: 1.4,
                        color: Colors.black, // matching color of title
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 10),
              if (ad.adType.toLowerCase() == "rent")
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!widget.isBooking) {
                        final bool? isBooked = await showDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => BookingProcessDialog(
                            userId: ad.creatorId.toString(),
                            adId: ad.id.toString(),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(
                        16,
                        123,
                        40,
                        1,
                      ), // ✅ green color
                      foregroundColor: Colors.white, // text color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      (!widget.isBooking) ? 'Book' : 'Booked',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              //const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateWords(String text, int wordLimit) {
    final words = text.split(RegExp(r'\s+')); // split by spaces/newlines
    if (words.length <= wordLimit) return text;
    return '${words.sublist(0, wordLimit).join(' ')}...';
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share this Ad",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text("Share via apps"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareAd() async {
    final ad = widget.ad;
    final String shareUrl = "https://api.inkaanalysis.com/ad/${ad.adUid}";
    final String message = "Check out this ${ad.title} on Namur!\n$shareUrl";

    if (ad.images.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(ad.images[0].url));
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/share_image.png';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(path)], text: message);
      } catch (e) {
        Share.share(message);
      }
    } else {
      Share.share(message);
    }
  }

  Future<void> toggleWishlist(String adId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid"); // replace with logged in user id

    if (!isFav) {
      // Add to wishlist
      final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/add');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "ad_id": adId}),
      );
      print("====Add wish list===");
      print(url);
      print(jsonEncode({"user_id": userId, "ad_id": adId}));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() => isFav = true);
        /*     if (data['success'] == true) {
          setState(() => isFav = true);
        } else {
          // show message from response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Failed to add to wishlist")),
          );
        }*/
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server error, try again later"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Remove from wishlist
      final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/remove');
      final response = await http.delete(
        url, // some APIs may use DELETE, here your API uses POST
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "ad_id": adId}),
      );
      print("====remove wish list===");
      print(url);
      print(jsonEncode({"user_id": userId, "ad_id": adId}));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isFav = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, try again later")),
        );
      }
    }
  }

  /// -------------------------------------------------------------------
  /// 🚀 CAROUSEL WITH IMAGES
  /// -------------------------------------------------------------------
  Widget buildCarousel(MachineryAdModel ad) {
    List<Widget> items = [];

    for (var img in ad.images) {
      items.add(
        GestureDetector(
          onTap: () => openImageViewer(img.url ?? ""),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                img.url ?? "",
                width: double.infinity,
                fit: BoxFit.cover,

                // ✅ LOW RES for carousel (performance)
                cacheWidth: 600, // recommended
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (ad.videoUrl != null && ad.videoUrl!.isNotEmpty) {
      final youtubeThumb = getYoutubeThumbnail(ad.videoUrl!);
      items.add(
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(ad.videoUrl!);
            try {
              // Direct launch attempt
              bool launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                // Fallback to internal/platform default if external fails
                await launchUrl(uri);
              }
            } catch (e) {
              debugPrint('Could not launch YouTube URL: $e');
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  if (youtubeThumb != null)
                    Image.network(
                      youtubeThumb,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else
                    Container(
                      color: Colors.black12,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 60,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Text("no_image".tr()),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: items,
          options: CarouselOptions(
            height: 230,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() => activeIndex = index);
            },
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "AD-${ad.id}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeIndex == index
                          ? Colors.green
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: Material(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => toggleWishlist(ad.id.toString()),
                    child: Center(
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        size: 30,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? getYoutubeThumbnail(String url) {
    try {
      if (url.contains("youtu.be/")) {
        final id = url.split("youtu.be/")[1];
        return "https://img.youtube.com/vi/$id/0.jpg";
      }

      if (url.contains("v=")) {
        final id = url.split("v=")[1].split("&").first;
        return "https://img.youtube.com/vi/$id/0.jpg";
      }
    } catch (_) {}
    return null;
  }

  Widget specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void openImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              /// ZOOMABLE IMAGE
              Center(
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                ),
              ),

              /// CLOSE BUTTON
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Widget? child; // optional widget to replace value

  const InfoBox({
    super.key,
    required this.label,
    required this.value,
    required this.bgColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          child ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
        ],
      ),
    );
  }
}
