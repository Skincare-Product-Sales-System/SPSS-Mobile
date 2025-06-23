import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/enhanced_wishlist_view_model.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({
    super.key,
    this.bkgColor = Colors.transparent,
    this.size = 20,
    required this.productId,
    // this.isInWishlist = false,
  });
  final Color bkgColor;
  final double size;
  final String productId;
  // final bool? isInWishlist;
  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final wishlistViewModel = Provider.of<EnhancedWishlistViewModel>(context);

    return Container(
      decoration: BoxDecoration(color: widget.bkgColor, shape: BoxShape.circle),
      child: IconButton(
        style: IconButton.styleFrom(elevation: 10),
        onPressed: () {
          wishlistViewModel.addOrRemoveFromWishlist(
            productId: widget.productId,
          );
        },
        icon: Icon(
          wishlistViewModel.isInWishlist(widget.productId)
              ? IconlyBold.heart
              : IconlyLight.heart,
          size: widget.size,
          color:
              wishlistViewModel.isInWishlist(widget.productId)
                  ? Colors.red
                  : Colors.grey,
        ),
      ),
    );
  }
}
