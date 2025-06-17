import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../models/order_models.dart';
import '../../services/api_service.dart';
import '../../services/jwt_service.dart';
import '../../services/currency_formatter.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../services/my_app_function.dart';
import '../../screens/auth/login.dart';
import '../../screens/orders/order_detail_screen.dart';

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
    'Tất cả',
    'Đang xử lý',
    'Đã hủy',
    'Chờ thanh toán',
    'Đã hoàn tiền',
    'Đang giao hàng',
    'Đã giao hàng',
    'Đã trả hàng',
    'Đang chờ hoàn tiền',
  ];
  String _selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
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
        status:
            _selectedStatus == 'Tất cả'
                ? null
                : _convertStatusToEnglish(_selectedStatus),
      );

      print('Orders API Response: ${response.toString()}'); // Debug log

      if (response.success && response.data != null) {
        try {
          print('Response data: ${response.data}'); // Debug log
          print('Response items: ${response.data!.items}'); // Debug log

          final orders = response.data!.items;
          print('Final orders list: ${orders.length} orders'); // Debug log

          if (mounted) {
            setState(() {
              _orders = orders;
              _totalPages = response.data!.totalPages;
              _hasMore = _currentPage < _totalPages;
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Error processing orders: $e'); // Debug log
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
        print('API response not successful: ${response.message}'); // Debug log
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
      print('Error loading orders: $e'); // Debug log
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
        status:
            _selectedStatus == 'Tất cả'
                ? null
                : _convertStatusToEnglish(_selectedStatus),
      );

      print(
        'Load More Orders API Response: ${response.toString()}',
      ); // Debug log

      if (response.success && response.data != null) {
        try {
          print('Load more data: ${response.data}'); // Debug log
          print('Load more items: ${response.data!.items}'); // Debug log

          final newOrders = response.data!.items;
          print(
            'Final new orders list: ${newOrders.length} orders',
          ); // Debug log

          if (mounted) {
            setState(() {
              _orders.addAll(newOrders);
              _currentPage++;
              _hasMore = _currentPage < _totalPages;
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Error processing more orders: $e'); // Debug log
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
        print(
          'Load more API response not successful: ${response.message}',
        ); // Debug log
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
      print('Error loading more orders: $e'); // Debug log
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle:
              'An error occurred while loading more orders: ${e.toString()}',
          isError: true,
          fct: () {},
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _convertStatusToEnglish(String vietnameseStatus) {
    switch (vietnameseStatus) {
      case 'Đang xử lý':
        return 'processing';
      case 'Đã hủy':
        return 'cancelled';
      case 'Chờ thanh toán':
        return 'awaiting payment';
      case 'Đã hoàn tiền':
        return 'refunded';
      case 'Đang giao hàng':
        return 'shipping';
      case 'Đã giao hàng':
        return 'delivered';
      case 'Đã trả hàng':
        return 'returned';
      case 'Đang chờ hoàn tiền':
        return 'refund pending';
      default:
        return vietnameseStatus.toLowerCase();
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

  String _translateStatusToVietnamese(String englishStatus) {
    String status = englishStatus.toLowerCase();
    switch (status) {
      case 'processing':
        return 'Đang xử lý';
      case 'cancelled':
        return 'Đã hủy';
      case 'awaiting payment':
        return 'Chờ thanh toán';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'returned':
        return 'Đã trả hàng';
      case 'refund pending':
        return 'Đang chờ hoàn tiền';
      default:
        return status.toUpperCase();
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
        title: const TitlesTextWidget(label: 'Đơn hàng của tôi', fontSize: 22),
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
              children:
                  _statusOptions.map((status) {
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
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
            child:
                _isLoading && _orders.isEmpty
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
                            label: 'Chưa có đơn hàng nào',
                            fontSize: 18,
                          ),
                          const SizedBox(height: 8),
                          const SubtitleTextWidget(
                            label: 'Lịch sử đơn hàng của bạn sẽ hiển thị ở đây',
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  OrderDetailScreen.routeName,
                                  arguments: order.id,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Đơn hàng #${order.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                _getStatusColor(
                                                  order.status,
                                                ).replaceAll('#', '0xFF'),
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _translateStatusToVietnamese(
                                              order.status,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ngày: ${order.createdAt.toString().split('.')[0]}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(),
                                    ...order.orderDetails.map(
                                      (detail) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                detail.productName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              'x${detail.quantity}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              CurrencyFormatter.formatVND(
                                                detail.price,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tổng cộng:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatVND(
                                            order.totalAmount,
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
