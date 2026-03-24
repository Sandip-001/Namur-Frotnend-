import 'package:flutter/material.dart';

class SortFilterWidget extends StatefulWidget {
  const SortFilterWidget({super.key});

  @override
  State<SortFilterWidget> createState() => _SortFilterWidgetState();
}

class _SortFilterWidgetState extends State<SortFilterWidget> {
  String selectedSort = "None"; // "Low to High" / "High to Low"
  List<String> selectedBreeds = [];
  List<String> allBreeds = ["Tractor", "Harvester", "Plough", "Sprayer"]; // Example

  bool showFilter = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOP SORT & FILTER BUTTONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Toggle filter section
                setState(() {
                  showFilter = !showFilter;
                });
              },
              icon: const Icon(Icons.filter_list),
              label: const Text("Filter"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Show sort options dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Sort by Price"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: const Text("Low to High"),
                          value: "Low to High",
                          groupValue: selectedSort,
                          onChanged: (value) {
                            setState(() {
                              selectedSort = value!;
                              Navigator.pop(context);
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text("High to Low"),
                          value: "High to Low",
                          groupValue: selectedSort,
                          onChanged: (value) {
                            setState(() {
                              selectedSort = value!;
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.sort),
              label: const Text("Sort"),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // FILTER SECTION
        if (showFilter)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Breeds",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // Breed Checkboxes
                Wrap(
                  spacing: 10,
                  children: allBreeds.map((breed) {
                    return FilterChip(
                      label: Text(breed),
                      selected: selectedBreeds.contains(breed),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedBreeds.add(breed);
                          } else {
                            selectedBreeds.remove(breed);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedBreeds.clear();
                        });
                      },
                      child: const Text("Clear"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Apply filter logic here later
                        setState(() {
                          showFilter = false;
                        });
                      },
                      child: const Text("Apply"),
                    ),
                  ],
                )
              ],
            ),
          ),
      ],
    );
  }
}
