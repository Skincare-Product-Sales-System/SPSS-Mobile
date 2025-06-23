import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import '../../providers/enhanced_viewed_products_provider.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../services/assets_manager.dart';
import '../../widgets/empty_bag.dart';
import '../../widgets/products/enhanced_product_widget.dart';
import '../../widgets/title_text.dart';

class EnhancedViewedRecentlyScreen extends StatefulWidget {
  static const routeName = "/enhanced-viewed-recently";
  const EnhancedViewedRecentlyScreen({super.key});

  @override
  State<EnhancedViewedRecentlyScreen> createState() =>
      _EnhancedViewedRecentlyScreenState();
}

class _EnhancedViewedRecentlyScreenState
    extends State<EnhancedViewedRecentlyScreen> {
  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<
      EnhancedViewedProductsProvider,
      ViewedProductsState
    >(
      title: "Đã xem gần đây",
      onInit: (viewModel) {
        viewModel.loadViewedProducts();
      },
      isLoading: (viewModel) => viewModel.isLoading,
      isEmpty: (viewModel) => viewModel.viewedProducts.isEmpty,
      getErrorMessage:
          (viewModel) => viewModel.hasError ? viewModel.errorMessage : null,
      onRefresh: (viewModel) => viewModel.loadViewedProducts(),
      buildAppBar:
          (context, viewModel) => AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: TitlesTextWidget(
              label: "Đã xem gần đây (${viewModel.viewedProducts.length})",
            ),
            actions: [
              if (viewModel.viewedProducts.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, viewModel);
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
      buildEmpty:
          (context, viewModel) => EmptyBagWidget(
            imagePath: AssetsManager.orderBag,
            title: "Chưa có sản phẩm đã xem",
            subtitle:
                "Có vẻ như bạn chưa xem sản phẩm nào, hãy khám phá cửa hàng",
            buttonText: "Mua sắm ngay",
          ),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedViewedProductsProvider viewModel,
  ) {
    final viewedProducts = viewModel.viewedProducts;

    return DynamicHeightGridView(
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      builder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: EnhancedProductWidget(
            productId: viewedProducts[index].productId,
          ),
        );
      },
      itemCount: viewedProducts.length,
      crossAxisCount: 2,
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    EnhancedViewedProductsProvider viewModel,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tất cả sản phẩm đã xem?'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tất cả sản phẩm đã xem gần đây không?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                viewModel.clearViewedProducts();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
