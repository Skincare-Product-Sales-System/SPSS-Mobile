import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../services/jwt_service.dart';
import '../../services/currency_formatter.dart';
import '../../screens/auth/login.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../models/order_models.dart';
import '../../services/api_service.dart';
import '../../services/my_app_function.dart';

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
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
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
                'Verifying authentication...',
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        centerTitle: true,
        title: const TitlesTextWidget(label: 'Checkout', fontSize: 22),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(IconlyLight.arrow_left_2, size: 24),
        ),
      ),
      body: _isLoading
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
                            label: 'Your cart is empty',
                            fontSize: 18,
                          ),
                          const SizedBox(height: 8),
                          const SubtitleTextWidget(
                            label: 'Add some products to get started',
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Continue Shopping'),
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

                        // Address Selection
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TitlesTextWidget(label: 'Delivery Address'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedAddressId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [], // TODO: Add address items
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAddressId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an address';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Selection
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TitlesTextWidget(label: 'Payment Method'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedPaymentMethodId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Payment Method',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [], // TODO: Add payment method items
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethodId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a payment method';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Voucher Selection (Optional)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TitlesTextWidget(label: 'Voucher (Optional)'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedVoucherId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Voucher',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [], // TODO: Add voucher items
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedVoucherId = value;
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
                                const TitlesTextWidget(label: 'Order Summary'),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    return ListTile(
                                      title: Text(item.productId),
                                      subtitle: Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Total'),
                                  trailing: Text(
                                    '\$${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Place Order Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Place Order',
                            style: TextStyle(fontSize: 18),
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

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.getCartitems.values.toList();

    setState(() {
      _isLoading = true;
    });

    try {
      final orderDetails = cartItems.map((item) {
        return OrderDetail(
          productItemId: item.productId,
          productId: item.productId,
          productName: item.title,
          productImage: '',
          quantity: item.quantity,
          price: item.price,
          variationOptionValues: [],
          isReviewable: false,
        );
      }).toList();

      final request = CreateOrderRequest(
        addressId: _selectedAddressId!,
        paymentMethodId: _selectedPaymentMethodId!,
        voucherId: _selectedVoucherId,
        orderDetails: orderDetails,
      );

      final response = await ApiService.createOrder(request);

      if (response.success) {
        // Clear cart after successful order
        cartProvider.clearLocalCart();

        // Show success message
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: 'Order placed successfully!',
            fct: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        }
      } else {
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: response.message,
            isError: true,
            fct: () {},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'An error occurred while creating order',
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
