import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:the_namur_frontend/models/booking_model.dart';

class BookingAdCard extends StatelessWidget {
  final BookingModel ad;
  final VoidCallback? onTap;

  const BookingAdCard({super.key, required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ad.ad.images.isNotEmpty
        ? ad.ad.images.first.url ?? ""
        : "";
    final district = ad.land.district.isNotEmpty ? ad.land.district : null;

    final taluk = ad.land.taluk;
    final village = ad.land.village;

    final locationParts = [
      if (district != null && district.isNotEmpty) district,
      if (taluk.isNotEmpty) taluk,
      if (village.isNotEmpty) village,
    ];

    final location = locationParts.join(', ');

    final priceText = "Booking Slot : ${ad.startTime}' - ${ad.endTime}";

    final dateText = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.parse(ad.bookingDate));

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0, // 🔹 clean border look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300, width: 2.5),
          ),
          child: SizedBox(
            height: 127,
            child: Row(
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
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE
                        Text(
                          ad.ad.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// PRICE
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                priceText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// LOCATION
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// DATE
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateText,
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
    );
  }

  /// 🔹 Fallback image
  Widget _noImageWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
