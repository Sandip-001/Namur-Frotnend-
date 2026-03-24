import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:the_namur_frontend/screens/notification_screen.dart';

import 'package:url_launcher/url_launcher.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../Widgets/hexagonal_tile.dart';
import '../provider/auth_provider.dart';
import '../provider/cropplan_provider.dart';
import '../provider/weather_provider.dart';
import '../utils/api_url.dart';
import '../utils/enums.dart' as enums;
import '../utils/my_theme.dart';
import '../provider/category_provider.dart';
import '../provider/friends_provider.dart';
import '../provider/land_product_list_provider.dart';
import '../screens/account_screen.dart';
import '../screens/new_add_screen.dart';
import '../screens/parent_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/calender_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calender_crop_details.dart';

bool isBuySelected = true;
String color = "buy";

class HomeScreen extends StatefulWidget {
  final String? sharedAdId;
  final String? sharedDistrict;

  const HomeScreen({super.key, this.sharedAdId, this.sharedDistrict});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeMainContent(),
    const AccountScreen(),
    const CartScreen(),
    const MapScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      final hasInternet = await _hasInternetConnection();

      if (!hasInternet) {
        await _showNoInternetDialog();
        return;
      }

      _loadInitialData(); // ✅ now safe
    });
  }

  Future<void> _requestPermissions() async {
    // Ask only what your app needs
    final statuses = await [
      Permission.notification,
      Permission.locationWhenInUse,
    ].request();

    // OPTIONAL: handle permanently denied case
    if (statuses[Permission.locationWhenInUse] ==
            PermissionStatus.permanentlyDenied ||
        statuses[Permission.notification] ==
            PermissionStatus.permanentlyDenied) {
      _showPermissionSettingsDialog();
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Please enable permissions from settings to continue using all features.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _loadInitialData() {
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    Provider.of<LandProductListProvider>(
      context,
      listen: false,
    ).fetchLandProductsByCategory("food");
    Provider.of<FriendsProvider>(context, listen: false).fetchFriendsCount();
    Provider.of<AuthProvider>(context, listen: false).saveFcmToken();
    Provider.of<FriendsProvider>(
      context,
      listen: false,
    ).fetchDistrictGroupCount();
  }

  Future<void> _showNoInternetDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false, // 🚫 user must retry
      builder: (context) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text(
            "Please check your internet connection and try again.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final hasInternet = await _hasInternetConnection();

                if (hasInternet) {
                  Navigator.of(context).pop();
                  _loadInitialData(); // 🔥 THIS WAS MISSING
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Still no internet connection"),
                    ),
                  );
                }
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
    );
  }

  getfirebaseid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("firebase_uid");
    print("Fitebase id ======$uid");
  }

  Future<void> _callSharedAdApi(String adId, String district) async {
    final url =
        "https://api.inkaanalysis.com/api/adShare/ad/$adId?district=$district";

    debugPrint("📡 Calling shared ad API: $url");

    try {
      // final response = await http.get(Uri.parse(url));

      // After success:
      // Navigate to ad detail screen
    } catch (e) {
      debugPrint("❌ Share API error: $e");
    }
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).pop(); // closes the drawer first

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Coming Soon!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // 🛒 Cart tapped → Coming Soon
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xff107B28),
          content: Text('Coming Soon!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home_label'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'my_account_label'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: 'cart_label'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on),
            label: 'Maps'.tr(),
          ),
        ],
      ),
    );
  }
}

