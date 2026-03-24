import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_image_picker.dart';
import '../models/product_model_api.dart';
import '../provider/crop_sell_provider.dart';
import '../provider/details_provider.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'home_screen.dart';

class CropDetailsScreen extends StatefulWidget {
  final ProductModel selectedProduct;

  const CropDetailsScreen({super.key, required this.selectedProduct});

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  @override
  void initState() {
    super.initState(); // MUST be first

    // use listen:false
    Future.microtask(() {
      Provider.of<CropSellProvider>(
        context,
        listen: false,
      ).setBreedsFromProduct(widget.selectedProduct.breeds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsProvider>(context);
    final cropprovider = Provider.of<CropSellProvider>(context);
    // final priceController = TextEditingController(text: provider.price ?? "");
    final titleController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: "Crop Details", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image upload placeholder
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: const CustomImagePicker(),
            ),
            const SizedBox(height: 12),

            // Header
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 15,
                    ),
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 8,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(45, 252, 12, 0.3),
                    ),
                    child: const Text(
                      "ಎಮ್ಮೆ ಕಿತ್ತಳೆ 4 Years @ 75 ನಾವಿರ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // A. Fruit/Veg/Cereals
                  CustomTextField(
                    hint: "A.Product Name",
                    controller: titleController,
                    inputType: TextInputType.number,
                  ),

                  const SizedBox(height: 10),

                  // C. Breed
                  CustomDropdown(
                    hint: "B.Select Breed",
                    items: cropprovider.breedOptions, // 🔥 from product
                    value: cropprovider.selectedBreed,
                    onChanged: (val) => cropprovider.setBreed(val!),
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "C. Qty",
                    controller: qtyController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "D. Unit",
                    items: ["kg", "gram", "piece", "ltr"],
                    value: provider.selectedC,
                    onChanged: (val) => provider.setC(val!),
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "E. Price(per unit)",
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),

                  SizedBox(height: 10),

                  CustomTextField(
                    hint: "F. Description",
                    controller: descController,
                    inputType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),

            // Description box
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                10,
              ), // space between border and green area
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(45, 252, 12, 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // match title size
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "1. ಹಸು ಉತ್ತಮ ಸ್ಥಿತಿಯಲ್ಲಿ ಇದೆ\n2. No Accident\n3. ಉತ್ತಮ ಪಾಳು ನೀಡಿದೆ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w500, // matching "look" of description
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            CustomButton(
              title: "Preview",
              onPressed: () async {
                final cropSellProvider = Provider.of<CropSellProvider>(
                  context,
                  listen: false,
                );
                final detailsProvider = Provider.of<DetailsProvider>(
                  context,
                  listen: false,
                );

                if (detailsProvider.images.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please upload at least one image"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Map<String, dynamic>
                statusResp = await cropSellProvider.createAd(
                  title: titleController.text.trim(),
                  categoryId: widget.selectedProduct.categoryId.toString(),
                  subCategoryId: widget.selectedProduct.subCategoryId
                      .toString(),
                  productId: widget.selectedProduct.id.toString(),
                  productName: widget.selectedProduct.name,
                  quantity: qtyController.text.isEmpty
                      ? "1"
                      : qtyController.text,
                  unit: provider.selectedC ?? "piece", // 🔥 Use selected value
                  price: priceController.text.isEmpty
                      ? "0"
                      : priceController.text,
                  description: descController.text.trim(),
                  breed: cropSellProvider.selectedBreed ?? "",
                  images: detailsProvider.images,
                );

                final int status = statusResp["status"] ?? 0;

                if (status == 200 || status == 201) {
                  // 🎉 Success popup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ad created successfully!"),
                      backgroundColor: Colors.orange,
                    ),
                  );

                  // 🔥 CLEAR ALL FIELDS + PROVIDERS
                  titleController.clear();
                  qtyController.clear();
                  priceController.clear();
                  descController.clear();

                  cropSellProvider.resetCropForm();
                  detailsProvider.resetDetails();

                  // Wait before navigating
                  Future.delayed(const Duration(milliseconds: 400), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed! Status Code: $status"),
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

  Widget _unitBox(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text),
    );
  }

  Widget _descriptionBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}
