import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/details_provider.dart';

class CustomImagePicker extends StatelessWidget {
  const CustomImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsProvider>(context);

    // TOTAL IMAGES
    final totalImages =
        provider.getExistingImageUrls().length + provider.images.length;
    final canAddMore = totalImages < 6;

    // No images at all
    if (totalImages == 0) {
      return GestureDetector(
        onTap: canAddMore ? () => provider.pickImages(context) : null,
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Click to Add Images / Videos",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    // Combine both lists
    final List<dynamic> combinedImages = [
      ...provider.getExistingImageUrls(), // String URLs
      ...provider.images, // Files
    ];

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            viewportFraction: 0.85,
          ),
          items: combinedImages.asMap().entries.map((entry) {
            int index = entry.key;
            dynamic item = entry.value;
            bool isNetworkImage = item is String;

            Widget displayedImage;

            if (isNetworkImage) {
              displayedImage = Image.network(
                item,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              );
            } else {
              File file = File(item.path);

              displayedImage = file.existsSync()
                  ? Image.file(file, width: double.infinity, fit: BoxFit.cover)
                  : _placeholder();
            }

            return Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: displayedImage,
                ),

                /// Delete button
                Positioned(
                  right: 6,
                  top: 6,
                  child: GestureDetector(
                    onTap: () {
                      if (isNetworkImage) {
                        provider.removeExistingImage(index);
                      } else {
                        final actualIndex =
                            index - provider.getExistingImageUrls().length;
                        provider.removeNewImage(actualIndex);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        // ADD MORE ONLY IF LESS THAN 6
        if (canAddMore)
          TextButton.icon(
            onPressed: () => provider.pickImages(context),
            icon: const Icon(Icons.add_photo_alternate, color: Colors.green),
            label: const Text(
              "Add More",
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.black45),
      ),
    );
  }
}
