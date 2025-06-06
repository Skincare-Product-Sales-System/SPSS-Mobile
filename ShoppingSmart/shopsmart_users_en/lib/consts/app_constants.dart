// import 'package:shopsmart_users_en/services/assets_manager.dart';

import 'package:shopsmart_users_en/models/categories_model.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';

class AppConstants {
  static const String imageUrl =
      "https://images.unsplash.com/photo-1465572089651-8fde36c892dd?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";

  static const List<String> bannersImage = [
    'https://images.pexels.com/photos/3785803/pexels-photo-3785803.jpeg',
    'https://images.pexels.com/photos/3762879/pexels-photo-3762879.jpeg',
    'https://images.pexels.com/photos/6663368/pexels-photo-6663368.jpeg',
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
