import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:the_namur_frontend/utils/api_url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/drawer_menu.dart';
import '../Widgets/overlap_avatar.dart';
import '../Widgets/profile_header.dart';
import '../models/news_model.dart';
import '../provider/friends_provider.dart';
import '../provider/user_provider.dart';
import '../services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showNews = true;
  bool isbarcode = false;
  int friendsCount = 0;

  List<String> avatarImages = [];

  @override
  void initState() {
    print('profile screen');
    super.initState();
    _loadUserId();
    _loadProfile();
    _loadFriendsCount();
    _loadAvatarImages();
  }

  String? userId;

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("uid");
    });
  }

  Future<void> _loadAvatarImages() async {
    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString("district");
    final uid = prefs.getString("uid");

    if (district == null || uid == null) return;

    try {
      final uri = Uri.parse(
        "https://api.inkaanalysis.com/api/ads/user/$uid/district/$district",
      );

      print("AVATAR API → $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List groups = decoded["groups"] ?? [];

        /// Collect profile images from groups
        List<String> imgs = [];

        for (final group in groups) {
          final members = group["members"] as List? ?? [];
          for (final member in members) {
            final img = member["profile_image"];
            if (img != null && img.toString().isNotEmpty) {
              imgs.add(img);
            }
          }
        }

        /// Take only first 4
        imgs = imgs.take(4).toList();

        /// Fill remaining slots with asset placeholder
        while (imgs.length < 4) {
          imgs.add("assets/images/profile_image.png");
        }

        setState(() {
          avatarImages = imgs;
        });

        print("AVATARS → $avatarImages");
      }
    } catch (e) {
      print("Avatar Error: $e");

      /// fallback – always show 4 empty avatars
      setState(() {
        avatarImages = List.filled(
          4,
          "asset://assets/images/profile_placeholder.png",
        );
      });
    }
  }

  void _loadFriendsCount() async {
    final friendsProvider = Provider.of<FriendsProvider>(
      context,
      listen: false,
    );
    await friendsProvider.fetchFriendsCount();

    setState(() {
      friendsCount = friendsProvider.friendsCount;
    });
  }

  Future<void> _loadProfile() async {
    final service = ProfileService();
    final fetchedUser = await service.fetchProfileDetails();

    if (!mounted) return;

    if (fetchedUser != null) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).saveFetchedProfile(fetchedUser);
      Provider.of<UserProvider>(context, listen: false).fetchMyStock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final name = user?.username ?? tr("profile.user");
    final district = user?.district ?? tr("profile.no_location");
    final profession = user?.profession ?? tr("profile.farmer");
    final imageUrl =
        user?.profileImageUrl ??
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2Fmore%2Ffarmers.png?alt=media&token=663f050d-24b2-43c5-9196-b43800a5a725';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DrawerMenu(),
      drawerEnableOpenDragGesture: false,
      body: CustomScrollView(
        slivers: [
          // ---------- SLIVER APP BAR ----------
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: MediaQuery.of(context).size.height * 0.30,
            backgroundColor: Colors.white,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  setState(() {
                    isbarcode = true;
                  });
                },
                child: ProfileHeader(
                  name: name,
                  location: district,
                  friends:
                      "$friendsCount ${tr("profile.friends_and_neighbors")}",
                  imageUrl: imageUrl,
                  isbarcode: false,
                ),
              ),
            ),
          ),

          // ---------- OVERLAY CONTENT USING STACK ----------
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -80), // ✅ move up safely
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(top: 20),
                child: (!isbarcode)
                    ? _buildMainContent(name, district)
                    : _buildBarcodeView(name, profession, district),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<NewsItem>> fetchNews() async {
    final url = Uri.parse(ApiConstants.newsList);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => NewsItem.fromJson(e)).toList();
    } else {
      throw Exception(tr("profile.no_news"));
    }
  }

  Widget _buildNewsSection() {
    return FutureBuilder<List<NewsItem>>(
      future: fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text(tr("profile.no_news"))),
          );
        }

        final list = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          //padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final n = list[i];

            return InkWell(
              onTap: () async {
                print('news tapped');
                final Uri link = Uri.parse(n.url);

                try {
                  bool launched = await launchUrl(link, mode: LaunchMode.externalApplication);
                  if (!launched) await launchUrl(link);
                } catch (e) {
                  debugPrint("Error launching url $link : $e");
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          n.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${tr("profile.published")}: ${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyStockSection() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.myStock.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tr("profile.no_stock_found"),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 6, left: 10, right: 10),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 30,
              mainAxisSpacing: 15,
            ),
            itemCount: provider.myStock.length,
            itemBuilder: (context, index) {
              final item = provider.myStock[index];

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Image.network(
                      item.productImageUrl,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    /*  Text(
                      item.landName,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),*/
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMainContent(String name, String district) {
    return Transform.translate(
      offset: const Offset(
        0,
        0,
      ), // 🔥 Moves the container up without margin error
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 8), // 🔥
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FriendsScreen()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OverlappingAvatars(
                          imageUrls: avatarImages,
                          radius: 25,
                          overlap: 30,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                district,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "$friendsCount ${tr("profile.friends_and_neighbors")}",
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildToggleButtons(),
                ],
              ),
            ),

            showNews ? _buildNewsSection() : _buildMyStockSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => setState(() => showNews = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: showNews
                    ? const Color(0xFF1E7A3F)
                    : Colors.grey[200],
                foregroundColor: showNews ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(tr("profile.news")),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => setState(() => showNews = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: !showNews
                    ? const Color(0xFF1E7A3F)
                    : Colors.grey[200],
                foregroundColor: !showNews ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(tr("profile.stock")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeView(String name, String profession, String district) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          profession,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(district, style: const TextStyle(fontSize: 15, height: 1.4)),
        const SizedBox(height: 20),
        Image.network(
          "${ApiConstants.baseUrl}/user/barcode/$userId",
          height: 220,
          width: 220,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
