import 'package:flutter/material.dart';
import '../models/cropplan_model.dart';
import '../Widgets/crop_calendar_header.dart';
import '../provider/cropplan_provider.dart';
import 'package:provider/provider.dart';

class CostEstimationScreen extends StatelessWidget {
  final List<CostEstimate> costList;

  const CostEstimationScreen({super.key, required this.costList});

  @override
  Widget build(BuildContext context) {
    // Calculate total
    int total = costList.fold(
        0, (sum, item) => sum + (int.tryParse(item.cost) ?? 0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cost Estimation"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const CropCalendarHeader(activeScreen: "cost_estimate"),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Description",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Cost (Rs)",
                            style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Table Rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: costList.length,
                      itemBuilder: (context, index) {
                        final item = costList[index];
                        return Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.description,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                item.cost,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Total Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          total.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
