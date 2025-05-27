import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/products/heart_btn.dart';
import '../../models/detailed_product_model.dart';
import '../../services/api_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routName = "/ProductDetailsScreen";
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  DetailedProductModel? _detailedProduct;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _loadProductDetails(productId);
      }
    });
  }

  Future<void> _loadProductDetails(String productId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getProductById(productId);
      if (response.success && response.data != null) {
        setState(() {
          _detailedProduct = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load product details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading product: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final String? productId =
                            ModalRoute.of(context)!.settings.arguments
                                as String?;
                        if (productId != null) {
                          _loadProductDetails(productId);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _detailedProduct == null
              ? const Center(child: Text('Product not found'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    FancyShimmerImage(
                      imageUrl: _detailedProduct!.thumbnail,
                      height: size.height * 0.35,
                      width: double.infinity,
                      boxFit: BoxFit.cover,
                      errorWidget: Container(
                        height: size.height * 0.35,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Title and Price
                          Text(
                            _detailedProduct!.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "${_detailedProduct!.formattedPrice} VND",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                              if (_detailedProduct!.marketPrice >
                                  _detailedProduct!.price) ...[
                                const SizedBox(width: 12),
                                Text(
                                  "${_detailedProduct!.formattedMarketPrice} VND",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "-${_detailedProduct!.discountPercentage.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              HeartButtonWidget(
                                bkgColor: Colors.blue.shade100,
                                productId: _detailedProduct!.id,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (cartProvider.isProdinCart(
                                      productId: _detailedProduct!.id,
                                    )) {
                                      return;
                                    }
                                    cartProvider.addProductToCart(
                                      productId: _detailedProduct!.id,
                                    );
                                  },
                                  icon: Icon(
                                    cartProvider.isProdinCart(
                                          productId: _detailedProduct!.id,
                                        )
                                        ? Icons.check
                                        : Icons.add_shopping_cart_outlined,
                                  ),
                                  label: Text(
                                    cartProvider.isProdinCart(
                                          productId: _detailedProduct!.id,
                                        )
                                        ? "In Cart"
                                        : "Add to Cart",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Product Information Tables
                          _buildInfoSection("Product Details", [
                            _buildInfoRow("Status", _detailedProduct!.status),
                            _buildInfoRow(
                              "Rating",
                              "${_detailedProduct!.rating}/5.0 ⭐",
                            ),
                            _buildInfoRow(
                              "Sold Count",
                              "${_detailedProduct!.soldCount} sold",
                            ),
                            _buildInfoRow(
                              "Category",
                              _detailedProduct!.category.categoryName,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          _buildInfoSection("Brand Information", [
                            _buildInfoRow(
                              "Brand",
                              _detailedProduct!.brand.name,
                            ),
                            _buildInfoRow(
                              "Brand Title",
                              _detailedProduct!.brand.title,
                            ),
                            _buildInfoRow(
                              "Description",
                              _detailedProduct!.brand.description,
                              isDescription: true,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          _buildInfoSection("Product Description", [
                            _buildInfoRow(
                              "Description",
                              _detailedProduct!.description,
                              isDescription: true,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          _buildInfoSection("Specifications", [
                            _buildInfoRow(
                              "Main Function",
                              _detailedProduct!.specifications.mainFunction,
                              isDescription: true,
                            ),
                            _buildInfoRow(
                              "Texture",
                              _detailedProduct!.specifications.texture,
                            ),
                            _buildInfoRow(
                              "Usage Instructions",
                              _detailedProduct!.specifications.usageInstruction,
                              isDescription: true,
                            ),
                            _buildInfoRow(
                              "Storage Instructions",
                              _detailedProduct!
                                  .specifications
                                  .storageInstruction,
                              isDescription: true,
                            ),
                            _buildInfoRow(
                              "Expiry Date",
                              _detailedProduct!.specifications.expiryDate,
                            ),
                            _buildInfoRow(
                              "Skin Issues",
                              _detailedProduct!.specifications.skinIssues,
                            ),
                            _buildInfoRow(
                              "Key Active Ingredients",
                              _detailedProduct!
                                  .specifications
                                  .keyActiveIngredients,
                              isDescription: true,
                            ),
                            _buildInfoRow(
                              "Detailed Ingredients",
                              _detailedProduct!
                                  .specifications
                                  .detailedIngredients,
                              isDescription: true,
                            ),
                          ]),

                          if (_detailedProduct!.productItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildProductVariants(),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isDescription = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? "Not specified" : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey : Colors.black54,
                height: isDescription ? 1.4 : 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductVariants() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              "Available Variants",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ..._detailedProduct!.productItems.map(
            (item) => _buildVariantRow(item),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantRow(ProductItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...item.configurations.map(
                      (config) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "${config.variationName}: ${config.optionName}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        if (item.marketPrice > item.price) ...[
                          const SizedBox(width: 8),
                          Text(
                            "${item.marketPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND",
                            style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          item.quantityInStock > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Stock: ${item.quantityInStock}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            item.quantityInStock > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
