import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import '../../models/order_models.dart';
import '../../services/api_service.dart';
import '../../services/jwt_service.dart';
import '../../services/currency_formatter.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../services/my_app_function.dart';
import '../../screens/auth/login.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  List<OrderModel> _orders = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Status filter
  final List<String> _statusOptions = [
    'All',
    'Processing',
    'Cancelled',
    'Awaiting Payment',
    'Refunded',
    'Shipping',
    'Delivered',
    'Returned',
    'Refund Pending',
  ];
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages && !_isLoading) {
        _loadMoreOrders();
      }
    }
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await JwtService.isAuthenticated();
    if (!isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      });
      return;
    }

    setState(() {
      _isAuthenticated = true;
    });
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!_isAuthenticated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getOrders(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
      );

      if (response.success && response.data != null) {
        try {
          final orders = response.data!.items;

          if (mounted) {
            setState(() {
              _orders = orders;
              _totalPages = response.data!.totalPages;
              _hasMore = _currentPage < _totalPages;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            MyAppFunctions.showErrorOrWarningDialog(
              context: context,
              subtitle: 'Error processing orders: ${e.toString()}',
              isError: true,
              fct: () {},
            );
          }
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: response.message ?? 'Failed to load orders',
            isError: true,
            fct: () {},
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'An error occurred while loading orders: ${e.toString()}',
          isError: true,
          fct: () {},
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getOrders(
        pageNumber: _currentPage + 1,
        pageSize: _pageSize,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
      );

      if (response.success && response.data != null) {
        try {
          final newOrders = response.data!.items;

          if (mounted) {
            setState(() {
              _orders.addAll(newOrders);
              _currentPage++;
              _hasMore = _currentPage < _totalPages;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            MyAppFunctions.showErrorOrWarningDialog(
              context: context,
              subtitle: 'Error processing more orders: ${e.toString()}',
              isError: true,
              fct: () {},
            );
          }
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: response.message ?? 'Failed to load more orders',
            isError: true,
            fct: () {},
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'An error occurred while loading more orders: ${e.toString()}',
          isError: true,
          fct: () {},
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'processing':
        return '#1E90FF'; // Dodger Blue
      case 'shipped':
        return '#4169E1'; // Royal Blue
      case 'delivered':
        return '#32CD32'; // Lime Green
      case 'cancelled':
        return '#FF0000'; // Red
      default:
        return '#808080'; // Gray
    }
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
        title: const TitlesTextWidget(label: 'My Orders', fontSize: 22),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(IconlyLight.arrow_left_2, size: 24),
        ),
      ),
      body: Column(
        children: [
          // Status filter row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                          _currentPage = 1;
                        });
                        _loadOrders();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Expanded order list
          Expanded(
            child: _isLoading && _orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? Center(
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
                              label: 'No orders yet',
                              fontSize: 18,
                            ),
                            const SizedBox(height: 8),
                            const SubtitleTextWidget(
                              label: 'Your order history will appear here',
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _currentPage = 1;
                          await _loadOrders();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _orders.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final order = _orders[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Order #${order.id}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(_getStatusColor(order.status).replaceAll('#', '0xFF'))),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Date: ${order.createdAt.toString().split('.')[0]}', style: TextStyle(color: Colors.grey[700])),
                                    const SizedBox(height: 8),
                                    Divider(),
                                    if (order.orderDetails.isNotEmpty)
                                    ...order.orderDetails.map((detail) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                                detail.productName?.toString() ?? '[Không có tên sản phẩm]',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                            Text('x${detail.quantity.toString()}', style: const TextStyle(fontSize: 13)),
                                          const SizedBox(width: 8),
                                          Text(
                                            CurrencyFormatter.formatVND(detail.price),
                                            style: const TextStyle(fontSize: 13, color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                      ))
                                    else
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text('Không có chi tiết sản phẩm', style: TextStyle(color: Colors.grey)),
                                      ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          CurrencyFormatter.formatVND(order.totalAmount),
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 