import '../models/transaction_model.dart';
import '../services/transaction_signalr_service.dart';
import '../services/api_service.dart';
import '../models/api_response_model.dart';

class TransactionRepository {
  final TransactionSignalRService _signalRService;

  // Cho phép dependency injection để dễ kiểm thử
  TransactionRepository({TransactionSignalRService? signalRService})
    : _signalRService = signalRService ?? TransactionSignalRService();

  // Thiết lập callback xử lý khi giao dịch được cập nhật
  void setTransactionUpdatedCallback(Function(TransactionDto) callback) {
    _signalRService.onTransactionUpdated = callback;
  }

  // Thiết lập callback xử lý khi có lỗi
  void setErrorCallback(Function(String) callback) {
    _signalRService.onError = callback;
  }

  // Kết nối đến SignalR hub
  Future<bool> connect() async {
    return await _signalRService.connect();
  }

  // Ngắt kết nối với SignalR hub
  Future<void> disconnect() async {
    await _signalRService.disconnect();
  }

  // Đăng ký theo dõi giao dịch
  Future<bool> registerTransactionWatch(
    String transactionId,
    String userId,
  ) async {
    return await _signalRService.registerTransactionWatch(
      transactionId,
      userId,
    );
  }

  // Kết nối lại với SignalR hub
  Future<bool> reconnect() async {
    return await _signalRService.reconnect();
  }

  // Tạo yêu cầu thanh toán cho phân tích da
  Future<ApiResponse<TransactionDto>> createSkinAnalysisPayment() async {
    return await ApiService.createSkinAnalysisPayment();
  }
}
