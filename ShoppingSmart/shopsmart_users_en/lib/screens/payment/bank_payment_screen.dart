import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/order_models.dart';
import '../../services/api_service.dart';
import '../checkout/enhanced_order_success_screen.dart';

class BankPaymentScreen extends StatefulWidget {
  final OrderResponse order;

  const BankPaymentScreen({super.key, required this.order});

  @override
  State<BankPaymentScreen> createState() => _BankPaymentScreenState();
}

class _BankPaymentScreenState extends State<BankPaymentScreen> {
  String? qrImageUrl;
  bool isLoading = true;
  String? errorMessage;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _startCheckingOrderStatus();
  }

  void _generateQRCode() {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Tạo URL QR code trực tiếp từ VietQR
      final bankId = '970422'; // Mã ngân hàng
      final accountNo = '0352314340'; // Số tài khoản
      final template = 'print';
      final amount = widget.order.totalAmount.toStringAsFixed(0);
      final description = Uri.encodeComponent(widget.order.orderId);
      final accountName = Uri.encodeComponent('DANG HO TUAN CUONG');

      final qrUrl =
          'https://img.vietqr.io/image/$bankId-$accountNo-$template.png?amount=$amount&addInfo=$description&accountName=$accountName';

      setState(() {
        qrImageUrl = qrUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi tạo mã QR. Vui lòng thử lại.';
        isLoading = false;
      });
    }
  }

  void _startCheckingOrderStatus() {
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final status = await _fetchOrderStatus();
      if (status != null && status.toLowerCase().trim() == 'processing') {
        _statusTimer?.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            EnhancedOrderSuccessScreen.routeName,
            arguments: widget.order.orderId,
          );
        }
      }
    });
  }

  Future<String?> _fetchOrderStatus() async {
    try {
      final resp = await ApiService.getOrderDetail(widget.order.orderId);
      if (resp.success && resp.data != null) {
        return resp.data!.status;
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán qua ngân hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin đơn hàng
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin đơn hàng',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mã đơn hàng:'),
                          Expanded(
                            child: Text(
                              widget.order.orderId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trạng thái:'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.order.status == 'Awaiting payment'
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.order.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    widget.order.status == 'Awaiting payment'
                                        ? Colors.orange[700]
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ngày tạo:'),
                          Text(
                            '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền:'),
                          Text(
                            '${widget.order.totalAmount.toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Thông tin thanh toán
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin thanh toán',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Ngân hàng:', 'MB Bank'),
                      _buildInfoRow('Số tài khoản:', '0352314340'),
                      _buildInfoRow('Tên tài khoản:', 'DANG HO TUAN CUONG'),
                      _buildInfoRow(
                        'Số tiền:',
                        '${widget.order.totalAmount.toStringAsFixed(0)} VNĐ',
                      ),
                      _buildInfoRow('Nội dung:', widget.order.orderId),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Mã QR
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Quét mã QR để thanh toán',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const SizedBox(
                          height: 320,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Đang tạo mã QR...'),
                              ],
                            ),
                          ),
                        )
                      else if (errorMessage != null)
                        SizedBox(
                          height: 320,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _generateQRCode,
                                  child: Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (qrImageUrl != null)
                        Center(
                          child: Image.network(
                            qrImageUrl!,
                            width: 280,
                            height: 280,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Không thể tải mã QR',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vui lòng mở ứng dụng ngân hàng và quét mã QR để thanh toán',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (label == 'Nội dung:') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 3,
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
