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
          (context, viewModel) => PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: TitlesTextWidget(
                  label: "Đã xem gần đây (${viewModel.viewedProducts.length})",
                  color: Colors.white,
                ),
                centerTitle: true,
                actions: [
                  if (viewModel.viewedProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _showDeleteConfirmationDialog(context, viewModel);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(Icons.delete_forever_rounded, color: Colors.red, size: 26),
                          ),
                        ),
                      ),
                    ),
                ],
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
      buildEmpty:
          (context, viewModel) => EmptyBagWidget(
            imagePath: AssetsManager.orderBag,
            title: "Chưa có sản phẩm đã xem",
            subtitle:
                "Có vẻ như bạn chưa xem sản phẩm nào, hãy khám phá cửa hàng",
            buttonText: "Mua sắm ngay",
          ),
      buildContent: (context, viewModel) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: DynamicHeightGridView(
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          builder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.13)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.07),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: EnhancedProductWidget(
                  productId: viewModel.viewedProducts[index].productId,
                ),
              ),
            );
          },
          itemCount: viewModel.viewedProducts.length,
          crossAxisCount: 2,
        ),
      ),
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
