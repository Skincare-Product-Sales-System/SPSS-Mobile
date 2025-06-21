import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../models/order_models.dart';
import '../../providers/enhanced_order_view_model.dart';
import '../../providers/order_state.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../services/currency_formatter.dart';

class EnhancedOrderDetailScreen extends StatelessWidget {
  static const routeName = '/enhanced-order-detail';
  final String orderId;

  const EnhancedOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedOrderViewModel, OrderState>(
      title: 'Chi tiết đơn hàng',
      onInit: (viewModel) => viewModel.loadOrderDetail(orderId),
      isLoading: (viewModel) => viewModel.isLoadingOrderDetail,
      getErrorMessage:
          (viewModel) =>
              viewModel.state.selectedOrder.hasError
                  ? viewModel.state.selectedOrder.message
                  : null,
      buildAppBar: (context, viewModel) => _buildAppBar(context),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      onRefresh: (viewModel) => viewModel.loadOrderDetail(orderId),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(title: const Text('Chi tiết đơn hàng'), elevation: 0);
  }

  Widget _buildContent(BuildContext context, EnhancedOrderViewModel viewModel) {
    final orderDetail = viewModel.selectedOrder;
    if (orderDetail == null) {
      return const Center(child: Text('Không tìm thấy thông tin đơn hàng'));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildOrderStatusCard(context, orderDetail),
          if (orderDetail.statusChanges.isNotEmpty)
            _buildStatusTimeline(context, orderDetail.statusChanges),
          _buildOrderSummaryCard(context, orderDetail),
          _buildShippingAddressCard(context, orderDetail),
          _buildOrderItemsCard(context, orderDetail),
          _buildOrderActionsCard(context, orderDetail, viewModel),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(
    BuildContext context,
    List<StatusChangeModel> statusChanges,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Lịch sử đơn hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statusChanges.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == statusChanges.length - 1;
              final statusChange = statusChanges[index];

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.2,
                isFirst: isFirst,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 20,
                  color: isLast ? Colors.green : Theme.of(context).primaryColor,
                  iconStyle: IconStyle(
                    color: Colors.white,
                    iconData: isLast ? Icons.check : Icons.circle,
                    fontSize: isLast ? 14 : 12,
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _translateStatus(statusChange.status),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(statusChange.date),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                startChild: Center(
                  child: Text(
                    _formatTimeOnly(statusChange.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(
    BuildContext context,
    OrderDetailModel orderDetail,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(orderDetail.status),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateStatus(orderDetail.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cập nhật: ${_formatDateTime(orderDetail.createdTime)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Section for order ID
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mã đơn hàng',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        orderDetail.id,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: orderDetail.id),
                        ).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã sao chép mã đơn hàng vào clipboard',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 22,
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    BuildContext context,
    OrderDetailModel orderDetail,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tóm tắt đơn hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Tổng tiền gốc:',
              CurrencyFormatter.formatVND(orderDetail.originalOrderTotal),
            ),
            if (orderDetail.voucherCode != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                'Mã giảm giá:',
                orderDetail.voucherCode!,
                valueColor: Colors.green,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                'Giảm giá:',
                '- ${CurrencyFormatter.formatVND(orderDetail.discountAmount)}',
                valueColor: Colors.green,
              ),
            ],
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              'Tổng thanh toán:',
              CurrencyFormatter.formatVND(orderDetail.discountedOrderTotal),
              isTotal: true,
              valueColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard(
    BuildContext context,
    OrderDetailModel orderDetail,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              orderDetail.address.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(orderDetail.address.phoneNumber),
            const SizedBox(height: 8),
            Text(
              '${orderDetail.address.addressLine1}, '
              '${orderDetail.address.ward}, '
              '${orderDetail.address.city}, '
              '${orderDetail.address.province}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(
    BuildContext context,
    OrderDetailModel orderDetail,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sản phẩm đã mua',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderDetail.orderDetails.length,
              itemBuilder: (context, index) {
                final item = orderDetail.orderDetails[index];
                return _buildOrderItemCard(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(BuildContext context, OrderDetail item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.productImage,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (item.variationOptionValues.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variationOptionValues.join(", "),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.formatVND(item.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('SL: ${item.quantity}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActionsCard(
    BuildContext context,
    OrderDetailModel orderDetail,
    EnhancedOrderViewModel viewModel,
  ) {
    // Hiển thị nút hủy đơn hàng chỉ khi đơn hàng đang ở trạng thái có thể hủy
    final canCancel = _canCancelOrder(orderDetail.status);

    if (!canCancel) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thao tác',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed:
                    () => _confirmCancelOrder(context, orderDetail, viewModel),
                child: const Text(
                  'Hủy đơn hàng',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancelOrder(
    BuildContext context,
    OrderDetailModel orderDetail,
    EnhancedOrderViewModel viewModel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận hủy đơn hàng'),
            content: const Text(
              'Bạn có chắc chắn muốn hủy đơn hàng này? '
              'Hành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Có, hủy đơn hàng'),
              ),
            ],
          ),
    );

    if (result == true) {
      final success = await viewModel.cancelOrder(orderDetail.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã hủy đơn hàng thành công'
                  : 'Không thể hủy đơn hàng. Vui lòng thử lại sau.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          viewModel.loadOrderDetail(orderDetail.id);
        }
      }
    }
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting payment':
        return Icons.payment;
      case 'processing':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.inventory;
      case 'shipped':
      case 'shipping':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.money_off;
      case 'returned':
        return Icons.keyboard_return;
      default:
        return Icons.info;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting payment':
        return 'Chờ thanh toán';
      case 'processing':
        return 'Đang xử lý';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'shipped':
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'returned':
        return 'Đã trả hàng';
      case 'refund pending':
        return 'Đang chờ hoàn tiền';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Chuyển đổi sang múi giờ Việt Nam (UTC+7)
    final vietnamTime = dateTime.add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy - HH:mm').format(vietnamTime);
  }

  String _formatTimeOnly(DateTime dateTime) {
    // Chuyển đổi sang múi giờ Việt Nam (UTC+7)
    final vietnamTime = dateTime.add(const Duration(hours: 7));
    return DateFormat('HH:mm').format(vietnamTime);
  }

  bool _canCancelOrder(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'awaiting payment' ||
        lowerStatus == 'processing' ||
        lowerStatus == 'confirmed';
  }
}
