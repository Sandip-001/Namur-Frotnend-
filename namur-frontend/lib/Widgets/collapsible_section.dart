import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  const CollapsibleSection({super.key, required this.title, required this.child});

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
