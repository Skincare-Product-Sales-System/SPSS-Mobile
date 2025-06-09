import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/wishlist_provider.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/services/my_app_function.dart';
import 'package:shopsmart_users_en/widgets/empty_bag.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';
import '../../widgets/products/product_widget.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = "/WishlistScreen";
  const WishlistScreen({super.key});
  final bool isEmpty = true;
  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return wishlistProvider.getWishlists.isEmpty
        ? Scaffold(
          body: EmptyBagWidget(
            imagePath: AssetsManager.bagWish,
            title: "Chưa có gì trong danh sách yêu thích",
            subtitle:
                "Có vẻ như danh sách yêu thích của bạn đang trống, hãy thêm gì đó và làm tôi vui",
            buttonText: "Mua sắm ngay",
          ),
        )
        : Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: TitlesTextWidget(
              label:
                  "Danh sách yêu thích (${wishlistProvider.getWishlists.length})",
            ),
            actions: [
              IconButton(
                onPressed: () {
                  MyAppFunctions.showErrorOrWarningDialog(
                    isError: false,
                    context: context,
                    subtitle: "Xóa danh sách yêu thích?",
                    fct: () {
                      wishlistProvider.clearLocalWishlist();
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          body: DynamicHeightGridView(
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            builder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProductWidget(
                  productId:
                      wishlistProvider.getWishlists.values
                          .toList()[index]
                          .productId,
                ),
              );
            },
            itemCount: wishlistProvider.getWishlists.length,
            crossAxisCount: 2,
          ),
        );
  }
}
