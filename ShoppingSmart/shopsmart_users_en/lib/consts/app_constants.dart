// import 'package:shopsmart_users_en/services/assets_manager.dart';

import 'package:shopsmart_users_en/models/categories_model.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';

class AppConstants {
  static const String imageUrl =
      "https://images.unsplash.com/photo-1465572089651-8fde36c892dd?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";

  static final List<String> bannersImage = [
    AssetsManager.bannerImage1,
    AssetsManager.bannerImage2,
    AssetsManager.bannerImage3,
  ];

  static List<CategoriesModel> categoriesList = [
    CategoriesModel(
      id: "mobiles",
      name: "Điện thoại",
      image: AssetsManager.mobiles,
    ),
    CategoriesModel(
      id: "fashion",
      name: "Thời trang",
      image: AssetsManager.fashion,
    ),
    CategoriesModel(id: "watches", name: "Đồng hồ", image: AssetsManager.watch),
    CategoriesModel(id: "books", name: "Sách", image: AssetsManager.book),
    CategoriesModel(
      id: "cosmetics",
      name: "Mỹ phẩm",
      image: AssetsManager.cosmetics,
    ),
    CategoriesModel(
      id: "electronics",
      name: "Điện tử",
      image: AssetsManager.electronics,
    ),
    CategoriesModel(id: "shoes", name: "Giày dép", image: AssetsManager.shoes),
    CategoriesModel(id: "computers", name: "Máy tính", image: AssetsManager.pc),
  ];
}
