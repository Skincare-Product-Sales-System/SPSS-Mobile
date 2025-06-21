import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';

import '../../providers/enhanced_cart_view_model.dart';
import '../../providers/enhanced_products_view_model.dart';
import '../../providers/enhanced_profile_view_model.dart';
import '../../providers/enhanced_order_view_model.dart';
import '../../models/voucher_model.dart';
import '../../widgets/title_text.dart';
import '../../services/currency_formatter.dart';
import '../../screens/auth/enhanced_login.dart';
import '../profile/enhanced_address_screen.dart';
import 'enhanced_order_success_screen.dart';

class EnhancedCheckoutScreen extends StatefulWidget {
  static const routeName = '/enhanced-checkout';

  const EnhancedCheckoutScreen({super.key});

  @override
  State<EnhancedCheckoutScreen> createState() => _EnhancedCheckoutScreenState();
}

class _EnhancedCheckoutScreenState extends State<EnhancedCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;
  String? _selectedVoucherId;
  VoucherModel? _selectedVoucher;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCheckout();
  }

  Future<void> _initializeCheckout() async {
    // Kiểm tra đăng nhập và tải dữ liệu cần thiết
    final profileViewModel = Provider.of<EnhancedProfileViewModel>(
      context,
      listen: false,
    );

    if (!profileViewModel.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
          EnhancedLoginScreen.routeName,
          arguments: 'checkout',
        );
      });
      return;
    }

    // Tải dữ liệu địa chỉ, phương thức thanh toán
    await profileViewModel.fetchAddresses();
    await profileViewModel.fetchPaymentMethods();

    // Nếu có địa chỉ, chọn địa chỉ mặc định hoặc địa chỉ đầu tiên
    final addresses = profileViewModel.addresses;
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => addresses.first,
      );
      setState(() {
        _selectedAddressId = defaultAddress.id;
      });
    }

    // Nếu có phương thức thanh toán, chọn phương thức đầu tiên
    final paymentMethods = profileViewModel.paymentMethods;
    if (paymentMethods.isNotEmpty) {
      setState(() {
        _selectedPaymentMethodId = paymentMethods.first.id;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        centerTitle: true,
        title: const TitlesTextWidget(label: 'Thanh toán', fontSize: 22),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(IconlyLight.arrow_left_2, size: 24),
        ),
      ),
      body: Consumer3<
        EnhancedCartViewModel,
        EnhancedProductsViewModel,
        EnhancedProfileViewModel
      >(
        builder: (
          context,
          cartViewModel,
          productsViewModel,
          profileViewModel,
          child,
        ) {
          final cartItems = cartViewModel.cartItems;
          final isLoading =
              cartViewModel.isLoading || profileViewModel.isLoading;
          final errorMessage =
              cartViewModel.errorMessage ?? profileViewModel.errorMessage;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyLight.bag, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng trống',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy thêm sản phẩm vào giỏ hàng để thanh toán',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(IconlyLight.bag),
                    label: const Text('Tiếp tục mua sắm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Địa chỉ giao hàng'),
                      _buildAddressSection(),
                      _buildSectionTitle('Phương thức thanh toán'),
                      _buildPaymentMethodSection(),
                      _buildSectionTitle('Thông tin đơn hàng'),
                      _buildOrderSummary(cartViewModel),
                      _buildSectionTitle('Ghi chú'),
                      _buildNotesSection(),
                      const SizedBox(height: 120), // Space for bottom button
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomCheckout(cartViewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: TitlesTextWidget(label: title, fontSize: 18),
    );
  }

  Widget _buildAddressSection() {
    // TODO: Replace with actual addresses from ViewModel
    final profileViewModel = Provider.of<EnhancedProfileViewModel>(
      context,
      listen: false,
    );
    final addresses = profileViewModel.addresses;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (addresses.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Text('Bạn chưa có địa chỉ nào'),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(EnhancedAddressScreen.routeName);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm địa chỉ mới'),
                    ),
                  ],
                ),
              )
            else
              for (final address in addresses)
                RadioListTile<String>(
                  title: Text(
                    address.address,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SĐT: ${address.phoneNumber}'),
                      if (address.note != null && address.note!.isNotEmpty)
                        Text('Ghi chú: ${address.note}'),
                    ],
                  ),
                  value: address.id,
                  groupValue: _selectedAddressId ?? addresses.first.id,
                  onChanged: (value) {
                    setState(() {
                      _selectedAddressId = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).primaryColor,
                ),
            const Divider(),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(EnhancedAddressScreen.routeName);
                },
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Quản lý địa chỉ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    // TODO: Replace with actual payment methods from ViewModel
    final profileViewModel = Provider.of<EnhancedProfileViewModel>(
      context,
      listen: false,
    );
    final paymentMethods = profileViewModel.paymentMethods;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paymentMethods.isEmpty)
              const Center(child: Text('Không có phương thức thanh toán nào'))
            else
              for (final method in paymentMethods)
                RadioListTile<String>(
                  title: Text(
                    method.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(method.description),
                  value: method.id,
                  groupValue:
                      _selectedPaymentMethodId ?? paymentMethods.first.id,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethodId = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).primaryColor,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(EnhancedCartViewModel cartViewModel) {
    final cartItems = cartViewModel.cartItems;
    final totalAmount = cartViewModel.totalAmount;

    final discount = _selectedVoucher?.discountAmount ?? 0.0;
    final finalAmount = totalAmount - discount;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh sách sản phẩm
            for (final item in cartItems.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.productImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.variationOptionValues.isNotEmpty)
                            Text(
                              'Phân loại: ${item.variationOptionValues.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${CurrencyFormatter.format(item.price)} đ',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('x${item.quantity}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            // Tổng tiền hàng
            _buildSummaryRow(
              'Tổng tiền hàng',
              '${CurrencyFormatter.format(totalAmount)} đ',
            ),
            if (discount > 0)
              _buildSummaryRow(
                'Giảm giá',
                '-${CurrencyFormatter.format(discount)} đ',
                valueColor: Colors.green,
              ),
            const Divider(),
            _buildSummaryRow(
              'Tổng thanh toán',
              '${CurrencyFormatter.format(finalAmount)} đ',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú cho đơn hàng (nếu có)',
            border: InputBorder.none,
          ),
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildBottomCheckout(EnhancedCartViewModel cartViewModel) {
    final totalAmount = cartViewModel.totalAmount;
    final discount = _selectedVoucher?.discountAmount ?? 0.0;
    final finalAmount = totalAmount - discount;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tổng thanh toán'),
                Text(
                  '${CurrencyFormatter.format(finalAmount)} đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đặt hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn địa chỉ giao hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedPaymentMethodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn phương thức thanh toán'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final cartViewModel = Provider.of<EnhancedCartViewModel>(
          context,
          listen: false,
        );
        final orderViewModel = Provider.of<EnhancedOrderViewModel>(
          context,
          listen: false,
        );

        // Chuẩn bị dữ liệu đơn hàng
        final orderDetails =
            cartViewModel.cartItems.values
                .map(
                  (item) => {
                    'productItemId': item.productItemId,
                    'quantity': item.quantity,
                  },
                )
                .toList();

        // Tạo dữ liệu đơn hàng hoàn chỉnh
        final orderData = {
          'addressId': _selectedAddressId,
          'paymentMethodId': _selectedPaymentMethodId,
          'voucherId': _selectedVoucherId,
          'notes': _notesController.text.trim(),
          'OrderDetail':
              orderDetails, // Changed to match API schema with correct capitalization
        };

        // Gọi API tạo đơn hàng thông qua EnhancedOrderViewModel
        final orderResponse = await orderViewModel.createOrder(orderData);

        // Đóng dialog loading
        Navigator.of(context).pop();

        if (orderResponse != null) {
          // Xóa giỏ hàng sau khi đặt hàng thành công
          await cartViewModel.clearCart();

          // Chuyển đến màn hình đặt hàng thành công
          Navigator.of(context).pushReplacementNamed(
            EnhancedOrderSuccessScreen.routeName,
            arguments: orderResponse.orderId,
          );
        } else {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderViewModel.creatingOrderError ??
                    'Đã xảy ra lỗi khi tạo đơn hàng',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Đóng dialog loading
        Navigator.of(context).pop();

        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
