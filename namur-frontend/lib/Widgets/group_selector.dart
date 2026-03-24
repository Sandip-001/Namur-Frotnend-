import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupSelector extends StatelessWidget {
  final List<GroupModel> groups;
  final Function(int) onTap;

  const GroupSelector({super.key, required this.groups, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final group = groups[index];
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: group.isActive ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.network(group.iconPath, width: 100, height: 100),
                  if (group.isActive)
                    const Icon(Icons.check_circle, color: Colors.green, size: 25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

