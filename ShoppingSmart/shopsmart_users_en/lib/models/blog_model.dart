
class BlogModel {
  final String id;
  final String title;
  final String thumbnail;
  final String description;
  final String author;
  final DateTime lastUpdatedAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.author,
    required this.lastUpdatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      lastUpdatedAt:
          DateTime.tryParse(json['lastUpdatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get formattedDate {
    return "${lastUpdatedAt.day}/${lastUpdatedAt.month}/${lastUpdatedAt.year}";
  }
}

class DetailedBlogModel {
  final String id;
  final String title;
  final String thumbnail;
  final String description;
  final String author;
  final DateTime lastUpdatedAt;
  final List<BlogSection> sections;

  DetailedBlogModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.author,
    required this.lastUpdatedAt,
    required this.sections,
  });

  factory DetailedBlogModel.fromJson(Map<String, dynamic> json) {
    return DetailedBlogModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      lastUpdatedAt:
          DateTime.tryParse(json['lastUpdatedAt']?.toString() ?? '') ??
          DateTime.now(),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => BlogSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedDate {
    return "${lastUpdatedAt.day}/${lastUpdatedAt.month}/${lastUpdatedAt.year}";
  }
}

class BlogSection {
  final String contentType;
  final String subtitle;
  final String content;
  final int order;

  BlogSection({
    required this.contentType,
    required this.subtitle,
    required this.content,
    required this.order,
  });

  factory BlogSection.fromJson(Map<String, dynamic> json) {
    return BlogSection(
      contentType: json['contentType']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      order: json['order']?.toInt() ?? 0,
    );
  }
}
