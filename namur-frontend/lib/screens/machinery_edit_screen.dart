import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_image_picker.dart';
import '../Widgets/custom_button.dart';
import '../Widgets/custom_textfield.dart';
import '../models/machinery_ad_model.dart';
import '../provider/details_provider.dart';
import '../provider/machinery_ads_provider.dart';
import '../provider/macinery_details_provider.dart';

class MachineryEditScreen extends StatefulWidget {
  final MachineryAdModel machinery;

  const MachineryEditScreen({super.key, required this.machinery});

  @override
  State<MachineryEditScreen> createState() => _MachineryEditScreenState();
}

class _MachineryEditScreenState extends State<MachineryEditScreen> {
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

  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();

    final m = widget.machinery;

    titleController.text = m.title;
    brandController.text = m.extraFields!.brand;
    modelController.text = m.extraFields!.model;
    yearController.text = m.extraFields!.manufactureYear.toString();
    regNoController.text = m.extraFields!.registrationNo;
    prevOwnerController.text = m.extraFields!.prevOwners.toString();
    drivenHrsController.text = m.extraFields!.drivenHours.toString();
    kmsController.text = m.extraFields!.kmsCovered.toString();
    qtyController.text = m.quantity;
    priceController.text = m.price;
    descController.text = m.description;

    final provider = Provider.of<MachineryProvider>(context, listen: false);
    provider.selectedAdType = m.adType;
    provider.selectedCondition =
        (m.extraFields!.condition ?? "new").toLowerCase().trim();

    provider.selectedInsurance = m.extraFields!.insuranceRunning;
    provider.selectedFc = m.extraFields!.fcValue;

    Future.microtask(() {
      final detailsProvider = Provider.of<DetailsProvider>(context, listen: false);
      detailsProvider.setExistingImages(widget.machinery.images);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    regNoController.dispose();
    prevOwnerController.dispose();
    drivenHrsController.dispose();
    kmsController.dispose();
    qtyController.dispose();
    priceController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MachineryProvider>(context);
    final detailsProvider = Provider.of<DetailsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: "edit_machinery".tr(), showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                  CustomTextField(
                    hint: "machine_title".tr(),
                    controller: titleController,
                  ),
                  const SizedBox(height: 10),

                  CustomDropdown(
                    hint: "sell_or_rent".tr(),
                    items: ["sell".tr(), "rent".tr()],
                    value: provider.selectedAdType,
                    onChanged: provider.setAdType,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "brand".tr(),
                    controller: brandController,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "model".tr(),
                    controller: modelController,
                  ),
                  const SizedBox(height: 10),
                  CustomDropdown(
                    hint: "condition",
                    items: ["new", "used"],
                    value: provider.selectedCondition,
                    onChanged: provider.setCondition,
                  ),
                  const SizedBox(height: 10),

                  // ------------------------------------------------------------------
                  // ⭐ EXPANDABLE SECTION — SAME AS MachineDetailsScreen
                  // ------------------------------------------------------------------
                  ExpansionTile(
                    initiallyExpanded: false,
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
                            Text(
                              "More details",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),

                    children: [
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "manufacture_year".tr(),
                        controller: yearController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "registration_no".tr(),
                        controller: regNoController,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "previous_owners".tr(),
                        controller: prevOwnerController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "driven_hours".tr(),
                        controller: drivenHrsController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        hint: "kms_covered".tr(),
                        controller: kmsController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      CustomDropdown(
                        hint: "insurance_running".tr(),
                        items: ["yes".tr(), "no".tr()],
                        value: provider.selectedInsurance,
                        onChanged: provider.setInsurance,
                      ),
                      const SizedBox(height: 10),

                      CustomDropdown(
                        hint: "fc_available".tr(),
                        items: ["yes".tr(), "no".tr()],
                        value: provider.selectedFc,
                        onChanged: provider.setFc,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "quantity".tr(),
                    controller: qtyController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "price".tr(),
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    hint: "description".tr(),
                    controller: descController,
                    maxLines: 4,
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                ],
              )

            ),
            const SizedBox(height: 16),

            provider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              title: "update".tr(),
              onPressed: () async {
                final provider = Provider.of<MachineryAdsProvider>(context, listen: false);
                final detailsProvider = Provider.of<DetailsProvider>(context, listen: false);

                setState(() => provider.isLoading = true);

                int status = await provider.updateAd(
                  adId: widget.machinery.id,
                  title: titleController.text,
                  quantity: qtyController.text,
                  price: priceController.text,
                  description: descController.text,
                  adType: provider.selectedAdType,
                  condition: provider.selectedCondition,
                  unit: widget.machinery.unit,

                  brand: brandController.text,
                  model: modelController.text,
                  manufactureYear: yearController.text,
                  registrationNo: regNoController.text,
                  prevOwners: prevOwnerController.text,
                  drivenHours: drivenHrsController.text,
                  kmsCovered: kmsController.text,
                  insuranceRunning: provider.selectedInsurance,
                  fcValue: provider.selectedFc,

                  existingImages: detailsProvider.existingImages,
                  newImages: detailsProvider.images,
                  districts: widget.machinery.districts,
                );

                setState(() => provider.isLoading = false);

                if (status == 200 || status == 201) {
                  detailsProvider.resetAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("update_success".tr())),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("update_failed".tr())),
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
