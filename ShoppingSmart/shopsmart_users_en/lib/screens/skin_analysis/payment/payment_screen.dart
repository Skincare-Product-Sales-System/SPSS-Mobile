import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_provider.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_camera_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SkinAnalysisPaymentScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-payment';
  const SkinAnalysisPaymentScreen({super.key});

  @override
  State<SkinAnalysisPaymentScreen> createState() =>
      _SkinAnalysisPaymentScreenState();
}

class _SkinAnalysisPaymentScreenState extends State<SkinAnalysisPaymentScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SkinAnalysisProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán phân tích da'),
        centerTitle: true,
      ),
      body: Consumer<SkinAnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.status == SkinAnalysisStatus.initial ||
              provider.status == SkinAnalysisStatus.creatingPayment) {
            return _buildInitialPaymentView(provider);
          } else if (provider.status ==
              SkinAnalysisStatus.waitingForPaymentApproval) {
            return _buildWaitingForApprovalView(provider);
          } else if (provider.status == SkinAnalysisStatus.paymentApproved) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamed(SkinAnalysisCameraScreen.routeName);
              }
            });
            return _buildPaymentApprovedView();
          } else if (provider.status == SkinAnalysisStatus.error) {
            return _buildErrorView(provider);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildInitialPaymentView(SkinAnalysisProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Dịch vụ phân tích da',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Để sử dụng tính năng phân tích da chuyên sâu, bạn cần thanh toán phí dịch vụ. '
            'Sau khi thanh toán, bạn có thể chụp ảnh khuôn mặt để nhận kết quả phân tích chi tiết.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phí dịch vụ:', style: TextStyle(fontSize: 16)),
                    Text(
                      '20.000 VNĐ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Bao gồm:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Phân tích chi tiết tình trạng da',
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Đề xuất sản phẩm phù hợp',
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Lộ trình chăm sóc da cá nhân hóa',
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Lưu trữ kết quả phân tích',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  provider.status == SkinAnalysisStatus.creatingPayment
                      ? null
                      : () => _createPaymentRequest(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.3),
              ),
              child:
                  provider.status == SkinAnalysisStatus.creatingPayment
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang xử lý...'),
                        ],
                      )
                      : const Text(
                        'Thanh toán ngay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForApprovalView(SkinAnalysisProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang chờ xác nhận thanh toán',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vui lòng chuyển khoản theo thông tin bên dưới và chờ admin xác nhận. '
            'Hệ thống sẽ tự động cập nhật khi thanh toán được xác nhận.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Hiển thị thông tin giao dịch
          if (provider.currentTransaction != null) ...[
            // QR Code Image
            if (provider.currentTransaction!.qrImageUrl.isNotEmpty)
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: provider.currentTransaction!.qrImageUrl,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Không thể tải mã QR: $error'),
                        ],
                      ),
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 16),

            // Thông tin thanh toán
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin thanh toán:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentInfoRow(
                    'Số tiền:',
                    '${provider.currentTransaction!.amount.toStringAsFixed(0)} VNĐ',
                  ),
                  _buildPaymentInfoRow(
                    'Thông tin ngân hàng:',
                    provider.currentTransaction!.bankInformation,
                  ),
                  _buildPaymentInfoRow(
                    'Nội dung chuyển khoản:',
                    provider.currentTransaction!.description,
                  ),
                  _buildPaymentInfoRow(
                    'Mã giao dịch:',
                    provider.currentTransaction!.id,
                  ),
                  _buildPaymentInfoRow(
                    'Trạng thái:',
                    provider.currentTransaction!.status,
                    isStatus: true,
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Đang tải thông tin thanh toán...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(
    String label,
    String value, {
    bool isStatus = false,
  }) {
    Color valueColor =
        isStatus
            ? value.toLowerCase() == 'approved'
                ? Colors.green
                : value.toLowerCase() == 'pending'
                ? Colors.orange
                : Theme.of(context).textTheme.bodyLarge!.color!
            : Theme.of(context).textTheme.bodyLarge!.color!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: valueColor))),
        ],
      ),
    );
  }

  Widget _buildPaymentApprovedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text(
            'Thanh toán đã được xác nhận!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Cảm ơn bạn đã thanh toán. Bạn có thể tiến hành phân tích da ngay bây giờ.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorView(SkinAnalysisProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'Không thể xử lý yêu cầu của bạn.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  provider.resetState();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPaymentRequest(SkinAnalysisProvider provider) async {
    setState(() {
      _isLoading = true;
    });
    await provider.createPaymentRequest();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildServiceFeature({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
