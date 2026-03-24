class PendingAd {
  String title;
  String categoryId;
  String subCategoryId;
  String productId;
  String productName;
  String quantity;
  String price;
  String description;
  String? brand;
  String? model;
  String? manufactureYear;
  String? registrationNo;
  String? prevOwners;
  String? drivenHours;
  String? kmsCovered;
  List<String> images;

  PendingAd({
    required this.title,
    required this.categoryId,
    required this.subCategoryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.description,
    this.brand,
    this.model,
    this.manufactureYear,
    this.registrationNo,
    this.prevOwners,
    this.drivenHours,
    this.kmsCovered,
    required this.images,
  });
}
