import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_analysis_view_model.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_state.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_camera_screen.dart';
import 'package:shopsmart_users_en/services/currency_formatter.dart';
import 'package:shopsmart_users_en/repositories/transaction_repository.dart';

class EnhancedPaymentScreen extends StatefulWidget {
  static const routeName = '/enhanced-skin-analysis-payment';
  const EnhancedPaymentScreen({super.key});

  @override
  State<EnhancedPaymentScreen> createState() => _EnhancedPaymentScreenState();
}

class _EnhancedPaymentScreenState extends State<EnhancedPaymentScreen> {
  bool _isLoading = false;
  bool _isNavigating = false; // Flag to prevent multiple navigation attempts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Center(
                  child: Text(
                    'Thanh toán phân tích da',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<EnhancedSkinAnalysisViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          if (state.status == AnalysisStatus.initial ||
              state.status == AnalysisStatus.creatingPayment) {
            return _buildInitialPaymentView(viewModel);
          } else if (state.status == AnalysisStatus.waitingForPaymentApproval) {
            return _buildWaitingForApprovalView(viewModel);
          } else if (state.status == AnalysisStatus.paymentApproved) {
            // Only navigate once when payment is approved
            if (!_isNavigating) {
              _isNavigating = true;
              // Use a longer delay to ensure the UI has time to update
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  // Navigate to camera screen with replacement to prevent going back
                  Navigator.of(context).pushReplacementNamed(
                    EnhancedSkinAnalysisCameraScreen.routeName,
                  );
                }
              });
            }
            return _buildPaymentApprovedView();
          } else if (state.status == AnalysisStatus.error) {
            return _buildErrorView(viewModel);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildInitialPaymentView(EnhancedSkinAnalysisViewModel viewModel) {
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
              gradient: const LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: const Text(
              'Dịch vụ phân tích da',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Để sử dụng tính năng phân tích da chuyên sâu, bạn cần thanh toán phí dịch vụ. Sau khi thanh toán, bạn có thể chụp ảnh khuôn mặt để nhận kết quả phân tích chi tiết.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí dịch vụ:', style: TextStyle(fontSize: 17)),
                    Text(
                      '${CurrencyFormatter.formatNumber(20000.0)} VNĐ',
                      style: const TextStyle(
                        fontSize: 17,
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Phân tích chi tiết tình trạng da',
                  iconColor: Colors.green,
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Đề xuất sản phẩm phù hợp',
                  iconColor: Colors.green,
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Lộ trình chăm sóc da cá nhân hóa',
                  iconColor: Colors.green,
                ),
                _buildServiceFeature(
                  icon: Icons.check_circle,
                  text: 'Lưu trữ kết quả phân tích',
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: ElevatedButton(
                onPressed: viewModel.state.status == AnalysisStatus.creatingPayment ? null : () => _createPaymentRequest(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.state.status == AnalysisStatus.creatingPayment
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForApprovalView(EnhancedSkinAnalysisViewModel viewModel) {
    final transaction = viewModel.state.currentTransaction;

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
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top,
              size: 50,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang chờ xác nhận thanh toán',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          if (transaction != null) ...[
            // QR Code Image
            if (transaction.qrImageUrl.isNotEmpty)
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
                  imageUrl: transaction.qrImageUrl,
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
                    '${CurrencyFormatter.formatNumber(transaction.amount)} VNĐ',
                  ),
                  _buildPaymentInfoRow(
                    'Thông tin ngân hàng:',
                    transaction.bankInformation,
                  ),
                  _buildPaymentInfoRow(
                    'Nội dung chuyển khoản:',
                    transaction.description,
                  ),
                  _buildPaymentInfoRow('Mã giao dịch:', transaction.id),
                  _buildPaymentInfoRow(
                    'Trạng thái:',
                    transaction.status,
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Thanh toán thành công!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cảm ơn bạn đã thanh toán. Bạn sẽ được chuyển đến trang chụp ảnh ngay bây giờ.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorView(EnhancedSkinAnalysisViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error, size: 60, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.state.errorMessage ??
                  'Không thể xử lý thanh toán. Vui lòng thử lại sau.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  viewModel.updateState(
                    viewModel.state.copyWith(
                      status: AnalysisStatus.initial,
                      errorMessage: null,
                    ),
                  );
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

  Widget _buildServiceFeature({required IconData icon, required String text, Color iconColor = const Color(0xFF8F5CFF)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPaymentRequest(
    EnhancedSkinAnalysisViewModel viewModel,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cập nhật trạng thái để hiển thị loading
      viewModel.updateState(
        viewModel.state.copyWith(status: AnalysisStatus.creatingPayment),
      );

      // Kết nối đến SignalR
      final connected = await viewModel.connectToSignalR();
      if (!connected) {
        throw Exception('Không thể kết nối đến máy chủ thông báo');
      }

      // Tạo một đối tượng TransactionRepository để gọi API
      final transactionRepository = TransactionRepository();

      // Gọi API tạo giao dịch thanh toán
      final result = await transactionRepository.createSkinAnalysisPayment();

      if (result.success && result.data != null) {
        // Cập nhật transaction vào state
        viewModel.updateState(
          viewModel.state.copyWith(
            status: AnalysisStatus.waitingForPaymentApproval,
            currentTransaction: result.data,
          ),
        );

        // Đăng ký theo dõi giao dịch
        await viewModel.registerTransactionWatch(
          result.data!.id,
          result.data!.userId,
        );
      } else {
        // Xử lý lỗi
        viewModel.updateState(
          viewModel.state.copyWith(
            status: AnalysisStatus.error,
            errorMessage: result.message ?? 'Không thể tạo yêu cầu thanh toán',
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      viewModel.updateState(
        viewModel.state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Lỗi khi tạo yêu cầu thanh toán: $e',
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
