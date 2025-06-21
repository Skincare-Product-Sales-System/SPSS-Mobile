import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/wishlist_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class WishlistRepository {
  // Local storage for wishlist items until backend API is available
  static final Map<String, WishlistModel> _localWishlist = {};
  static const String _wishlistKey = 'user_wishlist_items';

  // Load wishlist from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(_wishlistKey);

      if (wishlistJson != null) {
        final List<dynamic> items = jsonDecode(wishlistJson);
        _localWishlist.clear();

        for (var item in items) {
          final wishlistItem = {
            'wishlistId': item['wishlistId'],
            'productId': item['productId'],
          };
          final model = WishlistModel(
            wishlistId: wishlistItem['wishlistId']!,
            productId: wishlistItem['productId']!,
          );
          _localWishlist[model.productId] = model;
        }
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  // Save wishlist to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items =
          _localWishlist.values
              .map(
                (item) => {
                  'wishlistId': item.wishlistId,
                  'productId': item.productId,
                },
              )
              .toList();

      await prefs.setString(_wishlistKey, jsonEncode(items));
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  // Get wishlist items
  Future<ApiResponse<List<WishlistModel>>> getWishlistItems() async {
    try {
      await _loadFromPrefs();
      return ApiResponse<List<WishlistModel>>(
        success: true,
        data: _localWishlist.values.toList(),
        message: 'Successfully fetched wishlist items',
      );
    } catch (e) {
      return ApiResponse<List<WishlistModel>>(
        success: false,
        data: [],
        message: 'Error fetching wishlist items: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Add to wishlist
  Future<ApiResponse<bool>> addToWishlist(String productId) async {
    try {
      await _loadFromPrefs();

      final wishlistItem = WishlistModel(
        wishlistId: const Uuid().v4(),
        productId: productId,
      );

      _localWishlist[productId] = wishlistItem;
      await _saveToPrefs();

      return ApiResponse<bool>(
        success: true,
        data: true,
        message: 'Successfully added to wishlist',
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        data: false,
        message: 'Error adding to wishlist: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Remove from wishlist
  Future<ApiResponse<bool>> removeFromWishlist(String productId) async {
    try {
      await _loadFromPrefs();

      _localWishlist.remove(productId);
      await _saveToPrefs();

      return ApiResponse<bool>(
        success: true,
        data: true,
        message: 'Successfully removed from wishlist',
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        data: false,
        message: 'Error removing from wishlist: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }
}
