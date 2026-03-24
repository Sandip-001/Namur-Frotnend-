class ProductModel {
  final int id;
  final String name;
  final String imageUrl;
  final String imagePublicId;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final List<String> breeds;
  final String createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imagePublicId,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.breeds,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      imagePublicId: json['image_public_id'] ?? "",
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      subCategoryId: json['subcategory_id'],
      subCategoryName: json['subcategory_name'],
      breeds: List<String>.from(json['breeds'] ?? []),
      createdAt: json['created_at'] ?? "",
    );
  }
}
