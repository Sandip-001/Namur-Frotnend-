import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';

import '../Widgets/header_card.dart';
import '../provider/friends_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String profileUrl = "";
  String userSociety = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final friendsProvider = Provider.of<FriendsProvider>(
        context,
        listen: false,
      );
      await friendsProvider.fetchFriendsCount();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("uid");

      // Load shared preference values
      profileUrl = prefs.getString("profile_image_url") ?? "";
      userSociety = prefs.getString("district") ?? "";

      setState(() {});

      if (userId != null) {
        await friendsProvider.fetchUserGroups(int.parse(userId));
      }
    });
  }

  void onGroupTap(int index) {
    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GroupsScreen()),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'friends_title'.tr(), showBack: true),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Consumer<FriendsProvider>(
          builder: (context, friendsProvider, child) {
            final friendsCount = friendsProvider.friendsCount;
            final groups = friendsProvider.groups;
            final isLoadingGroups = friendsProvider.isLoadingGroups;

            return ListView(
              children: [
                HeaderCard(
                  profileUrl: profileUrl.isNotEmpty
                      ? profileUrl
                      : "https://picsum.photos/100",
                  friendsText:
                      "$friendsCount ${'friends_count'.tr()} & Neighbors",
                  groupsText: "${groups.length} ${'groups_title'.tr()}",
                  societyText: tr(
                    'society_text',
                    namedArgs: {'society_name': userSociety},
                  ),
                  progressValue: 0,
                ),

                const SizedBox(height: 16),

                Text(
                  'groups_title'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                isLoadingGroups
                    ? const Center(child: CircularProgressIndicator())
                    : groups.isEmpty
                    ? Text('no_groups_found'.tr())
                    : SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final group = groups[index];

                            return GestureDetector(
                              onTap: () => onGroupTap(index),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        group['product_image_url'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/profile_dummy.png',
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      group['product_name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
