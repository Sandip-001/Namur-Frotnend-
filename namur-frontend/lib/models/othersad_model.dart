import 'package:the_namur_frontend/models/create_ad_model.dart';

class OtherAdModel {
  final int id;
  final String? adUid;
  final String title;

  final int categoryId;
  final int subCategoryId;
  final int productId;
  final String productName;

  final String? unit;
  final String quantity;
  final String price;

  final List<String> districts;
  final String description;

  final String adType;
  final String postType;
  final String? scheduledAt;
  final String expiryDate;

  final String? videoUrl;
  final List<AdImage> images;
  final Map<String, dynamic> extraFields;

  // Creator info
  final String? createdByRole;
  final int? creatorId;
  final String? creatorName;
  final String? creatorEmail;

  // User info
  final String? userMobile;
  final String? userDistrict;
  final String? userTaluk;
  final String? userVillage;
  final String? userPanchayat;
  final String? userProfileImage;

  // Status
  final String? status;
  final String? createdAt;

  // Category labels
  final String? categoryName;
  final String? subcategoryName;

  OtherAdModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.subCategoryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.districts,
    required this.description,
    required this.adType,
    required this.postType,
    required this.expiryDate,
    required this.images,
    required this.extraFields,
    this.unit,
    this.scheduledAt,
    this.videoUrl,
    this.createdByRole,
    this.creatorId,
    this.creatorName,
    this.creatorEmail,
    this.userMobile,
    this.userDistrict,
    this.userTaluk,
    this.userVillage,
    this.userPanchayat,
    this.userProfileImage,
    this.status,
    this.createdAt,
    this.adUid,
    this.categoryName,
    this.subcategoryName,
  });

  factory OtherAdModel.fromJson(Map<String, dynamic> json) {
    return OtherAdModel(
      id: json['id'] ?? 0,
      adUid: json['ad_uid'],
      title: json['title'] ?? "",

      categoryId: json['category_id'] ?? 0,
      subCategoryId: json['subcategory_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? "",

      unit: json['unit'],
      quantity: json['quantity']?.toString() ?? "",
      price: json['price']?.toString() ?? "",

      districts: List<String>.from(json['districts'] ?? []),
      description: json['description'] ?? "",

      adType: json['ad_type'] ?? "",
      postType: json['post_type'] ?? "",
      scheduledAt: json['scheduled_at'],
      expiryDate: json['expiry_date'] ?? "",

      videoUrl: json['video_url'] != null && json['video_url'].toString().isNotEmpty
          ? json['video_url']
          : "https://youtu.be/dQw4w9WgXcQ",

      images: (json['images'] as List?)
          ?.map((e) => AdImage.fromJson(e))
          .toList() ??
          [],

      extraFields:
      Map<String, dynamic>.from(json['extra_fields'] ?? {}),

      createdByRole: json['created_by_role'],
      creatorId: json['creator_id'],
      creatorName: json['creator_name'],
      creatorEmail: json['creator_email'],

      userMobile: json['user_mobile'],
      userDistrict: json['user_district'],
      userTaluk: json['user_taluk'],
      userVillage: json['user_village'],
      userPanchayat: json['user_panchayat'],
      userProfileImage: json['user_profile_image'],

      status: json['status'],
      createdAt: json['created_at'],

      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
    );
  }
}
