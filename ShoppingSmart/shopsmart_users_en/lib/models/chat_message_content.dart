import 'dart:convert';

// Base class for all message contents
abstract class MessageContent {
  final String type;

  MessageContent({required this.type});

  Map<String, dynamic> toJson();

  static MessageContent fromJson(Map<String, dynamic> json) {
    final type = json['type'];

    switch (type) {
      case 'text':
        return TextMessage.fromJson(json);
      case 'image':
        return ImageMessage.fromJson(json);
      case 'product':
        return ProductMessage.fromJson(json);
      default:
        return TextMessage(content: json.toString());
    }
  }

  static MessageContent fromString(String content) {
    try {
      final json = jsonDecode(content);
      if (json is Map<String, dynamic> && json.containsKey('type')) {
        return MessageContent.fromJson(json);
      } else {
        return TextMessage(content: content);
      }
    } catch (e) {
      // If not a valid JSON, treat as plain text
      return TextMessage(content: content);
    }
  }
}

// Text message content
class TextMessage extends MessageContent {
  final String content;

  TextMessage({required this.content}) : super(type: 'text');

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'content': content};
  }

  factory TextMessage.fromJson(Map<String, dynamic> json) {
    return TextMessage(content: json['content'] ?? '');
  }

  @override
  String toString() {
    return content;
  }
}

// Image message content
class ImageMessage extends MessageContent {
  final String url;

  ImageMessage({required this.url}) : super(type: 'image');

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'url': url};
  }

  factory ImageMessage.fromJson(Map<String, dynamic> json) {
    return ImageMessage(url: json['url'] ?? '');
  }

  @override
  String toString() {
    return '[Hình ảnh]';
  }
}

// Product message content
class ProductMessage extends MessageContent {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final int soldCount;
  final String url;

  ProductMessage({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.soldCount,
    required this.url,
  }) : super(type: 'product');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'rating': rating,
      'soldCount': soldCount,
      'url': url,
    };
  }

  factory ProductMessage.fromJson(Map<String, dynamic> json) {
    return ProductMessage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 4.5).toDouble(),
      soldCount: json['soldCount'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  @override
  String toString() {
    return '[Sản phẩm]';
  }
}
