import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/widgets/empty_bag.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

import '../../providers/viewed_recently_provider.dart';
import '../../widgets/products/product_widget.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen({super.key});
  final bool isEmpty = false;
  @override
  Widget build(BuildContext context) {
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return viewedProdProvider.getViewedProds.isEmpty
        ? Scaffold(
          body: EmptyBagWidget(
            imagePath: AssetsManager.orderBag,
            title: "Chưa có sản phẩm đã xem",
            subtitle:
                "Có vẻ như bạn chưa xem sản phẩm nào, hãy khám phá cửa hàng",
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
                  "Đã xem gần đây (${viewedProdProvider.getViewedProds.length})",
            ),
            actions: [
              IconButton(
                onPressed: () {},
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
                      viewedProdProvider.getViewedProds.values
                          .toList()[index]
                          .productId,
                ),
              );
            },
            itemCount: viewedProdProvider.getViewedProds.length,
            crossAxisCount: 2,
          ),
        );
  }
}
