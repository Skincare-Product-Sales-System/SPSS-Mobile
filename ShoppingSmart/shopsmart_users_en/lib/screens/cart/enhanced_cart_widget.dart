import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../services/currency_formatter.dart';
import '../../providers/enhanced_cart_view_model.dart';
import 'enhanced_quantity_btm_sheet.dart';

class EnhancedCartWidget extends StatefulWidget {
  const EnhancedCartWidget({
    super.key,
    required this.cartModel,
    required this.viewModel,
  });

  final CartModel cartModel;
  final EnhancedCartViewModel viewModel;

  @override
  State<EnhancedCartWidget> createState() => _EnhancedCartWidgetState();
}

class _EnhancedCartWidgetState extends State<EnhancedCartWidget> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _quantityController.text = widget.cartModel.quantity.toString();
  }

  @override
  void didUpdateWidget(EnhancedCartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật controller nếu số lượng thay đổi từ nguồn khác
    if (int.tryParse(_quantityController.text) != widget.cartModel.quantity) {
      _quantityController.text = widget.cartModel.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _updateQuantity(int quantity) async {
    if (quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số lượng phải lớn hơn 0')));
      return;
    }

    await widget.viewModel.updateQuantity(
      productItemId: widget.cartModel.productItemId,
      quantity: quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final cartModel = widget.cartModel;

    // Sử dụng hình ảnh và tên từ CartModel (từ server)
    final productTitle = cartModel.title;
    final productImage = cartModel.productImageUrl;
    final variations = cartModel.variationOptionValues;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child:
                    productImage.isNotEmpty
                        ? FancyShimmerImage(
                          imageUrl: productImage,
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          boxFit: BoxFit.contain,
                        )
                        : Container(
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
              ),
              const SizedBox(width: 10),
              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề và nút xóa
                    Row(
                      children: [
                        Expanded(
                          child: TitlesTextWidget(
                            label: productTitle,
                            maxLines: 2,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              widget.viewModel.isProcessing
                                  ? null
                                  : () {
                                    widget.viewModel.removeFromCart(
                                      cartModel.productItemId,
                                    );
                                  },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    // Phiên bản sản phẩm (nếu có)
                    if (variations.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Phiên bản: ${variations.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Giá
                    SubtitleTextWidget(
                      label: CurrencyFormatter.formatVND(cartModel.price),
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    // Số lượng
                    Row(
                      children: [
                        // Nút giảm
                        InkWell(
                          onTap:
                              widget.viewModel.isProcessing
                                  ? null
                                  : () {
                                    final newQty = cartModel.quantity - 1;
                                    if (newQty >= 1) {
                                      _quantityController.text =
                                          newQty.toString();
                                      _updateQuantity(newQty);
                                    }
                                  },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        // Hiển thị số lượng
                        GestureDetector(
                          onTap:
                              widget.viewModel.isProcessing
                                  ? null
                                  : () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return EnhancedQuantityBottomSheetWidget(
                                          cartModel: cartModel,
                                          viewModel: widget.viewModel,
                                        );
                                      },
                                    );
                                  },
                          child: Container(
                            width: 48,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              cartModel.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Nút tăng
                        InkWell(
                          onTap:
                              widget.viewModel.isProcessing
                                  ? null
                                  : () {
                                    final newQty = cartModel.quantity + 1;
                                    if (newQty <= cartModel.stockQuantity) {
                                      _quantityController.text =
                                          newQty.toString();
                                      _updateQuantity(newQty);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đã đạt số lượng tối đa trong kho',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ),
                        const Spacer(),
                        // Thành tiền
                        Text(
                          CurrencyFormatter.formatVND(
                            cartModel.price * cartModel.quantity,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
