import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/screens/allmachinery_product_screen.dart';
import 'package:the_namur_frontend/screens/allother_product_screen.dart';

import 'package:the_namur_frontend/screens/friends_screen.dart';
import 'package:the_namur_frontend/screens/machine_details_screen.dart';

import 'package:the_namur_frontend/screens/product_details_screen.dart';
import 'package:the_namur_frontend/screens/product_inventory_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';

import '../Widgets/three_way_toggle.dart';
import '../provider/machinery_ads_provider.dart';
import '../provider/product_ads_provider.dart';
import '../provider/category_provider.dart';
import '../utils/enums.dart' as enums;
import '../utils/imageLinks.dart';
import 'machinery_inventory_screen.dart';

class ParentScreen extends StatefulWidget {
  final enums.ParentEnum parentEnum;
  final bool isBuy;
  final bool isSecondHand;
  final int initialIndexForTabBar;
  final int categoryId;
  final String categoryName;

  const ParentScreen({
    super.key,
    required this.parentEnum,
    this.isBuy = false,
    this.isSecondHand = false,
    this.initialIndexForTabBar = 0,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  late bool? isSwitched;
  late Future<int> totalFarmersCountFuture;
  var imageForName = imageForNameCloud;

  var categoryListForParentEnum = enums.categoryListForParentEnum;
  var nameForParentEnum = enums.nameForParentEnum;
  var nameForCategoryEnum = enums.nameForCategoryEnum;
  var subCategoryListsForCategory = enums.subCategoryListsForCategory;
  var nameForSubCategoryEnum = enums.nameForSubCategoryEnum;
  String rentFilter = 'all'; // default to 'all' (center)
  //var imageForName = imageForNameCloud;

  Future<int> getTotalFarmersCount({required String parentName}) async {
    return 0;
  }

  String appbarTitle = '';
  @override
  void initState() {
    super.initState();
    String catName = widget.categoryName.toLowerCase();
    if (catName.contains('animal')) {
      appbarTitle = 'Animals';
    } else if (catName.contains('food') || catName.contains('grain')) {
      appbarTitle = 'Food Crops';
    } else {
      appbarTitle = widget.categoryName;
    }

    // 1️⃣ Load sub-categories first
    Future.microtask(() async {
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      await provider.loadSubCategories(widget.categoryId);

      // 2️⃣ After loading subcategories, load products for the FIRST tab
      if (provider.subCategories.isNotEmpty) {
        final firstSubId = provider.subCategories.first.id;
        provider.loadProductsForTab(firstSubId);
      }
    });

    // Your existing logic
    if (widget.parentEnum == enums.ParentEnum.machine) {
      isSwitched = false;
    } else {
      isSwitched = null;
    }

    totalFarmersCountFuture = getTotalFarmersCount(
      parentName: nameForParentEnum[widget.parentEnum]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: provider.subCategories.length,
          child: Scaffold(
            drawer: const DrawerMenu(),
            appBar: CustomAppBar(title: appbarTitle, showBack: true),

            body: provider.isSubCategoryLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.subCategories.isEmpty
                ? const Center(
                    child: Text(
                      "Coming Soon!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // -------------------- TOP FARMER SECTION --------------------
                      Container(
                        height: 70,
                        width: double.infinity,
                        color: Colors.blueGrey.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            // LEFT: Farmer icon + count
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FriendsScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/icons/farmer.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.people,
                                      size: 36,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "200 Farmers",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // RIGHT: Three-position toggle (Rent | All | Buy)
                            if (widget.parentEnum == enums.ParentEnum.machine)
                              ThreeWayToggle(
                                selectedValue: rentFilter,
                                onChanged: (v) {
                                  setState(() {
                                    rentFilter = v;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),

                      // -------------------- TAB BAR --------------------
                      MediaQuery.removePadding(
                        context: context,
                        removeLeft: true,
                        removeRight: true,
                        child: TabBar(
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          indicator: BoxDecoration(
                            color: const Color(0xff4C7B10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          isScrollable: provider.subCategories.length > 3,
                          tabs: provider.subCategories.map((sub) {
                            return Tab(
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  sub.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onTap: (index) {
                            final subId = provider.subCategories[index].id;
                            provider.loadProductsForTab(subId);
                          },
                        ),
                      ),

                      // -------------------- TAB CONTENT --------------------
                      Expanded(
                        child: TabBarView(
                          children: provider.subCategories.map((sub) {
                            final subId = sub.id;
                            final products =
                                provider.productsBySubCategory[subId];

                            if (products == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (products.isEmpty) {
                              return const Center(
                                child: Text("No products found"),
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shrinkWrap: true,
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                              itemBuilder: (context, index) {
                                final product = products[index];

                                return InkWell(
                                  onTap: () async {
                                    print(widget.isBuy);
                                    if (!widget.isBuy) {
                                      int productId =
                                          product.id; // selected product ID

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? userId = prefs.getString("uid");
                                      String productCategory = product
                                          .categoryName
                                          .toLowerCase();

                                      if (productCategory.contains(
                                        "machinery",
                                      )) {
                                        final machineryProvider =
                                            Provider.of<MachineryAdsProvider>(
                                              context,
                                              listen: false,
                                            );

                                        bool hasAds = await machineryProvider
                                            .fetchMachineryAds(
                                              productId.toString(),
                                            );

                                        if (hasAds) {
                                          print('machinery ads exist');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MachineryInventoryScreen(
                                                    selectedProduct: product,
                                                    filterType: rentFilter,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          print('no machinery ads');
                                          // ❌ No ads → Go to Machinery Details screen or create screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => openScreen(
                                                widget.categoryName,
                                                widget.isBuy,
                                                product,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // PRODUCT ADS LOGIC
                                        final adsProvider =
                                            Provider.of<ProductAdsProvider>(
                                              context,
                                              listen: false,
                                            );

                                        bool hasAds = await adsProvider
                                            .fetchProductAds(
                                              userId ?? "",
                                              productId,
                                            );

                                        if (hasAds) {
                                          print('product ads exist');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductInventoryScreen(
                                                    selectedProduct: product,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          print('no product ads');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => openScreen(
                                                widget.categoryName,
                                                widget.isBuy,
                                                product,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => openScreen(
                                            widget.categoryName,
                                            widget.isBuy,
                                            product,
                                          ),
                                        ),
                                      );
                                    }
                                  },

                                  // selected product ID
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.all(5),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    product.imageUrl ?? "",
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                errorWidget: (_, __, ___) =>
                                                    const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget openScreen(String parentType, bool isBuy, product) {
    if (isBuy) {
      if (widget.parentEnum == enums.ParentEnum.machine) {
        return AllMachineryProductsScreen(
          productId: product,
          filterType: rentFilter,
        );
      } else {
        return AllOtherProductsScreen(product: product);
      }
    } else {
      if (widget.parentEnum == enums.ParentEnum.animal) {
        return ProductDetailsScreen(
          selectedProduct: product,
          screenTitle: "Animal Details",
        );
      } else if (widget.parentEnum == enums.ParentEnum.food) {
        return ProductDetailsScreen(
          selectedProduct: product,
          screenTitle: "Crop Details",
        );
      } else if (widget.parentEnum == enums.ParentEnum.machine) {
        return MachineDetailsScreen(selectedProduct: product);
      } else {
        // Fallback for market/others
        return MachineDetailsScreen(selectedProduct: product);
      }
    }
  }
}
