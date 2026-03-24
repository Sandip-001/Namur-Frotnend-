import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../Widgets/whatsapp_fab.dart';
import '../models/othersad_model.dart';
import '../seller_profile_screen.dart';
import '../utils/api_url.dart';
import 'machinery_description_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtherDescriptionScreen extends StatefulWidget {
  final OtherAdModel ad;
  const OtherDescriptionScreen({super.key, required this.ad});

  @override
  State<OtherDescriptionScreen> createState() => _OtherDescriptionScreenState();
}

class _OtherDescriptionScreenState extends State<OtherDescriptionScreen> {
  double userRating = 0.0;
  int activeIndex = 0;
  bool isFav = false;
  String displayLocation = "";
  late OtherAdModel ad;
  @override
  void initState() {
    super.initState();
    ad = widget.ad;
    fetchWishlistStatus(); // 👈 PREFILL HEART
    displayLocation = _buildLocation(ad);
  }

  String _buildLocation(OtherAdModel ad) {
    print('user location');
    print(ad.userVillage);
    print(ad.userTaluk);
    print(ad.userDistrict);
    final rawParts = [ad.userTaluk, ad.userVillage, ad.userDistrict];

    final validParts = rawParts.map((e) => e?.trim() ?? "").where((e) {
      // ignore empty or placeholder values
      if (e.isEmpty) return false;
      final lower = e.toLowerCase();
      return !(["null", "dist", "taluk", "village"].contains(lower));
    }).toList();

    return validParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final images = ad.images.map((e) => e.url).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff107B28),
        elevation: 0,
        centerTitle: true,
        title: Text(
          ad.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareAd();
            },
            tooltip: "Share",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ------------------ CAROUSEL WITH IMAGES ------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildCarousel(),
              ),
              const SizedBox(height: 8),

              /// ---------------------- TITLE + PRICE ----------------------
              const SizedBox(height: 10),
              // 🔹 Title (Auto-wrapping)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    ad.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),

              const SizedBox(height: 8),

              /// ------------------ RATING BOX ------------------
              /*Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(243, 206, 13, 0.56),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "rate_product".tr(),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 26,
                      itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                      unratedColor: Colors.grey.shade400,
                      onRatingUpdate: (rating) {
                        setState(() => userRating = rating);
                      },
                    ),
                  ],
                ),
              ),*/
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InfoBox(
                        label: "Breed",
                        value: "${ad.extraFields.values}",
                        bgColor: const Color.fromRGBO(243, 13, 13, 0.23),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InfoBox(
                        label: "rating_label".tr(),
                        value: "",
                        bgColor: const Color.fromRGBO(243, 206, 13, 0.56),
                        child: RatingBar.builder(
                          initialRating: userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 17,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          unratedColor: Colors.white,
                          onRatingUpdate: (rating) {
                            userRating = rating;
                            // call setState if needed
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InfoBox(
                        label: "Price",
                        value: "₹${ad.price}${ad.unit != null ? ' / ${ad.unit}' : ''}",
                        bgColor: const Color.fromRGBO(238, 13, 243, 0.41),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              /// ------------------ OWNER SECTION ------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 240, 10, 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerProfileScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (ad.userProfileImage != null)
                                ? NetworkImage(ad.userProfileImage!)
                                : const AssetImage(
                                    'assets/images/profile_image.png',
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.creatorName ?? "unknown".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              displayLocation,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WhatsAppButton(
                        phoneNumber:
                            (ad.userMobile != null && ad.userMobile!.isNotEmpty)
                            ? ad.userMobile!
                            : '9945278914',
                        message: 'whatsapp_message'.tr(),
                        imagePath: 'assets/images/whatsapp.png',
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// ------------------ DESCRIPTION ------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(232, 229, 229, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "description".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // matching size
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _truncateWords(ad.description, 1000),
                      style: TextStyle(
                        fontSize: 15, // matching size
                        height: 1.4,
                        color: Colors.black, // matching color of title
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateWords(String text, int wordLimit) {
    final words = text.split(RegExp(r'\s+')); // split by spaces/newlines
    if (words.length <= wordLimit) return text;
    return '${words.sublist(0, wordLimit).join(' ')}...';
  }

  Future<void> _shareAd() async {
    final ad = widget.ad;

    final String shareUrl = "https://api.inkaanalysis.com/ad/${ad.adUid}";
    final String message = "Check out this ${ad.title} on Namur!\n$shareUrl";

    if (ad.images.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(ad.images[0].url));
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/share_image.png';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(path)], text: message);
      } catch (e) {
        Share.share(message);
      }
    } else {
      Share.share(message);
    }
  }

  Future<void> fetchWishlistStatus() async {
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

        final List wishlist = decoded['data'] ?? [];

        final alreadyWishlisted = wishlist.any(
          (item) => item['ad_uid'] == widget.ad.adUid,
        );

        setState(() {
          isFav = alreadyWishlisted;
        });
      }
    } catch (e) {
      debugPrint("Wishlist fetch error: $e");
    }
  }

  /// ------------------ CAROUSEL: IMAGES ONLY ------------------
  Widget buildCarousel() {
    final ad = widget.ad;
    List<Widget> carouselItems = [];

    for (var img in ad.images) {
      carouselItems.add(
        GestureDetector(
          onTap: () => openImageViewer(img.url ?? ""),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                img.url ?? "",
                width: double.infinity,
                fit: BoxFit.cover,

                // ✅ downgrade image resolution for carousel
                cacheWidth: 600,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    if (ad.videoUrl != null && ad.videoUrl!.isNotEmpty) {
      final youtubeThumb = getYoutubeThumbnail(ad.videoUrl!);
      carouselItems.add(
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(ad.videoUrl!);
            try {
              // Direct launch attempt
              bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched) {
                // Fallback to internal/platform default if external fails
                await launchUrl(uri);
              }
            } catch (e) {
              debugPrint('Could not launch YouTube URL: $e');
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  if (youtubeThumb != null)
                    Image.network(
                      youtubeThumb,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else
                    Container(
                      color: Colors.black12,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  const Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (carouselItems.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Text("no_image".tr()),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: carouselItems,
          options: CarouselOptions(
            height: 200,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() => activeIndex = index);
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "AD-${ad.id}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(carouselItems.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeIndex == index
                          ? Colors.green
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: Material(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => toggleWishlist(ad.id.toString()),
                    child: Center(
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        size: 30,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  String? getYoutubeThumbnail(String url) {
    try {
      if (url.contains("youtu.be/")) {
        final id = url.split("youtu.be/")[1];
        return "https://img.youtube.com/vi/$id/0.jpg";
      }

      if (url.contains("v=")) {
        final id = url.split("v=")[1].split("&").first;
        return "https://img.youtube.com/vi/$id/0.jpg";
      }
    } catch (_) {}
    return null;
  }

  Future<void> toggleWishlist(String adId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid"); // replace with logged in user id

    if (!isFav) {
      // Add to wishlist
      final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/add');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "ad_id": adId}),
      );
      print("====Add wish list===");
      print(url);
      print(jsonEncode({"user_id": userId, "ad_id": adId}));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() => isFav = true);
        /*     if (data['success'] == true) {
          setState(() => isFav = true);
        } else {
          // show message from response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Failed to add to wishlist")),
          );
        }*/
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, try again later")),
        );
      }
    } else {
      // Remove from wishlist
      final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/remove');
      final response = await http.delete(
        url, // some APIs may use DELETE, here your API uses POST
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "ad_id": adId}),
      );
      print("====remove wish list===");
      print(url);
      print(jsonEncode({"user_id": userId, "ad_id": adId}));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isFav = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, try again later")),
        );
      }
    }
  }

  void openImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              /// ZOOMABLE IMAGE
              Center(
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                ),
              ),

              /// CLOSE BUTTON
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
