import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_button.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_image_picker.dart';
import '../Widgets/custom_textfield.dart';
import '../models/product_model_api.dart';
import '../provider/crop_sell_provider.dart';
import '../provider/details_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel selectedProduct;
  final String screenTitle;

  const ProductDetailsScreen({
    super.key,
    required this.selectedProduct,
    required this.screenTitle,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final titleController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  bool isLoading = false;
  int _wordCount = 0;
  String _lastValidText = '';

  void _clearFormAfterSave(
    DetailsProvider detailsProvider,
    CropSellProvider cropProvider,
  ) {
    titleController.clear();
    qtyController.clear();
    priceController.clear();
    descController.clear();
    _wordCount = 0;
    _lastValidText = '';

    detailsProvider.resetAll();
    cropProvider.resetForm();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CropSellProvider>(
        context,
        listen: false,
      ).setBreedsFromProduct(widget.selectedProduct.breeds);

      final detailsProvider = Provider.of<DetailsProvider>(
        context,
        listen: false,
      );
      detailsProvider.clearAllImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropSellProvider>(context);
    final detailsProvider = Provider.of<DetailsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: widget.screenTitle, showBack: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CustomImagePicker(),
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
                    hint: "product_details.product_title".tr(),
                    controller: titleController,
                    widthFactor: 0.9,
                    maxLength: 75,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "product_details.select_breed".tr(),
                    items: cropProvider.breedOptions,
                    value: cropProvider.selectedBreed,
                    onChanged: (val) => cropProvider.setBreed(val!),
                    widthFactor: 0.8,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "product_details.quantity".tr(),
                    controller: qtyController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "product_details.unit".tr(),
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
                    hint: "product_details.price".tr(),
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "product_details.description".tr(),
                    controller: descController,
                    maxLines: 4,
                    inputType: TextInputType.multiline,
                    onChanged: (value) {
                      final words = value.trim().isEmpty
                          ? <String>[]
                          : value.trim().split(RegExp(r'\s+'));

                      if (words.length <= 50) {
                        _lastValidText = value;
                        setState(() {
                          _wordCount = words.length;
                        });
                      } else {
                        descController.text = _lastValidText;
                        descController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _lastValidText.length),
                        );
                      }
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: (_wordCount >= 50),

                          child: const Text(
                            "Max 50 words allowed",
                            style: TextStyle(fontSize: 15, color: Colors.red),
                          ),
                        ),
                        Text(
                          "$_wordCount / 50 words",
                          style: TextStyle(
                            fontSize: 12,
                            color: _wordCount >= 50 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 16),
            CustomButton(
              title: "Post".tr(),
              width: 160,
              isLoading: isLoading,
              onPressed: () async {
                setState(() => isLoading = true);

                if (detailsProvider.images.isEmpty) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please upload at least one image"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final response = await cropProvider.createAd(
                  title: titleController.text.trim(),
                  categoryId: widget.selectedProduct.categoryId.toString(),
                  subCategoryId: widget.selectedProduct.subCategoryId
                      .toString(),
                  productId: widget.selectedProduct.id.toString(),
                  productName: widget.selectedProduct.name,
                  quantity: qtyController.text.isEmpty
                      ? "1"
                      : qtyController.text,
                  unit: detailsProvider.selectedC ?? "piece",
                  price: priceController.text.isEmpty
                      ? "0"
                      : priceController.text,
                  description: descController.text.trim(),
                  breed: cropProvider.selectedBreed ?? "",
                  images: detailsProvider.images,
                );

                setState(() => isLoading = false);

                final status = response["status"] ?? 0;
                final body = response["body"] ?? "";

                if (status == 201) {
                  _clearFormAfterSave(detailsProvider, cropProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ad posted successfully"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (status == 0 && body.contains("offline")) {
                  _clearFormAfterSave(detailsProvider, cropProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(body),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (status == 400 || status == 422) {
                  // Validation error from API
                  String message = "";
                  try {
                    message =
                        json.decode(body)["message"] ?? "Validation error";
                  } catch (_) {
                    message = body;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  // Other failures
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Upload failed. Please try again."),
                      backgroundColor: Colors.orange,
                    ),
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
