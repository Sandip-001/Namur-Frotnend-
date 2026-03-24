import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../utils/api_url.dart';

// Wishlist Item Model
class WishlistItem {
  final int id; // 👈 added
  final String adUid;
  final String title;
  final String unit;
  final String quantity;
  final String price;
  final String imageUrl;

  WishlistItem({
    required this.id,
    required this.adUid,
    required this.title,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? 0, // 👈 mapping API id
      adUid: json['ad_uid'] ?? '',
      title: json['title'] ?? json['product_name'] ?? '',
      unit: json['unit'] ?? '1 Kg',
      quantity: json['quantity'] ?? '1',
      price: json['price'] ?? '0',
      imageUrl:
          (json['images'] != null &&
              json['images'] is List &&
              (json['images'] as List).isNotEmpty)
          ? json['images'][0]['url']
          : '',
    );
  }
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistItem> wishlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  // Fetch wishlist from API
  Future<void> fetchWishlist() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");
    if (userId == null) return;

    final url = Uri.parse(
      'https://api.inkaanalysis.com/api/wishlist/user/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];

        setState(() {
          wishlist = data.map((item) => WishlistItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint(
          'Failed to load wishlist. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Wishlist fetch error: $e");
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(int wishlistId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("uid");
      if (userId == null) return;

      final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/remove');

      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "ad_id": wishlistId, // ✅ wishlist id, backend expects this
        }),
      );

      debugPrint("REMOVE WISHLIST PAYLOAD:");
      debugPrint(jsonEncode({"user_id": userId, "ad_id": wishlistId}));

      if (response.statusCode == 200) {
        fetchWishlist();
      } else {
        debugPrint(
          'Failed to remove wishlist → ${response.statusCode} | ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("Remove wishlist error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DrawerMenu(),
      appBar: const CustomAppBar(title: 'My Wishlist'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlist.isEmpty
          ? const Center(child: Text("No items in wishlist"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final item = wishlist[index];

                return GestureDetector(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              width: 100,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item.unit,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '20% Off',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Rs.${item.price}/${item.unit}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        removeFromWishlist(item.id);
                                      },
                                    ),
                                  ],
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
            ),
    );
  }
}
