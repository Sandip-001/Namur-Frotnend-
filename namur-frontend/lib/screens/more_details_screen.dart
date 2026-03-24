// lib/screens/more_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/string_extension.dart';

import 'edit_profile_screen.dart';
import 'land_details_screen.dart';
import '../Widgets/header_card.dart';
import '../provider/details_expand_provider.dart';
import '../provider/land_product_list_provider.dart';
import '../provider/land_provider.dart';
import '../provider/user_provider.dart';
import '../provider/friends_provider.dart';

class MoreDetailsScreen extends StatefulWidget {
  const MoreDetailsScreen({super.key});

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {
  String profileUrl = "";
  String userSociety = "";
  int friendsCount = 0;
  int groupsCount = 0;
  bool _isLoadingHeader = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrent) {
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final landProvider = Provider.of<LandDetailsProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<LandProductListProvider>(
      context,
      listen: false,
    );
    final friendsProvider = Provider.of<FriendsProvider>(
      context,
      listen: false,
    );

    await userProvider.fetchProfile();

    await landProvider.fetchLandsByUser();
    if (landProvider.lands.isNotEmpty) {
      productProvider.fetchLandProductsByCategory("Machinery");
      productProvider.fetchLandProductsByCategory("Food");
      productProvider.fetchLandProductsByCategory("Animal");
    }

    await friendsProvider.fetchFriendsCount();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");

    profileUrl = prefs.getString("profile_image_url") ?? "";
    userSociety = prefs.getString("district")?.toTitleCase() ?? "";

    if (userId != null) {
      await friendsProvider.fetchUserGroups(int.parse(userId));
    }

    setState(() {
      friendsCount = friendsProvider.friendsCount;
      groupsCount = friendsProvider.groups.length;
      _isLoadingHeader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expandProvider = Provider.of<DetailsExpandProvider>(context);

    Widget buildSection(
      String title,
      String key,
      Widget content, {
      Color? color,
    }) {
      final isExpanded = _getExpandedState(expandProvider, key);
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => expandProvider.toggle(key),
              child: Container(
                decoration: BoxDecoration(
                  color: color ?? const Color.fromRGBO(45, 252, 12, 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: content,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "more_details".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 35, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoadingHeader)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5,
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userP, _) {
                    final user = userP.user;
                    if (user == null) return const CircularProgressIndicator();
                    print("prog ${user.profileProgress}");
                    return HeaderCard(
                      profileUrl: profileUrl.isNotEmpty
                          ? profileUrl
                          : "https://picsum.photos/100",
                      friendsText: "friends_neighbors".tr(
                        args: [friendsCount.toString()],
                      ),
                      groupsText: "groups_count".tr(
                        args: [groupsCount.toString()],
                      ),
                      societyText: "society".tr(args: [userSociety]),
                      progressValue: user.profileProgress ?? 0.0,
                    );
                  },
                ),
              ),

            // 1️⃣ Address
            buildSection(
              "my_location".tr(),
              "location",
              Consumer<UserProvider>(
                builder: (context, userP, _) {
                  final user = userP.user;
                  if (user == null) return Text("loading_address".tr());
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("district".tr(), user.district?.toTitleCase()),
                      _infoRow("taluk".tr(), user.taluk?.toTitleCase()),
                      _infoRow("village".tr(), user.village?.toTitleCase()),
                      _infoRow("panchayat".tr(), user.panchayat?.toTitleCase()),
                    ],
                  );
                },
              ),
            ),

            // 2️⃣ Farm Details
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LandDetailsScreen(),
                  ),
                );
              },
              child: buildSection(
                "my_farm_details".tr(),
                "farm",
                Consumer<LandDetailsProvider>(
                  builder: (context, landP, _) {
                    if (landP.isLoadingList) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (landP.lands.isEmpty) {
                      return Text("no_details".tr(args: ["Farm"]));
                    }

                    return Column(
                      children: landP.lands.map((land) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 25,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "${land.landName.toTitleCase()} (${land.farmSize} Acres) @${land.village.toTitleCase()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                land.hissaNo.trim().isNotEmpty
                                    ? "${land.surveyNo}/${land.hissaNo}"
                                    : land.surveyNo,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            // 3️⃣ Machinery
            buildSection(
              "my_machinery".tr(),
              "machinary",
              _buildProductList(context, "Machinery"),
            ),

            // 4️⃣ Crops
            buildSection(
              "my_crops".tr(),
              "crops",
              _buildProductList(context, "Food"),
            ),

            // 5️⃣ Animals
            buildSection(
              "my_animals".tr(),
              "animals",
              _buildProductList(context, "Animal"),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(value?.isNotEmpty == true ? value! : 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, String category) {
    return Consumer<LandProductListProvider>(
      builder: (context, productProvider, _) {
        final items = category == "Machinery"
            ? productProvider.machineryItems
            : category == "Food"
            ? productProvider.foodItems
            : productProvider.animalItems;

        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) return Text("No $category details available");

        return SizedBox(
          height: 130, // Increased from 100 to fix overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ImageCard(item: item);
            },
          ),
        );
      },
    );
  }

  Widget ImageCard({required LandProductItem item}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.network(
                item.imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.productName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _getExpandedState(DetailsExpandProvider provider, String key) {
    switch (key) {
      case 'location':
        return provider.locationExpanded;
      case 'kyc':
        return provider.kycExpanded;
      case 'farm':
        return provider.farmExpanded;
      case 'machinary':
        return provider.machinaryExpanded;
      case 'crops':
        return provider.cropsExpanded;
      case 'animals':
        return provider.animalsExpanded;
      default:
        return false;
    }
  }
}
