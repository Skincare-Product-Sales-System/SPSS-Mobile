import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';

import '../../providers/enhanced_wishlist_view_model.dart';
import '../../providers/wishlist_state.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../services/assets_manager.dart';
import '../../services/my_app_function.dart';
import '../../widgets/empty_bag.dart';
import '../../widgets/products/enhanced_product_widget.dart';
import '../../widgets/title_text.dart';

class EnhancedWishlistScreen extends StatelessWidget {
  static const routeName = '/enhanced-wishlist';

  const EnhancedWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedWishlistViewModel, WishlistState>(
      title: 'Danh sách yêu thích',
      onInit: (viewModel) => viewModel.fetchWishlistFromServer(),
      isLoading: (viewModel) => viewModel.isLoading,
      isEmpty: (viewModel) => viewModel.isEmpty,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      onRefresh: (viewModel) => viewModel.fetchWishlistFromServer(),
      buildAppBar: (context, viewModel) => _buildAppBar(context, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      buildEmpty: (context, viewModel) => _buildEmpty(context),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EnhancedWishlistViewModel viewModel,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nếu muốn giữ icon nước, bỏ comment dòng dưới:
                    // Image.asset('assets/images/bag/wishlist_svg.png', height: 28, width: 28),
                    // const SizedBox(width: 8),
                    Text(
                      "Danh sách yêu thích (${viewModel.count})",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!viewModel.isEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      MyAppFunctions.showErrorOrWarningDialog(
                        isError: false,
                        context: context,
                        subtitle: "Xóa danh sách yêu thích?",
                        fct: () {
                          viewModel.clearWishlist();
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedWishlistViewModel viewModel,
  ) {
    return DynamicHeightGridView(
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      builder: (context, index) {
        final productId =
            viewModel.wishlistItems.values.toList()[index].productId;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: EnhancedProductWidget(productId: productId),
        );
      },
      itemCount: viewModel.count,
      crossAxisCount: 2,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyBagWidget(
      imagePath: AssetsManager.bagWish,
      title: "Chưa có gì trong danh sách yêu thích",
      subtitle:
          "Có vẻ như danh sách yêu thích của bạn đang trống, hãy thêm gì đó và làm tôi vui",
      buttonText: "Mua sắm ngay",
    );
  }
}
