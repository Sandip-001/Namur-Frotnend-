class LandProductModel {
  final String message;
  final LandItem product;

  LandProductModel({
    required this.message,
    required this.product,
  });

  factory LandProductModel.fromJson(Map<String, dynamic> json) {
    return LandProductModel(
      message: json["message"] ?? "",
      product: LandItem.fromJson(json["product"]),
    );
  }
}

class LandItem {
  final int id;
  final int userId;
  final int landId;
  final int productId;
  final String category;
  final String? acres;
  final String? modelNo;
  final String? registrationNo;
  final String? chassiNo;
  final String? rcCopyNo;
  final int? quantity;
  final String productName;
  final String productImageUrl;
  final String landName;

  LandItem({
    required this.id,
    required this.userId,
    required this.landId,
    required this.productId,
    required this.category,
    this.acres,
    this.modelNo,
    this.registrationNo,
    this.chassiNo,
    this.rcCopyNo,
    this.quantity,
    required this.productName,
    required this.productImageUrl,
    required this.landName,
  });

  factory LandItem.fromJson(Map<String, dynamic> json) {
    return LandItem(
      id: json["id"],
      userId: json["user_id"],
      landId: json["land_id"],
      productId: json["product_id"],
      category: json["category"] ?? "",
      acres: json["acres"],
      modelNo: json["model_no"],
      registrationNo: json["registration_no"],
      chassiNo: json["chassi_no"],
      rcCopyNo: json["rc_copy_no"],
      quantity: json["quantity"],
      productName: json["product_name"] ?? "",
      productImageUrl: json["product_image_url"] ?? "",
      landName: json["land_name"] ?? "",
    );
  }
}

