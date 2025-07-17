class ProductImage {
  final String id;
  final String url;

  ProductImage({required this.id, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(id: json['id'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url};
  }
}
