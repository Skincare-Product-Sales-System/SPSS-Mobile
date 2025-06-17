class ReviewReply {
  final String id;
  final String? avatarUrl;
  final String userName;
  final String replyContent;
  final DateTime lastUpdatedTime;

  ReviewReply({
    required this.id,
    this.avatarUrl,
    required this.userName,
    required this.replyContent,
    required this.lastUpdatedTime,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'] ?? '',
      avatarUrl: json['avatarUrl'],
      userName: json['userName'] ?? '',
      replyContent: json['replyContent'] ?? '',
      lastUpdatedTime: DateTime.parse(json['lastUpdatedTime']),
    );
  }
}

class ReviewModel {
  final String id;
  final String userName;
  final String? avatarUrl;
  final List<String> reviewImages;
  final List<String> variationOptionValues;
  final int ratingValue;
  final String comment;
  final DateTime lastUpdatedTime;
  final ReviewReply? reply;

  ReviewModel({
    required this.id,
    required this.userName,
    this.avatarUrl,
    required this.reviewImages,
    required this.variationOptionValues,
    required this.ratingValue,
    required this.comment,
    required this.lastUpdatedTime,
    this.reply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      avatarUrl: json['avatarUrl'],
      reviewImages: List<String>.from(json['reviewImages'] ?? []),
      variationOptionValues: List<String>.from(
        json['variationOptionValues'] ?? [],
      ),
      ratingValue: json['ratingValue'] ?? 0,
      comment: json['comment'] ?? '',
      lastUpdatedTime: DateTime.parse(json['lastUpdatedTime']),
      reply: json['reply'] != null ? ReviewReply.fromJson(json['reply']) : null,
    );
  }
}

class ReviewResponse {
  final List<ReviewModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  ReviewResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      items:
          (json['items'] as List?)
              ?.map((item) => ReviewModel.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
