import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/models/wishlist_model.dart';
import 'package:shopsmart_users_en/repositories/wishlist_repository.dart';
import 'package:uuid/uuid.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistRepository _wishlistRepository = WishlistRepository();

  final Map<String, WishlistModel> _wishlistItems = {};
  Map<String, WishlistModel> get getWishlists {
    return _wishlistItems;
  }

  // Initialize wishlist
  Future<void> fetchWishlistFromServer() async {
    // This is a placeholder for future implementation
    // When the API supports wishlist functionality, uncomment this code
    /*
    try {
      final response = await _wishlistRepository.getWishlistItems();
      if (response.success && response.data != null) {
        _wishlistItems.clear();
        for (var item in response.data!) {
          _wishlistItems[item.productId] = item;
        }
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: ${e.toString()}');
    }
    notifyListeners();
    */
  }

  void addOrRemoveFromWishlist({required String productId}) {
    if (_wishlistItems.containsKey(productId)) {
      // Remove from wishlist
      _wishlistItems.remove(productId);
      // Call repository (uncomment when API supports it)
      // _wishlistRepository.removeFromWishlist(productId);
    } else {
      // Add to wishlist
      _wishlistItems.putIfAbsent(
        productId,
        () =>
            WishlistModel(wishlistId: const Uuid().v4(), productId: productId),
      );
      // Call repository (uncomment when API supports it)
      // _wishlistRepository.addToWishlist(productId);
    }

    notifyListeners();
  }

  bool isProdinWishlist({required String productId}) {
    return _wishlistItems.containsKey(productId);
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
