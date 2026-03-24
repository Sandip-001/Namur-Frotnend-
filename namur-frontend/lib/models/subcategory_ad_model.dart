class SubCategoryAdItem {
  final int id;
  final String title;
  final String image;
  final String price;
  final String unit;
  final String breed;

  SubCategoryAdItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.unit,
    required this.breed,
  });

  factory SubCategoryAdItem.fromJson(Map<String, dynamic> json) {
    return SubCategoryAdItem(
      id: json['id'],
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      unit: json['unit'] ?? '',
      breed: json['extra_fields']?['breed'] ?? '',
      image: (json['images'] != null && json['images'].isNotEmpty)
          ? json['images'][0]['url']
          : '',
    );
  }
}
