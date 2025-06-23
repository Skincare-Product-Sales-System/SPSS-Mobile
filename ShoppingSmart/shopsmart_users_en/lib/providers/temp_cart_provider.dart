import 'package:flutter/material.dart';
import '../models/skin_analysis_models.dart';
import '../models/detailed_product_model.dart';
import '../repositories/product_repository.dart';
import '../services/service_locator.dart';

class TempCartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final String? productItemId; // Sẽ được cập nhật sau khi chọn variation
  final List<String>?
  selectedVariationOptionValues; // Lưu trữ các variation đã chọn

  TempCartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.productItemId,
    this.selectedVariationOptionValues,
  });

  // Tạo từ RecommendedProduct
  factory TempCartItem.fromRecommendedProduct(RecommendedProduct product) {
    return TempCartItem(
      productId: product.productId,
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
    );
  }

  // Tạo bản sao với thuộc tính cập nhật
  TempCartItem copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    String? productItemId,
    List<String>? selectedVariationOptionValues,
  }) {
    return TempCartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      productItemId: productItemId ?? this.productItemId,
      selectedVariationOptionValues:
          selectedVariationOptionValues ?? this.selectedVariationOptionValues,
    );
  }
}

class TempCartProvider with ChangeNotifier {
  final Map<String, TempCartItem> _tempCartItems = {};

  // Cache cho product details để tránh gọi API nhiều lần
  final Map<String, DetailedProductModel> _productDetailsCache = {};

  // Map để theo dõi trạng thái loading của từng sản phẩm
  final Map<String, bool> _loadingStates = {};

  // Map để lưu trữ lỗi cho từng sản phẩm
  final Map<String, String?> _errorMessages = {};

  // Khởi tạo repository
  final ProductRepository _productRepository = sl<ProductRepository>();

  // Getter cho giỏ hàng tạm thời
  Map<String, TempCartItem> get tempCartItems => _tempCartItems;

  // Getter cho cache sản phẩm
  Map<String, DetailedProductModel> get productDetailsCache =>
      _productDetailsCache;

  // Kiểm tra xem sản phẩm có đang loading không
  bool isProductLoading(String productId) => _loadingStates[productId] ?? false;

  // Lấy thông báo lỗi cho sản phẩm
  String? getErrorForProduct(String productId) => _errorMessages[productId];

  // Kiểm tra xem sản phẩm đã có trong cache chưa
  bool hasProductDetails(String productId) =>
      _productDetailsCache.containsKey(productId);

  // Lấy chi tiết sản phẩm từ cache
  DetailedProductModel? getProductDetails(String productId) =>
      _productDetailsCache[productId];

  // Số lượng sản phẩm trong giỏ hàng tạm thời
  int get itemCount => _tempCartItems.length;

  // Tổng giá tiền
  double get totalPrice {
    double total = 0.0;
    _tempCartItems.forEach((key, item) {
      total += item.price;
    });
    return total;
  }

  // Thêm sản phẩm vào giỏ hàng tạm thời
  void addProduct(RecommendedProduct product) {
    final tempItem = TempCartItem.fromRecommendedProduct(product);
    _tempCartItems[product.productId] = tempItem;
    notifyListeners();

    // Tự động fetch product details khi thêm sản phẩm
    fetchProductDetails(product.productId);
  }

  // Hàm fetch chi tiết sản phẩm từ API
  Future<void> fetchProductDetails(String productId) async {
    // Nếu đã có trong cache, không cần fetch lại
    if (_productDetailsCache.containsKey(productId)) return;

    // Đặt trạng thái loading
    _loadingStates[productId] = true;
    _errorMessages[productId] = null;
    notifyListeners();

    try {
      final response = await _productRepository.getProductById(productId);

      if (response.success && response.data != null) {
        _productDetailsCache[productId] = response.data!;
        _loadingStates[productId] = false;
        _errorMessages[productId] = null;
      } else {
        _loadingStates[productId] = false;
        _errorMessages[productId] =
            response.message ?? 'Không thể tải thông tin sản phẩm';
      }
    } catch (e) {
      _loadingStates[productId] = false;
      _errorMessages[productId] = 'Lỗi: ${e.toString()}';
    }

    notifyListeners();
  }

  // Cập nhật thông tin sản phẩm trong giỏ hàng tạm thời
  void updateProductItem(
    String productId,
    String productItemId,
    List<String> variationOptionValues, [
    double? newPrice,
  ]) {
    if (_tempCartItems.containsKey(productId)) {
      _tempCartItems[productId] = _tempCartItems[productId]!.copyWith(
        productItemId: productItemId,
        selectedVariationOptionValues: variationOptionValues,
        price: newPrice ?? _tempCartItems[productId]!.price,
      );
      notifyListeners();
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng tạm thời
  void removeProduct(String productId) {
    _tempCartItems.remove(productId);
    notifyListeners();
  }

  // Xóa tất cả sản phẩm trong giỏ hàng tạm thời
  void clearTempCart() {
    _tempCartItems.clear();
    // Không xóa cache product details để tái sử dụng
    notifyListeners();
  }

  // Thêm tất cả sản phẩm từ các bước skincare routine
  void addAllRoutineProducts(List<RoutineStep> routineSteps) {
    // Duyệt qua tất cả các bước
    for (var step in routineSteps) {
      // Duyệt qua các sản phẩm trong mỗi bước
      for (var product in step.products) {
        addProduct(product);
      }
    }
  }

  // Kiểm tra xem sản phẩm đã có trong giỏ hàng tạm thời chưa
  bool hasProduct(String productId) {
    return _tempCartItems.containsKey(productId);
  }
}
