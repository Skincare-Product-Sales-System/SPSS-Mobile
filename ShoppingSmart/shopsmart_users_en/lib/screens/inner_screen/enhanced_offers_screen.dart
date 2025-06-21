import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import '../../providers/enhanced_products_view_model.dart';
import '../../providers/products_state.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../services/assets_manager.dart';
import '../../widgets/empty_bag.dart';
import '../../widgets/products/product_widget.dart';
import '../../widgets/title_text.dart';

class EnhancedOffersScreen extends StatefulWidget {
  static const routeName = "/enhanced-offers";
  const EnhancedOffersScreen({super.key});

  @override
  State<EnhancedOffersScreen> createState() => _EnhancedOffersScreenState();
}

class _EnhancedOffersScreenState extends State<EnhancedOffersScreen> {
  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedProductsViewModel, ProductsState>(
      title: "Ưu đãi đặc biệt",
      onInit: (viewModel) {
        viewModel.loadProducts(refresh: true);
      },
      isLoading: (viewModel) => viewModel.isLoading,
      isEmpty: (viewModel) => viewModel.products.isEmpty,
      getErrorMessage:
          (viewModel) => viewModel.hasError ? viewModel.errorMessage : null,
      onRefresh: (viewModel) => viewModel.loadProducts(refresh: true),
      buildAppBar:
          (context, viewModel) => AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: const TitlesTextWidget(label: "🎉 Ưu đãi đặc biệt"),
            actions: [
              IconButton(
                onPressed: () {
                  viewModel.loadProducts(refresh: true);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
      buildEmpty:
          (context, viewModel) => EmptyBagWidget(
            imagePath: AssetsManager.bagWish,
            title: "Không có ưu đãi nào",
            subtitle: "Quay lại sau để xem các ưu đãi và giảm giá tuyệt vời",
            buttonText: "Mua sắm ngay",
          ),
      buildContent:
          (context, viewModel) => _buildOffersContent(context, viewModel),
    );
  }

  Widget _buildOffersContent(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    // Hiển thị tất cả sản phẩm như ưu đãi (hoặc có thể lọc theo tiêu chí khác)
    final offerProducts = viewModel.products;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Limited Time Offers",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        "${offerProducts.length} ưu đãi tuyệt vời đang chờ bạn",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DynamicHeightGridView(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              builder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ProductWidget(
                    productId: offerProducts[index].productId,
                  ),
                );
              },
              itemCount: offerProducts.length,
              crossAxisCount: 2,
            ),
          ),
        ],
      ),
    );
  }
}