class HomeMainContent extends StatefulWidget {
  const HomeMainContent({super.key});

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  Color textColor = const Color.fromRGBO(56, 137, 33, 1);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<LandProductListProvider>(
        context,
        listen: false,
      ).fetchLandProductsByCategory("food");
      Provider.of<FriendsProvider>(context, listen: false).fetchFriendsCount();
      Provider.of<AuthProvider>(context, listen: false).saveFcmToken();
      Provider.of<FriendsProvider>(
        context,
        listen: false,
      ).fetchDistrictGroupCount();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
      Provider.of<LandProductListProvider>(
        context,
        listen: false,
      ).fetchLandProductsByCategory("food"),
      Provider.of<FriendsProvider>(context, listen: false).fetchFriendsCount(),
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather(),
      Provider.of<FriendsProvider>(
        context,
        listen: false,
      ).fetchDistrictGroupCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const DrawerMenu(),
      appBar: CustomAppBar(title: 'home_label'.tr(), showBack: false),
      body: Stack(
        children: [
          RefreshIndicator(
            color: MyTheme.primary_color,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 🔽 KEEP YOUR EXISTING UI EXACTLY SAME 🔽

                  // Top info card
                  // Top info card
                  Container(
                    decoration: BoxDecoration(
                      color: MyTheme.field_color,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ========================= PROFILE + STATS =========================
                        Expanded(
                          flex: 6, // 60%
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color.fromRGBO(187, 233, 121, 1),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                // ----------- Profile Image -----------
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    child: FutureBuilder(
                                      future: SharedPreferences.getInstance(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.asset(
                                              'assets/images/profile_dummy.png',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          );
                                        }
                                        final prefs = snapshot.data!;
                                        final profileImagePath =
                                            prefs.getString(
                                              "profile_image_url",
                                            ) ??
                                            "";
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: profileImagePath.isNotEmpty
                                              ? Image.network(
                                                  profileImagePath,
                                                  width: 130,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          value:
                                                              loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                              : null,
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 60,
                                                          height: 60,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 40,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                )
                                              : Image.asset(
                                                  'assets/images/profile_dummy.png',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 60,
                                                          height: 60,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 40,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                ),
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ----------- Stats text -----------
                                Expanded(
                                  child:
                                      Consumer3<
                                        LandProductListProvider,
                                        FriendsProvider,
                                        CategoryProvider
                                      >(
                                        builder:
                                            (
                                              context,
                                              landProvider,
                                              friendsProvider,
                                              categoryProvider,
                                              _,
                                            ) {
                                              final cropCount =
                                                  landProvider.foodItems.length;
                                              final friendCount =
                                                  friendsProvider.friendsCount;
                                              final groupCount = friendsProvider
                                                  .districtGroupCount;

                                              return GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const FriendsScreen(),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'friends_label'.tr(
                                                            args: [
                                                              friendCount
                                                                  .toString(),
                                                            ],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Expanded(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'groups_label'.tr(
                                                            args: [
                                                              groupCount
                                                                  .toString(),
                                                            ],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Expanded(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'crops_label'.tr(
                                                            args: [
                                                              cropCount
                                                                  .toString(),
                                                            ],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ========================= WEATHER CARD =========================
                        Expanded(
                          flex: 4, // 40%
                          child: GestureDetector(
                            onTap: () async {
                              final url = Uri.parse("https://zoom.earth/");
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Consumer<WeatherProvider>(
                              builder: (context, weather, _) {
                                String imageAsset;
                                switch (weather.condition.toLowerCase()) {
                                  case 'clear':
                                    imageAsset = 'assets/weather/sunny.png';
                                    break;
                                  case 'clouds':
                                    imageAsset =
                                        'assets/weather/cloudy-day.png';
                                    break;
                                  case 'rain':
                                  case 'drizzle':
                                    imageAsset =
                                        'assets/weather/heavy-rain.png';
                                    break;
                                  case 'thunderstorm':
                                    imageAsset =
                                        'assets/weather/thunderstorm.png';
                                    break;
                                  case 'snow':
                                    imageAsset = 'assets/weather/snow.png';
                                    break;
                                  default:
                                    imageAsset = 'assets/weather/sunny.png';
                                }

                                return Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color.fromRGBO(187, 233, 121, 1),
                                      width: 2,
                                    ),
                                  ),
                                  child: weather.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(imageAsset, height: 40),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${weather.temperature.toStringAsFixed(1)}°C',
                                                    style: TextStyle(
                                                      color:
                                                          MyTheme.primary_color,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        weather.condition
                                                                    .toLowerCase()
                                                                    .tr() ==
                                                                weather
                                                                    .condition
                                                                    .toLowerCase()
                                                            ? weather.condition
                                                            : weather.condition
                                                                  .toLowerCase()
                                                                  .tr(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: MyTheme
                                                              .primary_color,

                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        weather.city
                                                                    .toLowerCase()
                                                                    .tr() ==
                                                                weather.city
                                                                    .toLowerCase()
                                                            ? weather.city
                                                            : weather.city
                                                                  .toLowerCase()
                                                                  .tr(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: MyTheme
                                                              .primary_color,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  // BUY/SELL toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: Image.asset(
                            'assets/images/new_badge.png',
                            height: 50,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewAddsScreen(),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 155,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1),
                            color: Colors.white,
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: isBuySelected
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  width: 77,
                                  height:
                                      42, // Height slightly less than outer container to account for border
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      11,
                                    ), // Smoother nested radius
                                    color: MyTheme.primary_color,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        color = "buy";
                                        isBuySelected = true;
                                      }),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                          ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'buy_label'.tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: isBuySelected
                                                  ? MyTheme.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        color = "sell";
                                        isBuySelected = false;
                                      }),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(12),
                                          ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'sell_label'.tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: !isBuySelected
                                                  ? MyTheme.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey, // random-ish color
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Hexagon categories
                  Consumer<CategoryProvider>(
                    builder: (context, provider, _) {
                      if (provider.isCategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.categories.isEmpty) {
                        return const Center(child: Text("No categories found"));
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: provider.categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1.15,
                              ),
                          itemBuilder: (context, index) {
                            final cat = provider.categories[index];
                            return HexagonTile(
                              hexagonImage: 'assets/icons/Polygon.png',
                              iconImage: cat.imageUrl ?? '',
                              title: cat.name.toLowerCase().tr(),
                              onTap: () {
                                enums.ParentEnum parentEnum;
                                String catName = cat.name.toLowerCase().trim();
                                int categoryId = cat.id;

                                if (catName.contains('machinery') ||
                                    catName.contains('machine') ||
                                    catName.contains('equipment') ||
                                    catName.contains('tool')) {
                                  parentEnum = enums.ParentEnum.machine;
                                } else if (catName.contains('food') ||
                                    catName.contains('grain') ||
                                    catName.contains('vegetable') ||
                                    catName.contains('fruit') ||
                                    catName.contains('pulses') ||
                                    catName.contains('crop')) {
                                  parentEnum = enums.ParentEnum.food;
                                } else if (catName.contains('animal') ||
                                    catName.contains('bird') ||
                                    catName.contains('poultry') ||
                                    catName.contains('dairy')) {
                                  parentEnum = enums.ParentEnum.animal;
                                } else {
                                  parentEnum = enums.ParentEnum.market;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ParentScreen(
                                      parentEnum: parentEnum,
                                      isBuy: isBuySelected,
                                      isSecondHand: false,
                                      categoryId: categoryId,
                                      categoryName: cat.name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final cropPlanProvider =
                              Provider.of<CropPlanProvider>(
                                context,
                                listen: false,
                              );

                          await cropPlanProvider
                              .fetchCropPlans(); // 🔹 Your user id = 6

                          if (!mounted) return;

                          if (cropPlanProvider.cropPlans.isEmpty) {
                            // 🔹 NO CROP PLAN → OPEN NORMAL CALENDAR
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CalendarScreen(),
                              ),
                            );
                          } else {
                            // 🔹 CROP PLAN EXISTS → OPEN DETAILS SCREEN
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CropCalendarDetailsScreen(),
                              ),
                            );
                          }
                        },

                        child: HexagonTile(
                          hexagonImage: 'assets/icons/Polygon.png',
                          iconImage: 'assets/images/calender_logo.png',
                          title: 'crop_calendar_title'.tr(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                ],
              ),
            ),
          ),
          // 📩 ENQUIRY BUTTON (BOTTOM RIGHT)
          Positioned(
            bottom: -10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.only(right: 0, bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  _showEnquiryDialog();
                },
                child: Image.asset(
                  'assets/icons/support_home.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
        ],
      ),

      /*
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 0, bottom: 16.0), // adjust padding
        child: GestureDetector(
          onTap: () {
            _showEnquiryDialog();
          },
          child: Image.asset(
            'assets/icons/support_home.png',
            width: 50,
            height: 50,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // optional to keep it bottom-right
*/
    );
  }

  Future<void> _showEnquiryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");

    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Send Enquiry",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: "Description",
                    hintText: "Enter your enquiry",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter description"),
                        ),
                      );
                      return;
                    }

                    await _sendEnquiry(
                      userId: userId ?? "6",
                      description: descriptionController.text.trim(),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Send Enquiry"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendEnquiry({
    required String userId,
    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.enquiry);

    final body = jsonEncode({"user_id": userId, "description": description});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enquiry sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to send enquiry")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
