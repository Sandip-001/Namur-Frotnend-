import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:the_namur_frontend/models/othersad_model.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_image_picker.dart';

import '../provider/product_ads_provider.dart';
import '../provider/details_provider.dart';
import '../provider/crop_sell_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ProductEditScreen extends StatefulWidget {
  final OtherAdModel adData;

  final List<String> breeds;

  const ProductEditScreen({
    super.key,
    required this.adData,
    required this.breeds,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final titleController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    final ad = widget.adData;

    titleController.text = ad.title;
    qtyController.text = ad.quantity;
    priceController.text = ad.price;
    descController.text = ad.description;

    Future.microtask(() {
      final cropProvider = Provider.of<CropSellProvider>(
        context,
        listen: false,
      );
      final detailsProvider = Provider.of<DetailsProvider>(
        context,
        listen: false,
      );

      // 🔥 Load breed list from passed product
      cropProvider.setBreedsFromProduct(widget.breeds);

      final breedValue = ad.extraFields["breed"] ?? "";

      // 🔥 Prefill selected breed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (cropProvider.breedOptions.contains(breedValue)) {
          cropProvider.setBreed(breedValue);
        }
      });

      // Prefill other fields
      detailsProvider.setExistingImages(ad.images);
      print("image set at provider");
      print(ad.images);
      detailsProvider.setC(ad.unit ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropSellProvider>(context);
    final detailsProvider = Provider.of<DetailsProvider>(context);

    final ad = widget.adData;

    return Scaffold(
      appBar: CustomAppBar(
        title: "product_edit.edit_product_ad".tr(),
        showBack: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomImagePicker(),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    hint: "product_edit.product_name".tr(),
                    controller: titleController,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "product_edit.select_breed".tr(),
                    items: cropProvider.breedOptions,
                    value: cropProvider.selectedBreed,
                    onChanged: (val) => cropProvider.setBreed(val!),
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "product_edit.quantity".tr(),
                    controller: qtyController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "product_edit.unit".tr(),
                    items: [
                      "kg",
                      "gram",
                      "piece",
                      "ltr",
                      "unit",
                      "acre",
                      "sqfeet",
                      "ton",
                    ],
                    value: detailsProvider.selectedC,
                    onChanged: (val) => detailsProvider.setC(val!),
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "product_edit.price".tr(),
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "product_edit.description".tr(),
                    controller: descController,
                    maxLength: 50,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CustomButton(
              title: "product_edit.update".tr(),
              onPressed: () async {
                final adsProvider = Provider.of<ProductAdsProvider>(
                  context,
                  listen: false,
                );
                final details = Provider.of<DetailsProvider>(
                  context,
                  listen: false,
                );
                final crop = Provider.of<CropSellProvider>(
                  context,
                  listen: false,
                );
                print("images list");
                print(details.images);
                print(details.existingImages);
                bool ok = await adsProvider.updateAd(
                  adId: ad.id,
                  title: titleController.text.trim(),
                  quantity: qtyController.text.trim(),
                  price: priceController.text.trim(),
                  description: descController.text.trim(),
                  unit: details.selectedC ?? ad.unit ?? "",
                  breed: crop.selectedBreed ?? (ad.extraFields["breed"] ?? ""),
                  existingImages: details.existingImages, // URL LIST
                  newImages: details.images, // FILE LIST
                );

                if (ok) {
                  detailsProvider.resetAll();
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("product_edit.update_failed".tr())),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
