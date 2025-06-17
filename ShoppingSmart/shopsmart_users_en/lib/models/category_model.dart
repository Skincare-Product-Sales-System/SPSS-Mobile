import 'package:flutter/material.dart';

class CategoryModel with ChangeNotifier {
  final String id;
  final String categoryName;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (child) =>
                    CategoryModel.fromJson(child as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Helper method to check if category has children
  bool get hasChildren => children.isNotEmpty;

  // Helper method to get all subcategory IDs (including nested)
  List<String> getAllCategoryIds() {
    List<String> ids = [id];
    for (var child in children) {
      ids.addAll(child.getAllCategoryIds());
    }
    return ids;
  }

  // Helper method to flatten all categories (parent + children)
  List<CategoryModel> getAllCategories() {
    List<CategoryModel> categories = [this];
    for (var child in children) {
      categories.addAll(child.getAllCategories());
    }
    return categories;
  }
}
