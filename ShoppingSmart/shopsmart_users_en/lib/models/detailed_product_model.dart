
class DetailedProductModel {
  final String id;
  final String name;
  final String description;
  final int soldCount;
  final double rating;
  final int price;
  final int marketPrice;
  final String status;
  final String thumbnail;
  final List<String> skinTypes;
  final List<ProductItem> productItems;
  final Brand brand;
  final Category category;
  final Specifications specifications;

  DetailedProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.soldCount,
    required this.rating,
    required this.price,
    required this.marketPrice,
    required this.status,
    required this.thumbnail,
    required this.skinTypes,
    required this.productItems,
    required this.brand,
    required this.category,
    required this.specifications,
  });

  factory DetailedProductModel.fromJson(Map<String, dynamic> json) {
    return DetailedProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      soldCount: json['soldCount']?.toInt() ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      price: json['price']?.toInt() ?? 0,
      marketPrice: json['marketPrice']?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      skinTypes:
          (json['skinTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      productItems:
          (json['productItems'] as List<dynamic>?)
              ?.map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      brand: Brand.fromJson(json['brand'] as Map<String, dynamic>? ?? {}),
      category: Category.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
      specifications: Specifications.fromJson(
        json['specifications'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  String get formattedPrice {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get formattedMarketPrice {
    return marketPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double get discountPercentage {
    if (marketPrice <= price) return 0.0;
    return ((marketPrice - price) / marketPrice * 100);
  }
}

class ProductItem {
  final String id;
  final int quantityInStock;
  final String imageUrl;
  final int price;
  final int marketPrice;
  final List<Configuration> configurations;

  ProductItem({
    required this.id,
    required this.quantityInStock,
    required this.imageUrl,
    required this.price,
    required this.marketPrice,
    required this.configurations,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id']?.toString() ?? '',
      quantityInStock: json['quantityInStock']?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: json['price']?.toInt() ?? 0,
      marketPrice: json['marketPrice']?.toInt() ?? 0,
      configurations:
          (json['configurations'] as List<dynamic>?)
              ?.map((e) => Configuration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Configuration {
  final String variationName;
  final String optionName;
  final String optionId;

  Configuration({
    required this.variationName,
    required this.optionName,
    required this.optionId,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      variationName: json['variationName']?.toString() ?? '',
      optionName: json['optionName']?.toString() ?? '',
      optionId: json['optionId']?.toString() ?? '',
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String title;
  final String description;
  final String imageUrl;
  final bool? isLiked;
  final String? country;
  final int countryId;

  Brand({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isLiked,
    this.country,
    required this.countryId,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isLiked: json['isLiked'],
      country: json['country']?.toString(),
      countryId: json['countryId']?.toInt() ?? 0,
    );
  }
}

class Category {
  final String id;
  final String categoryName;
  final List<dynamic> children;

  Category({
    required this.id,
    required this.categoryName,
    required this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      children: json['children'] as List<dynamic>? ?? [],
    );
  }
}

class Specifications {
  final String detailedIngredients;
  final String mainFunction;
  final String texture;
  final String? englishName;
  final String keyActiveIngredients;
  final String storageInstruction;
  final String usageInstruction;
  final String expiryDate;
  final String skinIssues;

  Specifications({
    required this.detailedIngredients,
    required this.mainFunction,
    required this.texture,
    this.englishName,
    required this.keyActiveIngredients,
    required this.storageInstruction,
    required this.usageInstruction,
    required this.expiryDate,
    required this.skinIssues,
  });

  factory Specifications.fromJson(Map<String, dynamic> json) {
    return Specifications(
      detailedIngredients: json['detailedIngredients']?.toString() ?? '',
      mainFunction: json['mainFunction']?.toString() ?? '',
      texture: json['texture']?.toString() ?? '',
      englishName: json['englishName']?.toString(),
      keyActiveIngredients: json['keyActiveIngredients']?.toString() ?? '',
      storageInstruction: json['storageInstruction']?.toString() ?? '',
      usageInstruction: json['usageInstruction']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      skinIssues: json['skinIssues']?.toString() ?? '',
    );
  }
}
