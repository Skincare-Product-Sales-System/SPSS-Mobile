class BrandModel {
  final String id;
  final String name;
  final String? title;
  final String? description;
  final String? imageUrl;
  final bool? isLiked;
  final String? country;
  final int? countryId;

  BrandModel({
    required this.id,
    required this.name,
    this.title,
    this.description,
    this.imageUrl,
    this.isLiked,
    this.country,
    this.countryId,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      isLiked: json['isLiked'],
      country: json['country'],
      countryId: json['countryId'],
    );
  }
}
