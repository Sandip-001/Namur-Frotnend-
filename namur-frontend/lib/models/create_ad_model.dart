class AdImage {
  final String url;
  final String publicId;

  AdImage({required this.url, required this.publicId});

  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      url: json["url"] ?? "",
      publicId: json["public_id"] ?? "",
    );
  }

  void operator [](String other) {}
}

class AdData {
  final int id;
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
  final List<AdImage> images;
  final String createdByRole;
  final int creatorId;
  final Map<String, dynamic> extraFields;
  final String status;
  final String createdAt;

  // 🔥 Newly added fields
  final String? adUid;
  final String? creatorName;
  final String? creatorEmail;
  final String? userMobile;
  final String? userDistrict;
  final String? userTaluk;
  final String? userVillage;
  final String? userPanchayat;
  final String? userProfileImage;

  final String? subadminNumber;
  final String? subadminAddress;
  final List<String>? subadminDistricts;
  final String? subadminImage;

  final String? adminName;
  final String? adminEmail;

  AdData({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.subCategoryId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.districts,
    required this.description,
    required this.adType,
    required this.postType,
    required this.scheduledAt,
    required this.expiryDate,
    required this.images,
    required this.createdByRole,
    required this.creatorId,
    required this.extraFields,
    required this.status,
    required this.createdAt,

    // Added
    this.adUid,
    this.creatorName,
    this.creatorEmail,
    this.userMobile,
    this.userDistrict,
    this.userTaluk,
    this.userVillage,
    this.userPanchayat,
    this.userProfileImage,
    this.subadminNumber,
    this.subadminAddress,
    this.subadminDistricts,
    this.subadminImage,
    this.adminName,
    this.adminEmail,
  });

  factory AdData.fromJson(Map<String, dynamic> json) {
    return AdData(
      id: json["id"],
      title: json["title"],
      categoryId: json["category_id"],
      subCategoryId: json["subcategory_id"],
      productId: json["product_id"],
      productName: json["product_name"],
      unit: json["unit"],
      quantity: json["quantity"].toString(),
      price: json["price"].toString(),
      districts: List<String>.from(json["districts"] ?? []),
      description: json["description"],
      adType: json["ad_type"],
      postType: json["post_type"],
      scheduledAt: json["scheduled_at"],
      expiryDate: json["expiry_date"],
      images: (json["images"] as List)
          .map((e) => AdImage.fromJson(e))
          .toList(),
      createdByRole: json["created_by_role"],
      creatorId: json["creator_id"],
      extraFields: json["extra_fields"] ?? {},
      status: json["status"],
      createdAt: json["created_at"],

      // Added fields
      adUid: json["ad_uid"],
      creatorName: json["creator_name"],
      creatorEmail: json["creator_email"],
      userMobile: json["user_mobile"],
      userDistrict: json["user_district"],
      userTaluk: json["user_taluk"],
      userVillage: json["user_village"],
      userPanchayat: json["user_panchayat"],
      userProfileImage: json["user_profile_image"],

      subadminNumber: json["subadmin_number"],
      subadminAddress: json["subadmin_address"],
      subadminDistricts: json["subadmin_districts"] != null
          ? List<String>.from(json["subadmin_districts"])
          : null,
      subadminImage: json["subadmin_image"],

      adminName: json["admin_name"],
      adminEmail: json["admin_email"],
    );
  }
}
