import 'package:flutter/foundation.dart';

class SkinCondition {
  final double acneScore;
  final double wrinkleScore;
  final double darkCircleScore;
  final double darkSpotScore;
  final double healthScore;
  final String skinType;

  SkinCondition({
    required this.acneScore,
    required this.wrinkleScore,
    required this.darkCircleScore,
    required this.darkSpotScore,
    required this.healthScore,
    required this.skinType,
  });

  factory SkinCondition.fromJson(Map<String, dynamic> json) {
    return SkinCondition(
      acneScore: json['acneScore']?.toDouble() ?? 0.0,
      wrinkleScore: json['wrinkleScore']?.toDouble() ?? 0.0,
      darkCircleScore: json['darkCircleScore']?.toDouble() ?? 0.0,
      darkSpotScore: json['darkSpotScore']?.toDouble() ?? 0.0,
      healthScore: json['healthScore']?.toDouble() ?? 0.0,
      skinType: json['skinType'] ?? '',
    );
  }
}

class SkinIssue {
  final String issueName;
  final String description;
  final int severity;

  SkinIssue({
    required this.issueName,
    required this.description,
    required this.severity,
  });

  factory SkinIssue.fromJson(Map<String, dynamic> json) {
    return SkinIssue(
      issueName: json['issueName'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 0,
    );
  }
}

class RecommendedProduct {
  final String productId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String recommendationReason;
  final int priorityScore;

  RecommendedProduct({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.recommendationReason,
    required this.priorityScore,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      recommendationReason: json['recommendationReason'] ?? '',
      priorityScore: json['priorityScore'] ?? 0,
    );
  }
}

class SkinAnalysisResult {
  final String imageUrl;
  final SkinCondition skinCondition;
  final List<SkinIssue> skinIssues;
  final List<RecommendedProduct> recommendedProducts;
  final List<String> skinCareAdvice;

  SkinAnalysisResult({
    required this.imageUrl,
    required this.skinCondition,
    required this.skinIssues,
    required this.recommendedProducts,
    required this.skinCareAdvice,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      imageUrl: json['imageUrl'] ?? '',
      skinCondition: SkinCondition.fromJson(json['skinCondition'] ?? {}),
      skinIssues:
          (json['skinIssues'] as List<dynamic>?)
              ?.map((issue) => SkinIssue.fromJson(issue))
              .toList() ??
          [],
      recommendedProducts:
          (json['recommendedProducts'] as List<dynamic>?)
              ?.map((product) => RecommendedProduct.fromJson(product))
              .toList() ??
          [],
      skinCareAdvice:
          (json['skinCareAdvice'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
