import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../services/jwt_service.dart';
import '../../services/currency_formatter.dart';
import '../../screens/auth/login.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../models/address_model.dart';
import '../../services/api_service.dart';
import '../../services/my_app_function.dart';
import '../../models/payment_method_model.dart';
import '../../screens/profile_screen.dart';
import '../../models/voucher_model.dart';
import '../../widgets/voucher_card_widget.dart';
import '../../services/vnpay_service.dart';
import '../../models/order_models.dart';
import '../../widgets/app_name_text.dart';
import '../payment/bank_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;
  String? _selectedVoucherId;
  VoucherModel? _selectedVoucher;
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  List<AddressModel> _addresses = [];
  List<PaymentMethodModel> _paymentMethods = [];
  AddressModel? _selectedAddress;
  PaymentMethodModel? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadData();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await JwtService.isAuthenticated();
    if (!isAuth) {
      // Navigate to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacementNamed(LoginScreen.routeName, arguments: 'checkout');
      });
      return;
    }

    // Get user info from token
    final token = await JwtService.getStoredToken();
    if (token != null) {
      final userInfo = JwtService.getUserFromToken(token);
      setState(() {
        _userInfo = userInfo;
        _isAuthenticated = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final addressesResponse = await ApiService.getAddresses(
        pageNumber: 1,
        pageSize: 10,
      );
      print('addressesResponse: $addressesResponse');
      print('addressesResponse.data: ${addressesResponse.data}');

      final paymentMethodsResponse = await ApiService.getPaymentMethods(
        pageNumber: 1,
        pageSize: 10,
      );

      if (mounted) {
        setState(() {
          if (addressesResponse.success && addressesResponse.data != null) {
            // Sắp xếp địa chỉ: isDefault=true lên đầu
            final allAddresses = List<AddressModel>.from(
              addressesResponse.data!.items,
            );
            allAddresses.sort(
              (a, b) => b.isDefault ? 1 : (a.isDefault ? -1 : 0),
            );
            // Nếu có địa chỉ mặc định, chọn nó, nếu không thì chọn địa chỉ đầu tiên
            _addresses = allAddresses;
            _selectedAddress =
                _addresses.isNotEmpty
                    ? (_addresses.firstWhere(
                      (address) => address.isDefault,
                      orElse: () => _addresses.first,
                    ))
                    : null;
            print('Parsed addresses: ${_addresses.length}');
          }

          if (paymentMethodsResponse.success &&
              paymentMethodsResponse.data != null) {
            _paymentMethods = paymentMethodsResponse.data!.items;
            if (_paymentMethods.isNotEmpty) {
              _selectedPaymentMethod = _paymentMethods.first;
            }
          }

          _isLoading = false;
        });
      }

      print('Addresses in state: ${_addresses.length}');
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'Đã xảy ra lỗi khi tải dữ liệu: ${e.toString()}',
          isError: true,
          fct: () {},
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                'Đang xác thực...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    print('Addresses in build: ${_addresses.length}');

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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Consumer2<CartProvider, ProductsProvider>(
                  builder: (context, cartProvider, productsProvider, child) {
                    final cartItems = cartProvider.getCartitems.values.toList();
                    final totalAmount = cartProvider.getTotal(
                      productsProvider: productsProvider,
                    );

                    if (cartItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyBold.bag,
                              size: 80,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 16),
                            const TitlesTextWidget(
                              label: 'Giỏ hàng của bạn trống',
                              fontSize: 18,
                            ),
                            const SizedBox(height: 8),
                            const SubtitleTextWidget(
                              label: 'Thêm một số sản phẩm để bắt đầu',
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tiếp tục mua sắm'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Info Card
                          if (_userInfo != null) _buildUserInfoCard(),
                          const SizedBox(height: 20),

                          // Delivery Address Section
                          const TitlesTextWidget(
                            label: 'Địa chỉ giao hàng',
                            fontSize: 18,
                          ),
                          const SizedBox(height: 8),
                          if (_addresses.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SubtitleTextWidget(
                                    label:
                                        'Không tìm thấy địa chỉ. Vui lòng thêm một địa chỉ.',
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.person),
                                    label: const Text(
                                      'Đến trang Hồ sơ để thêm địa chỉ',
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const ProfileScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _addresses.length,
                              itemBuilder: (context, index) {
                                final address = _addresses[index];
                                final isSelected =
                                    _selectedAddress?.id == address.id;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ListTile(
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedAddress = address;
                                      });
                                    },
                                    title: Text(
                                      address.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(address.phoneNumber),
                                        Text(
                                          '${address.streetNumber}, ${address.addressLine1}, ${address.ward}, ${address.city}, ${address.province}',
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        isSelected
                                            ? Icon(
                                              Icons.check_circle,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            )
                                            : null,
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 24),

                          // Payment Method Section
                          const TitlesTextWidget(
                            label: 'Phương thức thanh toán',
                            fontSize: 18,
                          ),
                          const SizedBox(height: 8),
                          if (_paymentMethods.isEmpty)
                            const Center(
                              child: SubtitleTextWidget(
                                label: 'Không có phương thức thanh toán nào.',
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _paymentMethods.length,
                              itemBuilder: (context, index) {
                                final method = _paymentMethods[index];
                                final isSelected =
                                    _selectedPaymentMethod?.id == method.id;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ListTile(
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedPaymentMethod = method;
                                      });
                                    },
                                    leading: Image.network(
                                      method.imageUrl,
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.payment,
                                          size: 40,
                                        );
                                      },
                                    ),
                                    title: Text(
                                      method.paymentType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing:
                                        isSelected
                                            ? Icon(
                                              Icons.check_circle,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            )
                                            : null,
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 24),

                          // Voucher Selection
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TitlesTextWidget(
                                    label: 'Mã giảm giá',
                                    fontSize: 18,
                                  ),
                                  const SizedBox(height: 12),
                                  VoucherCardWidget(
                                    selectedVoucher: _selectedVoucher,
                                    orderTotal: totalAmount,
                                    onVoucherChanged: (voucher) {
                                      setState(() {
                                        _selectedVoucher = voucher;
                                        _selectedVoucherId = voucher?.id;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Order Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TitlesTextWidget(
                                    label: 'Tóm tắt đơn hàng',
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      // Get product details using the product ID
                                      final product = productsProvider
                                          .findByProdId(item.productId);

                                      // Sử dụng thông tin trực tiếp từ CartModel và chỉ sử dụng productsProvider làm backup
                                      String itemName = item.title;
                                      String imageUrl =
                                          item.productImageUrl; // Sử dụng hình ảnh từ giỏ hàng

                                      // Hiển thị biến thể từ dữ liệu giỏ hàng
                                      String itemVariation = '';
                                      if (item
                                          .variationOptionValues
                                          .isNotEmpty) {
                                        itemVariation =
                                            'Phiên bản: ${item.variationOptionValues.join(", ")}';
                                      }

                                      // Backup: Nếu không có thông tin trong CartModel, thử lấy từ ProductsProvider
                                      if (imageUrl.isEmpty && product != null) {
                                        imageUrl = product.productImage;

                                        // Try to get the specific product item configuration
                                        if (product.productItems.isNotEmpty) {
                                          final productItem = product
                                              .productItems
                                              .firstWhere(
                                                (prodItem) =>
                                                    prodItem.id ==
                                                    item.productItemId,
                                                orElse:
                                                    () =>
                                                        product
                                                            .productItems
                                                            .first,
                                              );

                                          // Use the product item's image if available
                                          if (productItem.imageUrl.isNotEmpty) {
                                            imageUrl = productItem.imageUrl;
                                          }

                                          // Get the variation details if not already set
                                          if (itemVariation.isEmpty &&
                                              productItem
                                                  .configurations
                                                  .isNotEmpty) {
                                            itemVariation = productItem
                                                .configurations
                                                .map(
                                                  (config) =>
                                                      "${config.variationName}: ${config.optionName}",
                                                )
                                                .join(", ");
                                          }
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product image
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                              child:
                                                  imageUrl.isNotEmpty
                                                      ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.network(
                                                          imageUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              color:
                                                                  Colors.grey,
                                                              size: 30,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                      : const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                        size: 30,
                                                      ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Product info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    itemName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (itemVariation
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      itemVariation,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.color,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'SL: ${item.quantity}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Price
                                            Text(
                                              CurrencyFormatter.formatVND(
                                                item.price * item.quantity,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('Tạm tính'),
                                    trailing: Text(
                                      CurrencyFormatter.formatVND(totalAmount),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  if (_selectedVoucher != null) ...[
                                    ListTile(
                                      title: Text(
                                        'Giảm giá (${_selectedVoucher!.code})',
                                      ),
                                      trailing: Text(
                                        '- ${CurrencyFormatter.formatVND(_selectedVoucher!.calculateDiscount(totalAmount))}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                  ListTile(
                                    title: const Text(
                                      'Tổng thanh toán',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      CurrencyFormatter.formatVND(
                                        totalAmount -
                                            (_selectedVoucher
                                                    ?.calculateDiscount(
                                                      totalAmount,
                                                    ) ??
                                                0),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Place Order Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _selectedAddress == null ||
                                          _selectedPaymentMethod == null
                                      ? null
                                      : _placeOrder,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Đặt hàng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child:
                _userInfo!['avatarUrl'] != null
                    ? ClipOval(
                      child: Image.network(
                        _userInfo!['avatarUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            IconlyBold.profile,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                    )
                    : Icon(
                      IconlyBold.profile,
                      color: Theme.of(context).primaryColor,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitlesTextWidget(
                  label: _userInfo!['userName'] ?? 'User',
                  fontSize: 16,
                ),
                SubtitleTextWidget(
                  label: _userInfo!['email'] ?? '',
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra các điều kiện
    if (_selectedPaymentMethod == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: 'Vui lòng chọn phương thức thanh toán',
        isError: true,
        fct: () {},
      );
      return;
    }

    if (_selectedAddress == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: 'Vui lòng chọn địa chỉ giao hàng',
        isError: true,
        fct: () {},
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.getCartitems.values.toList();

    if (cartItems.isEmpty) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: 'Giỏ hàng trống',
        isError: true,
        fct: () {},
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chuẩn bị dữ liệu order (raw map)
      final orderDetails =
          cartItems
              .map(
                (item) => {
                  'productItemId': item.productItemId,
                  'quantity': item.quantity,
                },
              )
              .toList();

      final orderData = {
        'addressId': _selectedAddress!.id,
        'paymentMethodId': _selectedPaymentMethod!.id,
        'voucherId': _selectedVoucherId,
        'OrderDetail': orderDetails,
      };

      final response = await ApiService.createOrderRaw(orderData);

      if (response.success && response.data != null) {
        final orderId = response.data!.orderId;
        final totalAmount = response.data!.totalAmount;

        // Check if payment method is VNPay
        if (VNPayService.isVNPayPayment(_selectedPaymentMethod!.paymentType)) {
          // Get user ID from token
          final token = await JwtService.getStoredToken();
          final userInfo =
              token != null ? JwtService.getUserFromToken(token) : null;
          final userId = userInfo?['id'] ?? '';

          if (userId.isEmpty) {
            if (mounted) {
              MyAppFunctions.showErrorOrWarningDialog(
                context: context,
                subtitle: 'Không thể xác định thông tin người dùng',
                isError: true,
                fct: () {},
              );
            }
            return;
          }

          // Process VNPay payment
          final vnpayResponse = await VNPayService.processVNPayPayment(
            orderId: orderId,
            userId: userId,
          );

          if (vnpayResponse.success) {
            if (mounted) {
              // Show a message that we are redirecting
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang chuyển hướng đến VNPay...'),
                  backgroundColor: Colors.blue,
                ),
              );

              // Clear cart after successful order creation
              Future.microtask(() {
                cartProvider.clearLocalCart();
              });

              // DO NOT navigate here. The deep link handler will do it.
            }
          } else {
            if (mounted) {
              // Show an error dialog if payment initiation fails
              MyAppFunctions.showErrorOrWarningDialog(
                context: context,
                subtitle:
                    vnpayResponse.message ??
                    'Không thể khởi tạo thanh toán VNPay.',
                isError: true,
                fct: () {},
              );
            }
          }
        } else {
          // Non-VNPay payment method - check if it's BANK payment
          if (_selectedPaymentMethod!.paymentType.toUpperCase() == 'BANK') {
            // Nếu là thanh toán qua ngân hàng, chuyển đến màn hình QR Bank
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BankPaymentScreen(
                    order: response.data!,
                  ),
                ),
              );
              // Xóa giỏ hàng trong một microtask để tránh vấn đề rebuild
              Future.microtask(() {
                cartProvider.clearLocalCart();
              });
            }
          } else {
            // Non-VNPay và non-BANK payment method - proceed with normal flow
            if (mounted) {
              // Chuyển hướng đến trang success
              Navigator.pushReplacementNamed(context, '/order-success');
              // Xóa giỏ hàng trong một microtask để tránh vấn đề rebuild
              Future.microtask(() {
                cartProvider.clearLocalCart();
              });
            }
          }
        }
      } else {
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: response.message ?? 'Đã xảy ra lỗi khi tạo đơn hàng',
            isError: true,
            fct: () {},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'Đã xảy ra lỗi khi tạo đơn hàng: ${e.toString()}',
          isError: true,
          fct: () {},
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
