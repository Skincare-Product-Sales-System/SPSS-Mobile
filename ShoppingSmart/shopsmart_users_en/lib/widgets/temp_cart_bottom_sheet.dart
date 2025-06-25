import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temp_cart_provider.dart';
import '../providers/cart_provider.dart';
import '../models/detailed_product_model.dart';
import '../screens/inner_screen/enhanced_product_detail.dart';
import '../root_screen.dart';
import 'dart:async'; // Để sử dụng Timer

class TempCartBottomSheet extends StatefulWidget {
  const TempCartBottomSheet({super.key});

  @override
  State<TempCartBottomSheet> createState() => _TempCartBottomSheetState();
}

class _TempCartBottomSheetState extends State<TempCartBottomSheet>
    with SingleTickerProviderStateMixin {
  // Map để lưu các options đã chọn cho từng sản phẩm
  final Map<String, Map<String, String>> _selectedOptions = {};

  // Animation controller để làm nổi bật giỏ hàng
  late AnimationController _highlightController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;
  // Biến để phát hiện animation cho icon giỏ hàng
  late Animation<double> _cartIconScaleAnimation;
  late Animation<Color?> _cartIconColorAnimation;
  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation controller
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Tạo animation màu sắc từ nhạt đến đậm với gradient đẹp hơn
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.blue.shade100,
    ).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    // Tạo animation scale nhẹ nhàng hơn
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    // Animation cho icon giỏ hàng
    _cartIconScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.elasticOut),
    );

    _cartIconColorAnimation = ColorTween(
      begin: Theme.of(context).primaryColor,
      end: Colors.orange,
    ).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    // Lặp lại animation với nhịp độ chậm hơn để tạo cảm giác nhẹ nhàng
    _highlightController.repeat(reverse: true);

    // Bắt đầu hiệu ứng nhấp nháy cho icon giỏ hàng
    _startCartIconBlinking();
  }

  // Hàm khởi tạo hiệu ứng nhấp nháy cho icon giỏ hàng
  void _startCartIconBlinking() {
    _isBlinking = true;
    _blinkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _isBlinking) {
        setState(() {}); // Cập nhật giao diện để icon nhấp nháy
      }
    });
  }

  // Hàm dừng hiệu ứng nhấp nháy
  void _stopCartIconBlinking() {
    _isBlinking = false;
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }

  @override
  void dispose() {
    _stopCartIconBlinking();
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tempCartProvider = Provider.of<TempCartProvider>(context);
    final tempCartItems = tempCartProvider.tempCartItems;

    return WillPopScope(
      // Xử lý khi người dùng nhấn nút back trên điện thoại
      onWillPop: () async {
        // Hiển thị dialog thông báo
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Không thể quay lại'),
                content: const Text(
                  'Bạn không thể quay lại trang trước khi đã có kết quả phân tích. Vui lòng sử dụng nút Home hoặc Back trên thanh điều hướng để trở về trang chủ.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                    },
                    child: const Text('Để sau'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog

                      // Đóng bottom sheet
                      Navigator.of(context).pop();

                      // Điều hướng về màn hình chính
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(RootScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Về trang chủ'),
                  ),
                ],
              ),
        );

        return false; // Ngăn chặn hành vi back mặc định
      },
      child: AnimatedBuilder(
        animation: _highlightController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(
                    0.2 + 0.2 * _highlightController.value,
                  ),
                  spreadRadius: 2 + _highlightController.value,
                  blurRadius: 8 + 4 * _highlightController.value,
                  offset: const Offset(0, -3),
                ),
              ],
              border: Border.all(
                color: Colors.blue.withOpacity(
                  0.3 + 0.2 * _highlightController.value,
                ),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giỏ hàng gợi ý',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Thêm nút home với hiệu ứng nổi bật
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(
                                  0.2 + 0.1 * _highlightController.value,
                                ),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.home, size: 26),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              // Đóng bottom sheet và điều hướng về trang chủ
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(RootScreen.routeName);
                            },
                            tooltip: 'Về trang chủ',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  thickness: 1.5,
                  height: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Các sản phẩm trong quy trình chăm sóc da của bạn:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (tempCartItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Không có sản phẩm nào trong giỏ hàng gợi ý',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tempCartItems.length,
                      itemBuilder: (context, index) {
                        final productId = tempCartItems.keys.elementAt(index);
                        final item = tempCartItems[productId]!;
                        return Transform.scale(
                          scale: 1.0,
                          child: Card(
                            elevation: 3 + _highlightController.value * 2,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildTempCartItem(context, item, index),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _highlightController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                tempCartItems.isNotEmpty
                                    ? _scaleAnimation.value
                                    : 1.0,
                            child: ElevatedButton.icon(
                              onPressed:
                                  tempCartItems.isEmpty
                                      ? null
                                      : () async {
                                        await _addAllToCart(
                                          context,
                                          tempCartItems,
                                        );
                                      },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Thêm tất cả vào giỏ hàng'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Colors.orange.withOpacity(
                                      _highlightController.value * 0.8,
                                    ),
                                    width: 2.0,
                                  ),
                                ),
                                backgroundColor: ColorTween(
                                  begin: Theme.of(context).primaryColor,
                                  end: Colors.orange,
                                ).evaluate(
                                  AlwaysStoppedAnimation(
                                    _highlightController.value * 0.3,
                                  ),
                                ),
                                foregroundColor: Colors.white,
                                elevation: 6 + _highlightController.value * 4,
                                shadowColor: Colors.orange.withOpacity(
                                  0.3 + _highlightController.value * 0.3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTempCartItem(
    BuildContext context,
    TempCartItem item,
    int index,
  ) {
    final tempCartProvider = Provider.of<TempCartProvider>(context);
    final isLoading = tempCartProvider.isProductLoading(item.productId);
    final errorMessage = tempCartProvider.getErrorForProduct(item.productId);

    // Lấy product details từ cache
    final productDetails = tempCartProvider.getProductDetails(item.productId);

    // Khởi tạo selected options nếu chưa có
    if (!_selectedOptions.containsKey(item.productId)) {
      _selectedOptions[item.productId] = {};
    }

    // Tự động fetch product details nếu chưa có
    if (!isLoading &&
        productDetails == null &&
        !tempCartProvider.hasProductDetails(item.productId)) {
      Future.microtask(
        () => tempCartProvider.fetchProductDetails(item.productId),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 30),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(item.price)}₫',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item.productItemId != null)
                        _buildSelectedVariationText(item),
                    ],
                  ),
                ),
                // Các nút tương tác
                Column(
                  children: [
                    // Nút thêm vào giỏ hàng với hiệu ứng nổi bật
                    AnimatedBuilder(
                      animation: _highlightController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(
                                  0.3 * _highlightController.value,
                                ),
                                spreadRadius: 2 * _highlightController.value,
                                blurRadius: 7 * _highlightController.value,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: 1.0 + 0.15 * _highlightController.value,
                            child: IconButton(
                              icon: Icon(
                                Icons.add_shopping_cart,
                                size: 24,
                                color: ColorTween(
                                  begin: Theme.of(context).primaryColor,
                                  end: Colors.orange,
                                ).evaluate(
                                  AlwaysStoppedAnimation(
                                    _highlightController.value,
                                  ),
                                ),
                              ),
                              onPressed:
                                  item.productItemId != null
                                      ? () => _addToCart(context, item)
                                      : null,
                              tooltip:
                                  item.productItemId != null
                                      ? 'Thêm vào giỏ hàng'
                                      : 'Chọn thuộc tính trước',
                            ),
                          ),
                        );
                      },
                    ),
                    // Nút xem chi tiết sản phẩm
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, size: 20),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          EnhancedProductDetailsScreen.routeName,
                          arguments: item.productId,
                        );
                      },
                      tooltip: 'Xem chi tiết',
                    ),
                    // Nút xóa khỏi giỏ hàng tạm thời
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      onPressed: () {
                        Provider.of<TempCartProvider>(
                          context,
                          listen: false,
                        ).removeProduct(item.productId);
                      },
                      tooltip: 'Xóa khỏi giỏ hàng',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hiển thị phần chọn variations trực tiếp (luôn hiển thị)
          _buildVariationSelectionSection(
            context,
            item,
            productDetails,
            isLoading,
            errorMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedVariationText(TempCartItem item) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            item.selectedVariationOptionValues?.join(', ') ??
                'Đã chọn thuộc tính',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVariationSelectionSection(
    BuildContext context,
    TempCartItem item,
    DetailedProductModel? productDetails,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(errorMessage, textAlign: TextAlign.center),
              TextButton(
                onPressed: () {
                  Provider.of<TempCartProvider>(
                    context,
                    listen: false,
                  ).fetchProductDetails(item.productId);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (productDetails == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Không có dữ liệu sản phẩm')),
      );
    }

    // Xác định số lượng loại biến thể
    final variations = _getUniqueVariations(productDetails.productItems);

    if (variations.isEmpty) {
      // Nếu sản phẩm không có biến thể, tự động chọn sản phẩm
      if (productDetails.productItems.isNotEmpty &&
          item.productItemId == null) {
        // Delay để tránh setState trong build
        Future.microtask(() {
          final productItem = productDetails.productItems.first;
          Provider.of<TempCartProvider>(
            context,
            listen: false,
          ).updateProductItem(
            item.productId,
            productItem.id,
            [],
            productItem.price.toDouble(),
          );
        });
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Sản phẩm không có biến thể',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...variations.entries.map((entry) {
            final variationName = entry.key;
            final options = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      options.map((option) {
                        bool isSelected =
                            _selectedOptions[item.productId]![variationName] ==
                            option;

                        return ChoiceChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedOptions[item
                                        .productId]![variationName] =
                                    option;

                                // Tìm product item phù hợp với tất cả lựa chọn hiện tại
                                _updateSelectedProductItem(
                                  context,
                                  item,
                                  productDetails,
                                );
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }), // Hiển thị nút thêm vào giỏ hàng
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _highlightController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(
                          0.2 + 0.2 * _highlightController.value,
                        ),
                        spreadRadius: 1 + _highlightController.value,
                        blurRadius: 5 + 2 * _highlightController.value,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        item.productItemId != null
                            ? () => _addToCart(context, item)
                            : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.white,
                      backgroundColor: ColorTween(
                        begin: Theme.of(context).primaryColor,
                        end: Colors.orange,
                      ).evaluate(
                        AlwaysStoppedAnimation(_highlightController.value),
                      ),
                      elevation: 2 + 2 * _highlightController.value,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.shopping_cart,
                      size: 20 + 2 * _highlightController.value,
                    ),
                    label: const Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm lấy ra danh sách các loại biến thể và giá trị
  Map<String, List<String>> _getUniqueVariations(
    List<ProductItem> productItems,
  ) {
    Map<String, Set<String>> uniqueVariations = {};

    for (var item in productItems) {
      for (var config in item.configurations) {
        if (!uniqueVariations.containsKey(config.variationName)) {
          uniqueVariations[config.variationName] = {};
        }
        uniqueVariations[config.variationName]!.add(config.optionName);
      }
    }

    // Convert Set to List in the result
    return uniqueVariations.map((key, value) => MapEntry(key, value.toList()));
  }

  // Cập nhật ProductItem đã chọn dựa trên các options đã chọn
  void _updateSelectedProductItem(
    BuildContext context,
    TempCartItem item,
    DetailedProductModel productDetails,
  ) {
    final selectedOptions = _selectedOptions[item.productId];

    // Nếu chưa chọn đủ options cho tất cả variations, chưa thể xác định product item
    if (selectedOptions!.length <
        _getUniqueVariations(productDetails.productItems).length) {
      return;
    }

    // Tìm product item phù hợp với tất cả options đã chọn
    for (var productItem in productDetails.productItems) {
      bool isMatch = true;

      // Kiểm tra tất cả configurations của product item
      for (var config in productItem.configurations) {
        final selectedOption = selectedOptions[config.variationName];

        // Nếu một option không khớp, đây không phải product item phù hợp
        if (selectedOption != config.optionName) {
          isMatch = false;
          break;
        }
      }

      // Nếu tìm thấy product item phù hợp
      if (isMatch) {
        // Lưu danh sách tên các options đã chọn để hiển thị
        List<String> optionNames =
            productItem.configurations.map((c) => c.optionName).toList();

        // Cập nhật thông tin productItemId vào temp cart
        Provider.of<TempCartProvider>(context, listen: false).updateProductItem(
          item.productId,
          productItem.id,
          optionNames,
          productItem.price.toDouble(),
        );

        return;
      }
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> _addToCart(BuildContext context, TempCartItem item) async {
    if (item.productItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thuộc tính sản phẩm trước'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      await cartProvider.addProductToCart(
        productId: item.productId,
        productItemId: item.productItemId!,
        title: item.name,
        price: item.price,
      );

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${item.name} vào giỏ hàng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addAllToCart(
    BuildContext context,
    Map<String, TempCartItem> items,
  ) async {
    // Kiểm tra xem có sản phẩm nào chưa chọn variations không
    final incompleteItems =
        items.values.where((item) => item.productItemId == null).toList();

    if (incompleteItems.isNotEmpty) {
      // Hiển thị thông báo
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Cần chọn thuộc tính'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Các sản phẩm sau cần chọn thuộc tính:'),
                    const SizedBox(height: 8),
                    ...incompleteItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${item.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Đã hiểu'),
                ),
              ],
            ),
      );
      return;
    }

    // Tất cả sản phẩm đã chọn variations, tiến hành thêm vào giỏ hàng
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Thêm từng sản phẩm vào giỏ hàng
      for (var item in items.values) {
        await cartProvider.addProductToCart(
          productId: item.productId,
          productItemId: item.productItemId!,
          title: item.name,
          price: item.price,
        );
      }

      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm tất cả sản phẩm vào giỏ hàng'),
          backgroundColor: Colors.green,
        ),
      );

      // Đóng bottom sheet
      Navigator.of(context).pop();
    } catch (e) {
      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
