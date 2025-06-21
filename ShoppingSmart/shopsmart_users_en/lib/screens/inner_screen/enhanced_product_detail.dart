import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../models/detailed_product_model.dart';
import '../../models/review_models.dart';
import '../../models/cart_model.dart';
import '../../models/view_state.dart';
import '../../providers/cart_state.dart';
// Đã thay thế bằng EnhancedCartViewModel
import '../../providers/enhanced_products_view_model.dart';
import '../../widgets/products/heart_btn.dart';
import '../inner_screen/enhanced_reviews_screen.dart';
import '../../providers/enhanced_cart_view_model.dart';
import '../../providers/enhanced_wishlist_view_model.dart';
import '../cart/enhanced_cart_screen.dart';

class EnhancedProductDetailsScreen extends StatefulWidget {
  static const routeName = "/EnhancedProductDetailsScreen";
  final String? productId;

  const EnhancedProductDetailsScreen({super.key, this.productId});

  @override
  State<EnhancedProductDetailsScreen> createState() =>
      _EnhancedProductDetailsScreenState();
}

class _EnhancedProductDetailsScreenState
    extends State<EnhancedProductDetailsScreen>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
  String? _selectedProductItemId;
  late TabController _tabController;
  String? _productId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _productId = widget.productId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If productId wasn't passed as a constructor parameter, try to get it from route arguments
    _productId ??= ModalRoute.of(context)?.settings.arguments as String?;

    if (_productId != null) {
      _loadProductDetails(_productId!);

      // Đảm bảo dữ liệu wishlist được tải nếu cần
      final wishlistViewModel = Provider.of<EnhancedWishlistViewModel>(
        context,
        listen: false,
      );
      if (wishlistViewModel.wishlistItems.isEmpty &&
          !wishlistViewModel.isLoading) {
        wishlistViewModel.fetchWishlistFromServer();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails(String productId) async {
    final viewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );
    await viewModel.getProductDetails(productId);
    await viewModel.getProductReviews(productId);

    // Set first product item as default if available
    final product = viewModel.detailedProduct;
    if (product != null && product.productItems.isNotEmpty) {
      setState(() {
        _selectedProductItemId = product.productItems.first.id;
      });
    }
  }

  ProductItem? _getSelectedProductItem(DetailedProductModel? product) {
    if (_selectedProductItemId == null || product == null) return null;
    try {
      return product.productItems.firstWhere(
        (item) => item.id == _selectedProductItemId,
      );
    } catch (e) {
      return product.productItems.isNotEmpty
          ? product.productItems.first
          : null;
    }
  }

  double _getCurrentPrice(DetailedProductModel? product) {
    final selectedItem = _getSelectedProductItem(product);
    return (selectedItem?.price ?? product?.price ?? 0).toDouble();
  }

  double _getCurrentMarketPrice(DetailedProductModel? product) {
    final selectedItem = _getSelectedProductItem(product);
    return (selectedItem?.marketPrice ?? product?.marketPrice ?? 0).toDouble();
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  List<String> _getProductImages(DetailedProductModel? product) {
    if (product == null) return [];

    List<String> images = [product.thumbnail];

    // Add images from product items
    for (var item in product.productItems) {
      if (item.imageUrl.isNotEmpty && !images.contains(item.imageUrl)) {
        images.add(item.imageUrl);
      }
    }

    return images;
  }

  Color _getPriceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return Colors.purple; // Purple for dark theme
    } else {
      return Theme.of(context).primaryColor; // Primary color for light theme
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng các ViewModel cần thiết
    final enhancedCartViewModel = Provider.of<EnhancedCartViewModel>(context);
    // Không cần khai báo biến enhancedWishlistViewModel ở đây vì đã sử dụng trong _buildBottomNavigationBar

    return Consumer<EnhancedProductsViewModel>(
      builder: (context, viewModel, child) {
        final product = viewModel.detailedProduct;
        final isLoading = viewModel.isDetailLoading;
        final errorMessage = viewModel.detailErrorMessage;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? _buildErrorWidget(errorMessage)
                  : product == null
                  ? const Center(child: Text('Không tìm thấy sản phẩm'))
                  : _buildProductContent(
                    context,
                    product,
                    viewModel,
                    enhancedCartViewModel,
                  ),
          bottomNavigationBar:
              product != null
                  ? _buildBottomNavigationBar(
                    context,
                    product,
                    enhancedCartViewModel,
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Đã xảy ra lỗi', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(errorMessage, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductContent(
    BuildContext context,
    DetailedProductModel product,
    EnhancedProductsViewModel viewModel,
    EnhancedCartViewModel cartViewModel,
  ) {
    final productImages = _getProductImages(product);
    final currentPrice = _getCurrentPrice(product);
    final currentMarketPrice = _getCurrentMarketPrice(product);
    final formattedCurrentPrice = _formatPrice(currentPrice);
    final formattedCurrentMarketPrice = _formatPrice(currentMarketPrice);
    final priceColor = _getPriceColor(context);
    final selectedProductItem = _getSelectedProductItem(product);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                CarouselSlider(
                  items:
                      productImages.map((imageUrl) {
                        return FancyShimmerImage(
                          imageUrl: imageUrl,
                          boxFit: BoxFit.contain,
                          errorWidget: Image.asset('assets/images/error.png'),
                        );
                      }).toList(),
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        productImages.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _currentImageIndex == entry.key
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: HeartButtonWidget(productId: product.id),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$formattedCurrentPrice đ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (currentMarketPrice > currentPrice)
                      Text(
                        '$formattedCurrentMarketPrice đ',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.soldCount})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (product.productItems.isNotEmpty) ...[
                  const Text(
                    'Phân loại',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        product.productItems.map((item) {
                          final isSelected = item.id == _selectedProductItemId;
                          // Tạo tên hiển thị từ các configurations
                          String displayName =
                              item.configurations.isNotEmpty
                                  ? item.configurations
                                      .map((c) => c.optionName)
                                      .join(', ')
                                  : 'Mặc định';

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedProductItemId = item.id;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.black,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Số lượng:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed:
                                _selectedQuantity > 1
                                    ? () {
                                      setState(() {
                                        _selectedQuantity--;
                                      });
                                    }
                                    : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _selectedQuantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              setState(() {
                                _selectedQuantity++;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Còn ${selectedProductItem?.quantityInStock ?? 0} sản phẩm',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Chi tiết'),
                    Tab(text: 'Thông số'),
                    Tab(text: 'Đánh giá'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionTab(product),
                      _buildSpecificationsTab(product),
                      _buildReviewsTab(context, product, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(DetailedProductModel product) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(product.description),
      ),
    );
  }

  Widget _buildSpecificationsTab(DetailedProductModel product) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpecificationItem('Thương hiệu', product.brand.name),
            _buildSpecificationItem('Danh mục', product.category.categoryName),
            _buildSpecificationItem(
              'Xuất xứ',
              product.brand.country ?? 'Không có thông tin',
            ),
            _buildSpecificationItem(
              'Thành phần',
              product.specifications.detailedIngredients,
            ),
            _buildSpecificationItem(
              'Công dụng',
              product.specifications.mainFunction,
            ),
            _buildSpecificationItem('Kết cấu', product.specifications.texture),
            // Add more specifications as needed
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(
    BuildContext context,
    DetailedProductModel product,
    EnhancedProductsViewModel viewModel,
  ) {
    final reviews = viewModel.productReviews;
    final isLoading = viewModel.isReviewsLoading;
    final hasError = viewModel.hasReviewsError;
    final errorMessage = viewModel.reviewsErrorMessage;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Đã xảy ra lỗi khi tải đánh giá',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.getProductReviews(product.id),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có đánh giá nào cho sản phẩm này'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToReviewsScreen(context, product),
              icon: const Icon(Icons.add_comment),
              label: const Text('Viết đánh giá đầu tiên'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Text(
                  'Đánh giá (${reviews.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildRatingFilterDropdown(context, product.id, viewModel),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                reviews.length > 3
                    ? Column(
                      children: [
                        ...reviews
                            .take(3)
                            .map((review) => _buildReviewItem(review)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed:
                              () => _navigateToReviewsScreen(context, product),
                          icon: const Icon(Icons.more_horiz),
                          label: const Text('Xem tất cả đánh giá'),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        ...reviews.map((review) => _buildReviewItem(review)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed:
                              () => _navigateToReviewsScreen(context, product),
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Viết đánh giá mới'),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilterDropdown(
    BuildContext context,
    String productId,
    EnhancedProductsViewModel viewModel,
  ) {
    return DropdownButton<int?>(
      value: viewModel.selectedRatingFilter,
      hint: const Text('Lọc'),
      underline: Container(),
      onChanged: (value) {
        viewModel.getProductReviews(productId, ratingFilter: value);
      },
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Tất cả')),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          return DropdownMenuItem<int?>(
            value: rating,
            child: Row(
              children: [
                Text('$rating'),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _navigateToReviewsScreen(
    BuildContext context,
    DetailedProductModel product,
  ) {
    Navigator.pushNamed(
      context,
      EnhancedReviewsScreen.routeName,
      arguments: {'productId': product.id, 'productName': product.name},
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    // Format date to string
    final dateString =
        "${review.lastUpdatedTime.day}/${review.lastUpdatedTime.month}/${review.lastUpdatedTime.year}";

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dateString,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.ratingValue
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.reviewImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      review.reviewImages.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: FancyShimmerImage(
                                imageUrl: imageUrl,
                                boxFit: BoxFit.cover,
                                errorWidget: Image.asset(
                                  'assets/images/error.png',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    DetailedProductModel product,
    EnhancedCartViewModel cartViewModel,
  ) {
    final selectedProductItem = _getSelectedProductItem(product);
    final isOutOfStock =
        selectedProductItem != null
            ? selectedProductItem.quantityInStock <= 0
            : false;

    // Lấy wishlist view model
    final wishlistViewModel = Provider.of<EnhancedWishlistViewModel>(context);
    final isInWishlist = wishlistViewModel.isInWishlist(product.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút yêu thích
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                wishlistViewModel.addOrRemoveFromWishlist(
                  productId: product.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWishlist
                          ? 'Đã xóa khỏi danh sách yêu thích'
                          : 'Đã thêm vào danh sách yêu thích',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? Colors.red : Colors.grey,
              ),
              tooltip:
                  isInWishlist
                      ? 'Xóa khỏi danh sách yêu thích'
                      : 'Thêm vào danh sách yêu thích',
            ),
          ),
          // Nút thêm vào giỏ hàng
          Expanded(
            child: ElevatedButton(
              onPressed:
                  isOutOfStock || _selectedProductItemId == null
                      ? null
                      : () {
                        // Thêm vào giỏ hàng (sử dụng EnhancedCartViewModel)
                        _addToCart(product, cartViewModel);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm vào giỏ hàng'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isOutOfStock ? 'Hết hàng' : 'Thêm vào giỏ hàng',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút mua ngay
          Expanded(
            child: ElevatedButton(
              onPressed:
                  isOutOfStock || _selectedProductItemId == null
                      ? null
                      : () {
                        // Thêm vào giỏ hàng (sử dụng EnhancedCartViewModel) và chuyển đến trang giỏ hàng
                        _addToCart(product, cartViewModel);
                        Navigator.pushNamed(
                          context,
                          EnhancedCartScreen.routeName,
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isOutOfStock ? 'Hết hàng' : 'Mua ngay',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sửa phương thức để sử dụng EnhancedCartViewModel
  void _addToCart(
    DetailedProductModel product,
    EnhancedCartViewModel cartViewModel,
  ) {
    if (_selectedProductItemId == null) return;

    // Tìm kiếm thông tin sản phẩm đã chọn
    final selectedItem = _getSelectedProductItem(product);
    if (selectedItem == null) return;

    // Lấy hình ảnh sản phẩm cho giỏ hàng
    String productImageUrl = '';
    if (selectedItem.imageUrl.isNotEmpty) {
      productImageUrl = selectedItem.imageUrl;
    } else if (product.thumbnail.isNotEmpty) {
      productImageUrl = product.thumbnail;
    }

    // Lấy thông tin từ giỏ hàng hiện tại để cập nhật UI ngay lập tức
    final existingItem = cartViewModel.cartItems[_selectedProductItemId!];
    final int newQuantity =
        existingItem != null
            ? existingItem.quantity + _selectedQuantity
            : _selectedQuantity;

    // Tạo CartModel mới
    final cartItem = CartModel(
      cartId:
          existingItem?.cartId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      productItemId: _selectedProductItemId!,
      id: product.id,
      title: product.name,
      price: selectedItem.price.toDouble(),
      marketPrice: selectedItem.marketPrice.toDouble(),
      quantity: newQuantity,
      stockQuantity: selectedItem.quantityInStock,
      productImageUrl: productImageUrl,
      inStock: selectedItem.quantityInStock > 0,
      totalPrice: selectedItem.price.toDouble() * newQuantity,
      variationOptionValues: existingItem?.variationOptionValues ?? [],
    );

    // Cập nhật state thủ công để UI cập nhật ngay lập tức
    final newCartItems = Map<String, CartModel>.from(cartViewModel.cartItems);
    newCartItems[_selectedProductItemId!] = cartItem;

    // Tính tổng số lượng sản phẩm và tổng giá tiền mới
    int totalQuantity = 0;
    double totalPrice = 0;
    for (var item in newCartItems.values) {
      totalQuantity += item.quantity;
      totalPrice += item.price * item.quantity;
    }

    // HACK: Bắt buộc UI cập nhật bằng cách tạo object state mới hoàn toàn
    final newState = CartState(
      cartItems: ViewState.loaded(newCartItems),
      isProcessing: false,
      errorMessage: null,
    );

    // Cập nhật state của CartViewModel với state mới hoàn toàn
    cartViewModel.updateState(newState);

    // HACK: Buộc UI cập nhật bằng cách gọi notifyListeners thêm lần nữa sau một khoảng thời gian ngắn
    Future.delayed(const Duration(milliseconds: 50), () {
      cartViewModel.notifyListeners();
    });

    // Gọi API để đồng bộ với server
    cartViewModel.addToCart(
      productId: product.id,
      productItemId: _selectedProductItemId!,
      title: product.name,
      price: selectedItem.price.toDouble(),
      marketPrice: selectedItem.marketPrice.toDouble(),
      productImageUrl: productImageUrl,
    );
  }
}
