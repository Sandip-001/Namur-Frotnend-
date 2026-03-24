import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model_api.dart';
import '../provider/product_provider_api.dart';

class ProductDropdown extends StatelessWidget {
  final String category; // food / machinery / animal
  final String hint;
  final Function(int)? onSelected;

  const ProductDropdown({
    super.key,
    required this.category,
    this.hint = "Select Item",
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productP, _) {
        // Pick correct list based on category
        List<ProductModel> list = [];
        if (category == "food") list = productP.cropList;
        if (category == "machinery") list = productP.machineryList;
        if (category == "animal") list = productP.animalList;

        if (productP.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ⭐ HANDLE EMPTY ITEMS → Show disabled dropdown
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.90, // ⬅ updated
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(232, 229, 229, 0.75),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: null,
                  hint: const Text(
                    "No items available",
                    style: TextStyle(color: Colors.grey),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: const [], // no items
                  onChanged: null, // disabled
                ),
              ),
            ),
          );
        }

        int? selectedId;
        if (category == "food") selectedId = productP.selectedCropId;
        if (category == "machinery") selectedId = productP.selectedMachineryId;
        if (category == "animal") selectedId = productP.selectedAnimalId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.90, // ⬅ updated
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(232, 229, 229, 0.75),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                hint: Text(
                  hint,
                  style: const TextStyle(color: Colors.grey),
                ),
                value: selectedId,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: list.map((ProductModel p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;

                  // save selected value
                  if (category == "food") productP.selectCrop(val);
                  if (category == "machinery") productP.selectMachinery(val);
                  if (category == "animal") productP.selectAnimal(val);

                  if (onSelected != null) onSelected!(val);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
