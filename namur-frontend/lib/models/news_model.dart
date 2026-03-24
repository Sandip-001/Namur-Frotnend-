class NewsItem {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final DateTime createdAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.createdAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}