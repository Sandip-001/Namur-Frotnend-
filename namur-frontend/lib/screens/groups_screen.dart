import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/group_model.dart';
import '../widgets/group_selector.dart';
import '../widgets/member_avatar.dart';
import '../Widgets/custom_appbar.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<GroupModel> groups = [
    GroupModel(
        name: "Veg",
        iconPath:
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FfruitsAndVeg%2FGreen%20Onion.png?alt=media&token=4d352fdf-fb0b-44d9-b043-4618471340b0',
        isActive: true),
    GroupModel(
      name: "Milk",
      iconPath:
      'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2Fanimals%2Fmilk%20tank.png?alt=media&token=474b8c03-19c6-4667-8af0-68e15a5a1826',
    ),
    GroupModel(
      name: "Storage",
      iconPath:
      'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2Fanimals%2Fpet%20supplies.png?alt=media&token=7b4930fc-a1c7-4b51-a8cc-1dbe42e1061f',
    ),
  ];

  void onGroupTap(int index) {
    setState(() {
      groups = groups
          .map((g) => GroupModel(
        name: g.name,
        iconPath: g.iconPath,
        isActive: groups.indexOf(g) == index,
      ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final members = List.generate(
      9,
          (index) => "https://picsum.photos/${200 + index}",
    );

    return Scaffold(
      appBar: CustomAppBar(title: 'groups_title'.tr(), showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text('groups_title'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GroupSelector(groups: groups, onTap: onGroupTap),
            const SizedBox(height: 16),
            Text(
              'members_count'.tr(args: ['325']),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
              members.map((url) => MemberAvatar(imageUrl: url)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
