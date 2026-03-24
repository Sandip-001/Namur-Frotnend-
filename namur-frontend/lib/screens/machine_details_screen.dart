import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_button.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_image_picker.dart';
import '../Widgets/custom_textfield.dart';
import '../models/product_model_api.dart';

import '../provider/details_provider.dart';
import '../provider/macinery_details_provider.dart';

import 'machinery_inventory_screen.dart';

class MachineDetailsScreen extends StatefulWidget {
  final ProductModel selectedProduct;

  const MachineDetailsScreen({super.key, required this.selectedProduct});

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  final titleController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final regNoController = TextEditingController();
  final prevOwnerController = TextEditingController();
  final drivenHrsController = TextEditingController();
  final kmsController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  bool _expandMoreDetails = false;
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final detailsProvider = Provider.of<DetailsProvider>(
        context,
        listen: false,
      );
      detailsProvider.clearAllImages();
    });
  }

  int _wordCount = 0;
  String _lastValidText = '';

  void _clearFormAfterSave(
    DetailsProvider detailsProvider,
    MachineryProvider provider,
  ) {
    titleController.clear();
    brandController.clear();
    modelController.clear();
    yearController.clear();
    regNoController.clear();
    prevOwnerController.clear();
    drivenHrsController.clear();
    kmsController.clear();
    qtyController.clear();
    priceController.clear();
    descController.clear();
    _wordCount = 0;
    _lastValidText = '';

    detailsProvider.resetAll();
    provider.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MachineryProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: "Machine Details", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            /// Image Picker
            CustomImagePicker(),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// 1. Title
                  CustomTextField(
                    hint: "1. Product Title *",
                    controller: titleController,
                    maxLength: 75,
                  ),
                  const SizedBox(height: 10),

                  /// 2. Sell / Rent
                  CustomDropdown(
                    hint: "2. Sell / Rent *",
                    items: ["Sell", "Rent"],
                    value: provider.selectedAdType,
                    onChanged: provider.setAdType,
                  ),
                  const SizedBox(height: 10),

                  /// 3. Company / Brand
                  CustomTextField(
                    hint: "3. Company / Brand *",
                    controller: brandController,
                  ),
                  const SizedBox(height: 10),

                  /// 4. Model
                  CustomTextField(
                    hint: "4. Model *",
                    controller: modelController,
                  ),

                  const SizedBox(height: 10),
                  CustomDropdown(
                    hint: "Machine Condition *",
                    items: const ["new", "used"],
                    value: provider.selectedCondition,
                    onChanged: provider.setCondition,
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------------
                  // ⭐ EXPANDABLE SECTION START – "More Details"
                  // ------------------------------------------------------
                  ExpansionTile(
                    initiallyExpanded: _expandMoreDetails,
                    onExpansionChanged: (value) {
                      setState(() {
                        _expandMoreDetails = value;
                      });
                    },

                    trailing: const SizedBox.shrink(),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,

                    title: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFFFD9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Text(
                              "More Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),

                            Icon(
                              _expandMoreDetails
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.black,
                            ),

                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),

                    children: [
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "5. Manufacture Year",
                        controller: yearController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "6. Registration No",
                        controller: regNoController,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "7. Previous Owners",
                        controller: prevOwnerController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "8. Driven Hours",
                        controller: drivenHrsController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "9. Kms Covered",
                        controller: kmsController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomDropdown(
                        hint: "10. Insurance Running",
                        items: ["Yes", "No"],
                        value: provider.selectedInsurance,
                        onChanged: provider.setInsurance,
                      ),
                      const SizedBox(height: 10),

                      CustomDropdown(
                        hint: "11. FC Available",
                        items: ["Yes", "No"],
                        value: provider.selectedFc,
                        onChanged: provider.setFc,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 12. Quantity
                  CustomTextField(
                    hint: "12. Quantity *",
                    controller: qtyController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  /// 13. Price
                  CustomTextField(
                    hint: "13. Price *",
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  /// 14. Description
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

                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),

            provider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    width: 150,
                    title: "Post Ad",
                    onPressed: () async {
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

                      // Prepare ad data
                      Map<String, dynamic> adData = {
                        "title": titleController.text,
                        "categoryId": widget.selectedProduct.categoryId
                            .toString(),
                        "subCategoryId": widget.selectedProduct.subCategoryId
                            .toString(),
                        "productId": widget.selectedProduct.id.toString(),
                        "productName": widget.selectedProduct.name,
                        "quantity": qtyController.text,
                        "price": priceController.text,
                        "description": descController.text,
                        "brand": brandController.text,
                        "model": modelController.text,
                        "manufactureYear": yearController.text,
                        "registrationNo": regNoController.text,
                        "prevOwners": prevOwnerController.text,
                        "drivenHours": drivenHrsController.text,
                        "kmsCovered": kmsController.text,
                        "images": detailsProvider.images
                            .map((f) => f.path)
                            .toList(),
                      };

                      // Check connectivity
                      final connectivity = await Connectivity()
                          .checkConnectivity();
                      final isOnline = connectivity.any((result) => result != ConnectivityResult.none);

                      if (!isOnline) {
                        // Save offline if no internet
                        await provider.saveOfflineAd(adData);
                        _clearFormAfterSave(detailsProvider, provider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No internet. Ad saved offline"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Make API call
                      final response = await provider.createAd(
                        title: titleController.text,
                        categoryId: widget.selectedProduct.categoryId
                            .toString(),
                        subCategoryId: widget.selectedProduct.subCategoryId
                            .toString(),
                        productId: widget.selectedProduct.id.toString(),
                        productName: widget.selectedProduct.name,
                        quantity: qtyController.text,
                        price: priceController.text,
                        description: descController.text,
                        brand: brandController.text,
                        model: modelController.text,
                        manufactureYear: yearController.text,
                        registrationNo: regNoController.text,
                        prevOwners: prevOwnerController.text,
                        drivenHours: drivenHrsController.text,
                        kmsCovered: kmsController.text,
                        images: detailsProvider.images,
                        machineCondition: provider.selectedCondition,
                      );

                      final status = response["status"] ?? 0;
                      final body = response["body"] ?? "";

                      if (status == 200 || status == 201) {
                        // Success
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ad posted successfully"),
                            backgroundColor: Colors.orange,
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MachineryInventoryScreen(
                              selectedProduct: widget.selectedProduct,
                              filterType: 'rent',
                            ),
                          ),
                          (route) => route.isFirst,
                        );
                      } else if (status == 400 || status == 422) {
                        // Validation error from API
                        try {
                          final message =
                              json.decode(body)["message"] ??
                              "Validation error";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } catch (e) {
                          // Fallback in case parsing fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Validation error occurred"),
                            ),
                          );
                        }
                      } else {
                        // Other failures → save offline
                        await provider.saveOfflineAd(adData);
                        _clearFormAfterSave(detailsProvider, provider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Upload failed. Saved offline"),
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
