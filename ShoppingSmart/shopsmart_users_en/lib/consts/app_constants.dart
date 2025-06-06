// import 'package:shopsmart_users_en/services/assets_manager.dart';

import 'package:shopsmart_users_en/models/categories_model.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';

class AppConstants {
  static const String imageUrl =
      "https://images.unsplash.com/photo-1465572089651-8fde36c892dd?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";

  static const List<String> bannersImage = [
    'assets/images/banners/banner1.jpg',
    'assets/images/banners/banner2.jpg',
  ];

  static List<CategoriesModel> categoriesList = [
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Phones",
      image: AssetsManager.mobiles,
    ),
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Phones",
      image: AssetsManager.mobiles,
    ),
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Phones",
      image: AssetsManager.mobiles,
    ),
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Phones",
      image: AssetsManager.mobiles,
    ),
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Cosmetics",
      image: AssetsManager.cosmetics,
    ),
    CategoriesModel(
      id: AssetsManager.mobiles,
      name: "Phones",
      image: AssetsManager.electronics,
    ),
  ];
}
