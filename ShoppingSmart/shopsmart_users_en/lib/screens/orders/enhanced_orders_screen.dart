import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../models/order_models.dart';
import '../../providers/enhanced_order_view_model.dart';
// Removed unused import
import '../../services/jwt_service.dart';
import '../../services/navigation_service.dart';
import '../../services/service_locator.dart';
import '../../widgets/title_text.dart';
import '../../screens/auth/login.dart';
import '../../screens/orders/enhanced_order_detail_screen.dart';
// Removed unused import

class EnhancedOrdersScreen extends StatefulWidget {
  static const routeName = '/enhanced-orders';

  const EnhancedOrdersScreen({super.key});

  @override
  State<EnhancedOrdersScreen> createState() => _EnhancedOrdersScreenState();
}

class _EnhancedOrdersScreenState extends State<EnhancedOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAuthenticated = false;

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
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final viewModel = Provider.of<EnhancedOrderViewModel>(
        context,
        listen: false,
      );
      if (viewModel.state.hasMoreData &&
          !viewModel.state.orders.isLoadingMore) {
        viewModel.loadMoreOrders();
      }
    }
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await JwtService.isAuthenticated();
    if (!isAuth) {
      if (mounted) {
        sl<NavigationService>().navigateTo(LoginScreen.routeName);
      }
      return;
    }

    setState(() {
      _isAuthenticated = true;
    });

    // Tải đơn hàng ban đầu
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!_isAuthenticated) return;

    final viewModel = Provider.of<EnhancedOrderViewModel>(
      context,
      listen: false,
    );

    await viewModel.loadOrders(
      refresh: true,
      status: _selectedStatus == 'Tất cả' ? null : _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Use custom scaffold instead of MvvmScreenTemplate to have more control
    return Consumer<EnhancedOrderViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh:
                () => viewModel.loadOrders(
                  refresh: true,
                  status: _selectedStatus == 'Tất cả' ? null : _selectedStatus,
                ),
            child: Column(
              children: [
                // Filter row is always visible
                _buildStatusFilterRow(context, viewModel),
                const SizedBox(height: 10),

                // Content area
                Expanded(
                  child:
                      viewModel.isLoading && viewModel.orders.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.state.orders.hasError
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  viewModel.state.orders.message ??
                                      'Đã xảy ra lỗi',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed:
                                      () => viewModel.loadOrders(
                                        refresh: true,
                                        status:
                                            _selectedStatus == 'Tất cả'
                                                ? null
                                                : _selectedStatus,
                                      ),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          )
                          : viewModel.orders.isEmpty
                          ? _selectedStatus == 'Tất cả'
                              ? _buildEmptyState()
                              : _buildEmptyFilterResult(context)
                          : _buildOrdersList(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(IconlyLight.arrow_left_2, size: 24, color: Colors.white),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: TitlesTextWidget(
                    label: 'Đơn hàng của tôi',
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow(
    BuildContext context,
    EnhancedOrderViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: _statusOptions.map((status) {
            final isSelected = _selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(
                  status,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF8F5CFF) : Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = status;
                    });
                    viewModel
                        .loadOrders(
                          refresh: true,
                          status: status == 'Tất cả' ? null : status,
                        )
                        .then((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                  }
                },
                backgroundColor: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(const Rect.fromLTWH(0, 0, 120, 40)) !=
                            null
                        ? Colors.transparent
                        : const Color(0xFFF3EDFF)
                    : const Color(0xFFF3EDFF),
                selectedColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSelected
                      ? const BorderSide(color: Color(0xFF8F5CFF), width: 2)
                      : BorderSide.none,
                ),
                elevation: isSelected ? 2 : 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                showCheckmark: false,
                // Custom gradient background for selected
                avatar: isSelected
                    ? Container(
                        width: 0,
                        height: 0,
                        decoration: const BoxDecoration(),
                      )
                    : null,
                clipBehavior: Clip.antiAlias,
                // Nếu muốn gradient thực sự, cần custom widget, ở đây dùng border và chữ màu tím đậm
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyFilterResult(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy đơn hàng nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_selectedStatus != 'Tất cả')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Thử chọn trạng thái khác',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    EnhancedOrderViewModel viewModel,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount:
          viewModel.orders.length +
          (viewModel.state.orders.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.orders.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final order = viewModel.orders[index];
        return _buildOrderItem(context, order, viewModel);
      },
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    OrderModel order,
    EnhancedOrderViewModel viewModel,
  ) {
    final statusColor = viewModel.getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => EnhancedOrderDetailScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đơn hàng #${order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      viewModel.getTranslatedStatus(order.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Order info
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày đặt: ${viewModel.formatDate(order.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Số sản phẩm: ${order.orderDetails.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order products preview
              if (order.orderDetails.isNotEmpty &&
                  order.orderDetails.length <= 3)
                ...order.orderDetails.map(
                  (detail) =>
                      _buildOrderItemPreview(context, detail, viewModel),
                ),

              if (order.orderDetails.length > 3)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...order.orderDetails
                        .take(2)
                        .map(
                          (detail) => _buildOrderItemPreview(
                            context,
                            detail,
                            viewModel,
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8),
                      child: Text(
                        '... và ${order.orderDetails.length - 2} sản phẩm khác',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),

              const Divider(height: 24),

              // Total and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền: ${viewModel.formatCurrency(order.totalAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EnhancedOrderDetailScreen(orderId: order.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Xem chi tiết'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemPreview(
    BuildContext context,
    OrderDetail detail,
    EnhancedOrderViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              image:
                  detail.productImage.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(detail.productImage),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                detail.productImage.isEmpty
                    ? Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 20,
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${detail.quantity} x ${viewModel.formatCurrency(detail.price)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn chưa có đơn hàng nào',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Hãy mua sắm và quay lại sau'),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(IconlyLight.bag_2),
            label: const Text('Tiếp tục mua sắm'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  } // Empty with filters is now built directly in the build method
}
