import 'create_ad_model.dart';

class MachineryAdModel {
  final int id;
  final String title;
  final int? categoryId;
  final int? subCategoryId;
  final int? productId;
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
  final List<AdImage> images;
  final String? videoUrl;

  final String? adUid;

  final String createdByRole;
  final int? creatorId;
  final ExtraFields? extraFields;
  final String status;
  final String createdAt;
  final String categoryName;
  final String subcategoryName;
  final String creatorName;
  final String creatorEmail;
  final String userMobile;
  final String userDistrict;
  final String? userTaluk;
  final String? userVillage;
  final String? userPanchayat;
  final String? userProfileImage;

  MachineryAdModel({
    required this.id,
    required this.title,
    this.categoryId,
    this.subCategoryId,
    this.productId,
    required this.productName,
    this.unit,
    required this.quantity,
    required this.price,
    required this.districts,
    required this.description,
    required this.adType,
    required this.postType,
    this.scheduledAt,
    required this.expiryDate,
    required this.images,
    this.videoUrl,
    this.adUid,
    required this.createdByRole,
    this.creatorId,
    this.extraFields,
    required this.status,
    required this.createdAt,
    required this.categoryName,
    required this.subcategoryName,
    required this.creatorName,
    required this.creatorEmail,
    required this.userMobile,
    required this.userDistrict,
    this.userTaluk,
    this.userVillage,
    this.userPanchayat,
    this.userProfileImage,
  });

  factory MachineryAdModel.fromJson(Map<String, dynamic> json) {
    return MachineryAdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryId: json['category_id'],
      subCategoryId: json['subcategory_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      unit: json['unit'] as String?,
      quantity: json['quantity']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      districts: List<String>.from(json['districts'] ?? []),
      description: json['description'] ?? '',
      adType: json['ad_type'] ?? '',
      postType: json['post_type'] ?? '',
      scheduledAt: json['scheduled_at'] as String?,
      expiryDate: json['expiry_date'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((e) => AdImage.fromJson(e))
          .toList(),
      videoUrl: json['video_url'] ?? json['youtube_url'] ?? "https://youtu.be/dQw4w9WgXcQ",
      adUid: json['ad_uid'] as String?,
      createdByRole: json['created_by_role'] ?? '',
      creatorId: json['creator_id'],
      extraFields: json['extra_fields'] != null
          ? ExtraFields.fromJson(json['extra_fields'])
          : null,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryName: json['category_name'] ?? '',
      subcategoryName: json['subcategory_name'] ?? '',
      creatorName: json['creator_name'] ?? '',
      creatorEmail: json['creator_email'] ?? '',
      userMobile: json['user_mobile'] ?? '',
      userDistrict: json['user_district'] ?? '',
      userTaluk: json['user_taluk'] as String?,
      userVillage: json['user_village'] as String?,
      userPanchayat: json['user_panchayat'] as String?,
      userProfileImage: json['user_profile_image'] as String?,
    );
  }
  factory MachineryAdModel.fromBookingAdJson(Map<String, dynamic> json) {
    return MachineryAdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      productName: json['title'] ?? '', // fallback
      quantity: json['quantity']?.toString() ?? '',
      price: json['price']?.toString() ?? '',

      images: (json['images'] as List? ?? [])
          .map((e) => AdImage.fromJson(e))
          .toList(),

      adUid: json['ad_uid'],
      videoUrl: json['video_url'] ?? json['youtube_url'] ?? "https://youtu.be/dQw4w9WgXcQ",

      // 🔻 SAFE DEFAULTS FOR MISSING FIELDS
      categoryId: null,
      subCategoryId: null,
      productId: null,
      unit: null,
      districts: [],
      description: '',
      adType: json['ad_type'] ?? 'Rent',
      postType: '',
      scheduledAt: null,
      expiryDate: '',
      createdByRole: '',
      creatorId: null,
      extraFields: null,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryName: '',
      subcategoryName: '',
      creatorName: '',
      creatorEmail: '',
      userMobile: '',
      userDistrict: '',
      userTaluk: null,
      userVillage: null,
      userPanchayat: null,
      userProfileImage: null,
    );
  }
}

class ExtraFields {
  final String brand;
  final String model;
  final String fcValue;
  final String? condition;
  final int kmsCovered;
  final int prevOwners;
  final int drivenHours;
  final String registrationNo;
  final int manufactureYear;
  final String insuranceRunning;

  ExtraFields({
    required this.brand,
    required this.model,
    required this.fcValue,
    this.condition,
    required this.kmsCovered,
    required this.prevOwners,
    required this.drivenHours,
    required this.registrationNo,
    required this.manufactureYear,
    required this.insuranceRunning,
  });

  factory ExtraFields.fromJson(Map<String, dynamic> json) {
    return ExtraFields(
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      fcValue: json['fc_value']?.toString() ?? '',
      condition: json['condition']?.toString(),

      kmsCovered: int.tryParse(json['kms_covered']?.toString() ?? '') ?? 0,
      prevOwners: int.tryParse(json['prev_owners']?.toString() ?? '') ?? 0,
      drivenHours: int.tryParse(json['driven_hours']?.toString() ?? '') ?? 0,

      registrationNo: json['registration_no']?.toString() ?? '',
      manufactureYear:
          int.tryParse(json['manufacture_year']?.toString() ?? '') ?? 0,

      insuranceRunning: json['insurance_running']?.toString() ?? '',
    );
  }
}
