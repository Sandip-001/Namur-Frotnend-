import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/othersad_model.dart';

class OtherProductCard extends StatefulWidget {

  final OtherAdModel ad;
  final VoidCallback onTap;

  const OtherProductCard({
    super.key,
    required this.ad,
    required this.onTap,
  });

  @override
  State<OtherProductCard> createState() => _OtherProductCardState();
}

class _OtherProductCardState extends State<OtherProductCard> {

  String? _userDistrict;

  @override
  void initState() {
    super.initState();
    _loadUserDistrict();
  }

  Future<void> _loadUserDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    final d = prefs.getString("district");
    if (d != null && d.isNotEmpty && mounted) {
      setState(() => _userDistrict = d);
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return "Unknown";

    final date = DateTime.tryParse(dateString);
    if (date == null) return "Unknown";

    final diff = DateTime.now().difference(date);

    if (diff.inDays > 0) return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    if (diff.inHours > 0) return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} min ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.ad.images.isNotEmpty ? widget.ad.images.first.url ?? "" : "";
    final timeAgo = _formatTimeAgo(widget.ad.createdAt);

    // Show user's current district if available, otherwise fall back to the ad's own district
    // If the ad covers many districts (admin ad) and no user district override, show condensed format
    final districtLabel = (_userDistrict != null && _userDistrict!.isNotEmpty)
        ? _userDistrict!
        : _buildDistrictDisplay(widget.ad.districts);
    final taluk = widget.ad.userTaluk;
    final village = widget.ad.userVillage;

    final location = [
      if (districtLabel.isNotEmpty) districtLabel,
      if (taluk != null && taluk.isNotEmpty) taluk,
      if (village != null && village.isNotEmpty) village,
    ].join(', ');

    final priceText =
        "₹${widget.ad.price}${widget.ad.unit != null ? ' / ${widget.ad.unit}' : ''}";

    final dateText =
    DateTime.tryParse(widget.ad.expiryDate) != null
        ? _formatDate(widget.ad.expiryDate)
        : "";
    final String? breed = widget.ad.extraFields['breed']?.toString();
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 2.5,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 125),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                /// LEFT IMAGE
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
                        : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    ),
                  ),
                ),

                /// RIGHT CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE
                        Text(
                          widget.ad.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// PRODUCT + PRICE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                breed!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              priceText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,

                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),

                            /// LOCATION (2 lines)
                            Expanded(
                              child: Text(
                                location.isNotEmpty ? location : "Unknown",
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),

                            /// TIME AGO
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
  );
}

  String _buildDistrictDisplay(List<String> districts) {
    if (districts.isEmpty) return "";
    if (districts.length == 1) return districts.first;
    final extra = districts.length - 1;
    return "${districts.first} +$extra dist";
  }

  Widget _noImageWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  String _formatDate(String date) {
    return DateTime.parse(date)
        .toLocal()
        .toString()
        .split(' ')
        .first
        .split('-')
        .reversed
        .join('-');
  }
}
