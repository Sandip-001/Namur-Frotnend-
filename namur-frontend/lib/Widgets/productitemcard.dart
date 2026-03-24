import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/models/othersad_model.dart';
import '../models/machinery_ad_model.dart';
import '../provider/machinery_ads_provider.dart';
import '../provider/product_ads_provider.dart';
import '../screens/machinery_edit_screen.dart';
import '../screens/product_edit_screen.dart';

class ProductCardList extends StatefulWidget {
  final MachineryAdModel? machineryAd;
  final OtherAdModel? productAd;
  final List<String>? breeds;

  const ProductCardList({
    this.machineryAd,
    this.productAd,
    super.key,
    this.breeds,
  });

  @override
  State<ProductCardList> createState() => _ProductCardListState();
}

class _ProductCardListState extends State<ProductCardList> {
  @override
  Widget build(BuildContext context) {
    final adsProvider = Provider.of<ProductAdsProvider>(context);
    // ---------------- GET THE DATA AUTOMATICALLY ----------------
    final imageUrl = widget.machineryAd != null
        ? (widget.machineryAd!.images.isNotEmpty
              ? widget.machineryAd!.images[0].url
              : "")
        : (widget.productAd!.images.isNotEmpty
              ? widget.productAd!.images[0].url
              : "");

    final title = widget.machineryAd?.title ?? widget.productAd?.title ?? "";
    final id =
        widget.machineryAd?.id.toString() ??
        widget.productAd?.id.toString() ??
        "";
    final adUid =
        widget.machineryAd?.id.toString() ?? widget.productAd?.adUid ?? "";

    final price = widget.machineryAd != null
        ? "${widget.machineryAd!.price} "
        : "${widget.productAd!.price} / ${widget.productAd!.unit ?? ""} ";

    final location = () {
      if (widget.machineryAd != null) {
        final ad = widget.machineryAd!;
        final districtDisplay = _buildDistrictDisplay(ad.districts);
        final parts = <String>[
          if (districtDisplay.isNotEmpty) districtDisplay,
          if (ad.userTaluk != null && ad.userTaluk!.isNotEmpty) ad.userTaluk!,
          if (ad.userVillage != null && ad.userVillage!.isNotEmpty)
            ad.userVillage!,
        ];
        return parts.join(', ');
      } else {
        final ad = widget.productAd!;
        final districtDisplay = _buildDistrictDisplay(ad.districts);
        final parts = <String>[
          if (districtDisplay.isNotEmpty) districtDisplay,
          if (ad.userTaluk != null && ad.userTaluk!.isNotEmpty) ad.userTaluk!,
          if (ad.userVillage != null && ad.userVillage!.isNotEmpty)
            ad.userVillage!,
        ];
        return parts.join(', ');
      }
    }();

    final String? typeOrBreed = () {
      // 🔹 Machinery Ad → show adType
      if (widget.machineryAd != null) {
        return widget.machineryAd!.adType;
      }

      // 🔹 Other/Product Ad → show breed
      if (widget.productAd != null) {
        // priority: passed breeds list
        if (widget.breeds != null && widget.breeds!.isNotEmpty) {
          return widget.productAd?.extraFields['breed']?.toString();
        }

        // fallback: from extra_fields
        final breed = widget.productAd!.extraFields['breed'];
        if (breed != null && breed.toString().isNotEmpty) {
          return "Breed: ${breed.toString()}";
        }
      }

      return "";
    }();

    final timeAgo = _formatTimeAgo(
      (widget.machineryAd?.createdAt ?? widget.productAd?.createdAt).toString(),
    );

    // ------------------------------------------------------------
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.machineryAd != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MachineryEditScreen(machinery: widget.machineryAd!),
                ),
              );
            } else {
              print('breeds');
              print(widget.productAd!.extraFields['breeds']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductEditScreen(
                    adData: widget.productAd!,
                    breeds: widget.breeds ?? [],
                  ),
                ),
              );
            }
          },

          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0, // 🔹 border looks better without elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300, width: 2.5),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 140),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  /// LEFT IMAGE (FULL HEIGHT, NO LEFT SPACE)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: SizedBox(
                      width: 110,
                      height: double.infinity,
                      child: imageUrl.isEmpty
                          ? _noImageWidget()
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover, // 🔥 fills full height & width
                            ),
                    ),
                  ),

                  /// RIGHT CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// PRODUCT NAME
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// GRADE + PRICE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  typeOrBreed!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Rs $price",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              /// LOCATION - LEFT
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 2, // ✅ two lines
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3, // 👌 better line spacing
                                  ),
                                ),
                              ),

                              /// TIME - RIGHT
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeAgo,

                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Ad"),
        content: const Text("Are you sure you want to delete this ad?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final int adId = widget.machineryAd?.id ?? widget.productAd!.id;

              bool success;
              if (widget.machineryAd != null) {
                final provider = Provider.of<MachineryAdsProvider>(
                  context,
                  listen: false,
                );
                success = await provider.deleteAd(adId);
              } else {
                final provider = Provider.of<ProductAdsProvider>(
                  context,
                  listen: false,
                );
                success = await provider.deleteAd(adId);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? "Ad deleted successfully" : "Failed to delete ad",
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _noImageWidget() => Container(
    color: Colors.grey.shade300,
    child: const Center(
      child: Text(
        "No Image",
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ),
  );

  /// Returns a compact district display string.
  /// - Single district: shows it directly (e.g., "Belgaum")
  /// - Multiple districts (admin ads): shows "Dist1 +N dist" (e.g., "Belgaum +28 dist")
  String _buildDistrictDisplay(List<String> districts) {
    if (districts.isEmpty) return "";
    if (districts.length == 1) return districts.first;
    final extra = districts.length - 1;
    return "${districts.first} +$extra dist";
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";

    final date = DateTime.parse(dateString);
    final diff = DateTime.now().difference(date);

    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? "1 day ago" : "${diff.inDays} days ago";
    }

    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? "1 hour ago" : "${diff.inHours} hours ago";
    }

    if (diff.inMinutes >= 1) {
      return diff.inMinutes == 1
          ? "1 minute ago"
          : "${diff.inMinutes} minutes ago";
    }

    return "Just now";
  }
}
