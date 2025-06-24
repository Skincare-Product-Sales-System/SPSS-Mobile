import 'review_models.dart';

class UserReviewModel extends ReviewModel {
  UserReviewModel({
    required super.id,
    required super.userName,
    super.avatarUrl,
    required super.reviewImages,
    required super.variationOptionValues,
    required super.ratingValue,
    required super.comment,
    required super.lastUpdatedTime,
    super.reply,
    super.productImage = '',
    super.productId = '',
    super.productName = '',
    super.isEditble = false,
  });

  // Getters to ensure non-null values with defaults
  String get productImageSafe => productImage ?? '';
  String get productIdSafe => productId ?? '';
  String get productNameSafe => productName ?? '';
  bool get isEditbleSafe => isEditble ?? false;

  factory UserReviewModel.fromJson(Map<String, dynamic> json) {
    return UserReviewModel(
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
      productImage: json['productImage'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      isEditble: json['isEditble'] ?? false,
    );
  }

  // Create a copy of this model with updated fields
  UserReviewModel copyWith({
    String? id,
    String? userName,
    String? avatarUrl,
    List<String>? reviewImages,
    List<String>? variationOptionValues,
    int? ratingValue,
    String? comment,
    DateTime? lastUpdatedTime,
    ReviewReply? reply,
    String? productImage,
    String? productId,
    String? productName,
    bool? isEditble,
  }) {
    return UserReviewModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      reviewImages: reviewImages ?? this.reviewImages,
      variationOptionValues:
          variationOptionValues ?? this.variationOptionValues,
      ratingValue: ratingValue ?? this.ratingValue,
      comment: comment ?? this.comment,
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
      reply: reply ?? this.reply,
      productImage: productImage ?? this.productImage,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      isEditble: isEditble ?? this.isEditble,
    );
  }
}

class UserReviewResponse {
  final List<UserReviewModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  UserReviewResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory UserReviewResponse.fromJson(Map<String, dynamic> json) {
    return UserReviewResponse(
      items:
          (json['items'] as List?)
              ?.map((item) => UserReviewModel.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
