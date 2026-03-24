// lib/screens/land_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import '../provider/details_expand_provider.dart';
import '../provider/land_product_list_provider.dart';
import '../provider/land_provider.dart';

class LandDetailsScreen extends StatefulWidget {
  const LandDetailsScreen({super.key});

  @override
  State<LandDetailsScreen> createState() => _LandDetailsScreenState();
}

class _LandDetailsScreenState extends State<LandDetailsScreen> {
  late PageController _pageController;
  late ScrollController _tabScrollController;
  List<GlobalKey> tabKeys = [];
  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    _tabScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final landProvider = Provider.of<LandDetailsProvider>(
        context,
        listen: false,
      );

      if (landProvider.lands.isNotEmpty) {
        final firstLand = landProvider.lands.first;
        landProvider.selectLand(firstLand);

        final prodProvider = Provider.of<LandProductListProvider>(
          context,
          listen: false,
        );
        for (var category in ["food", "machinery", "animal"]) {
          prodProvider.fetchLandProductsByCategoryForLand(
            landId: firstLand.id,
            category: category,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expandProvider = Provider.of<DetailsExpandProvider>(context);

    final landProvider = Provider.of<LandDetailsProvider>(context);
    if (tabKeys.length != landProvider.lands.length) {
      tabKeys = List.generate(landProvider.lands.length, (_) => GlobalKey());
    }
    if (landProvider.isLoadingList) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (landProvider.lands.isEmpty) {
      return const Scaffold(body: Center(child: Text("No land available")));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(title: "Land", showBack: true),
      body: Column(
        children: [
          landTabs(context, _pageController, _tabScrollController, tabKeys),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: landProvider.lands.length,
              onPageChanged: (index) {
                final land = landProvider.lands[index];
                landProvider.selectLand(land);

                // ✅ WAIT until frame is built, THEN scroll tab
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final tabContext = tabKeys[index].currentContext;
                  if (tabContext != null) {
                    Scrollable.ensureVisible(
                      tabContext,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: 0.5, // keep selected tab centered
                    );
                  }
                });

                final prodProvider = Provider.of<LandProductListProvider>(
                  context,
                  listen: false,
                );

                for (var category in ["food", "machinery", "animal"]) {
                  prodProvider.fetchLandProductsByCategoryForLand(
                    landId: land.id,
                    category: category,
                  );
                }
              },

              itemBuilder: (context, index) {
                final selectedLand = landProvider.lands[index];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _section(
                        title: "Land Area Size",
                        key: "landArea",
                        expandProvider: expandProvider,
                        content: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/land.png',
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(68, 246, 5, 0.44),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Name: ${selectedLand.landName}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Survey No: ${selectedLand.surveyNo}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Area: ${selectedLand.farmSize} Acre",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _section(
                        title: "Crop Detail",
                        key: "crop",
                        expandProvider: expandProvider,
                        content: Consumer<LandProductListProvider>(
                          builder: (context, prodList, _) {
                            final items = prodList.landFoodItems
                                .where((i) => i.id == selectedLand.id)
                                .toList();
                            if (prodList.isNewCategoryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (items.isEmpty) {
                              return const Text("No crop details available");
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: items
                                    .map(
                                      (item) => _imageCard(
                                        item: item,
                                        onDelete: () async {
                                          final ok = await prodList
                                              .deleteLandProduct(item.id);
                                          if (ok) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Deleted successfully",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      _section(
                        title: "Machine Details",
                        key: "implement",
                        expandProvider: expandProvider,
                        content: Consumer<LandProductListProvider>(
                          builder: (context, prodList, _) {
                            final items = prodList.landMachineryItems
                                .where((i) => i.id == selectedLand.id)
                                .toList();
                            if (prodList.isNewCategoryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (items.isEmpty) {
                              return const Text(
                                "No machinery details available",
                              );
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: items
                                    .map(
                                      (item) => _imageCard(
                                        item: item,
                                        onDelete: () async {
                                          final ok = await prodList
                                              .deleteLandProduct(item.id);
                                          if (ok) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Deleted successfully",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      _section(
                        title: "Animal Details",
                        key: "animal",
                        expandProvider: expandProvider,
                        content: Consumer<LandProductListProvider>(
                          builder: (context, prodList, _) {
                            final items = prodList.landAnimalItems
                                .where((i) => i.id == selectedLand.id)
                                .toList();
                            if (prodList.isNewCategoryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (items.isEmpty) {
                              return const Text("No animal details available");
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: items
                                    .map(
                                      (item) => _imageCard(
                                        item: item,
                                        onDelete: () async {
                                          final ok = await prodList
                                              .deleteLandProduct(item.id);
                                          if (ok) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Deleted successfully",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String key,
    required DetailsExpandProvider expandProvider,
    required Widget content,
  }) {
    final expanded = _expandedState(expandProvider, key);
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(73, 243, 13, 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
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
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _imageCard({required dynamic item, required VoidCallback onDelete}) {
    return Container(
      width: 110,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.productName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  bool _expandedState(DetailsExpandProvider provider, String key) {
    switch (key) {
      case 'landArea':
        return provider.landAreaExpanded;
      case 'crop':
        return provider.cropExpanded;
      case 'implement':
        return provider.implementExpanded;
      case 'animal':
        return provider.animalExpanded;
      case 'date':
        return provider.dateExpanded;
      case 'contact':
        return provider.contactExpanded;
      default:
        return false;
    }
  }
}

Widget landTabs(
  BuildContext context,
  PageController pageController,
  ScrollController tabScrollController,
  List<GlobalKey> tabKeys,
) {
  return Consumer<LandDetailsProvider>(
    builder: (context, landP, _) {
      if (landP.isLoadingList) {
        return const Center(child: CircularProgressIndicator());
      }
      if (landP.lands.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text("No land available"),
        );
      }

      final selectedId =
          (landP.selectedLandId != null &&
              landP.lands.any((e) => e.id == landP.selectedLandId))
          ? landP.selectedLandId
          : null;

      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          controller: tabScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: landP.lands.length,
          itemBuilder: (context, index) {
            final land = landP.lands[index];
            final isActive = land.id == selectedId;

            return GestureDetector(
              onTap: () {
                // 1️⃣ Update selected land
                landP.selectLand(land);

                // 2️⃣ Change page
                pageController.jumpToPage(index);

                // 3️⃣ Auto-scroll the tab into view 🔥
                final tabContext = tabKeys[index].currentContext;
                if (tabContext != null) {
                  Scrollable.ensureVisible(
                    tabContext,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: 0.5, // centers the selected tab
                  );
                }

                // 4️⃣ Fetch products for the selected land
                final prodProvider = Provider.of<LandProductListProvider>(
                  context,
                  listen: false,
                );

                for (var category in ["food", "machinery", "animal"]) {
                  prodProvider.fetchLandProductsByCategoryForLand(
                    landId: land.id,
                    category: category,
                  );
                }
              },

              child: Container(
                key: tabKeys[index],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    land.landName,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
