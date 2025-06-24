import 'package:signalr_netcore/signalr_client.dart';
import '../models/transaction_model.dart';
import 'package:shopsmart_users_en/services/auth_service.dart';

class TransactionSignalRService {
  // Singleton instance
  static final TransactionSignalRService _instance =
      TransactionSignalRService._internal();
  factory TransactionSignalRService() => _instance;
  TransactionSignalRService._internal();

  // Signalr kết nối
  HubConnection? _connection;
  bool _connected = false;
  bool _isConnecting = false; // Biến để theo dõi việc đang kết nối
  bool get isConnected => _connected;

  // Các callback handlers
  Function(String)? onError;
  Function(TransactionDto)? onTransactionUpdated;

  // Id người dùng
  String? userId;

  // Url đến SignalR hub
  final String hubUrl = 'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/transactionhub';

  // Kết nối đến hub
  Future<bool> connect() async {
    // Nếu đã kết nối, trả về true ngay lập tức
    if (_connection != null && _connected) {
      print('SignalR đã kết nối, không cần kết nối lại');
      return true;
    }

    // Nếu đang trong quá trình kết nối, đợi và trả về kết quả
    if (_isConnecting) {
      print('SignalR đang trong quá trình kết nối, đợi...');
      // Đợi tối đa 5 giây
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_connected) {
          return true;
        }
      }
      return _connected;
    }

    _isConnecting = true;
    print('Bắt đầu kết nối đến SignalR hub');

    try {
      // Lấy JWT token
      String? token = await AuthService.getStoredToken();
      if (token == null) {
        if (onError != null) {
          onError!('Không tìm thấy token người dùng');
        }
        _isConnecting = false;
        return false;
      }

      final httpConnectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => token,
      );

      _connection =
          HubConnectionBuilder()
              .withUrl(hubUrl, options: httpConnectionOptions)
              .withAutomaticReconnect()
              .build();

      // Xử lý sự kiện cập nhật giao dịch
      _connection!.on('TransactionUpdated', (List<Object?>? args) {
        if (args != null && args.isNotEmpty && args[0] != null) {
          try {
            print('Nhận được sự kiện TransactionUpdated từ server');
            final Map<String, dynamic> transactionData =
                args[0] as Map<String, dynamic>;
            final transaction = TransactionDto.fromJson(transactionData);
            print(
              'Dữ liệu giao dịch: ID=${transaction.id}, Status=${transaction.status}',
            );
            if (onTransactionUpdated != null) {
              onTransactionUpdated!(transaction);
            }
          } catch (e) {
            print('Lỗi xử lý sự kiện TransactionUpdated: $e');
            if (onError != null) {
              onError!('Lỗi xử lý dữ liệu giao dịch: $e');
            }
          }
        }
      });

      await _connection!.start();
      _connected = true;
      _isConnecting = false;
      print('Kết nối SignalR thành công');
      return true;
    } catch (e) {
      print('Lỗi kết nối đến SignalR hub: $e');
      _connected = false;
      _isConnecting = false;
      if (onError != null) {
        onError!(e.toString());
      }
      return false;
    }
  }

  // Đăng ký theo dõi giao dịch
  Future<bool> registerTransactionWatch(
    String transactionId,
    String userId,
  ) async {
    if (!isConnected || _connection == null) {
      if (await connect() == false) {
        return false;
      }
    }

    try {
      await _connection!.invoke(
        'RegisterTransactionWatch',
        args: [transactionId, userId],
      );
      return true;
    } catch (e) {
      if (onError != null) {
        onError!('Lỗi khi đăng ký theo dõi giao dịch: $e');
      }
      return false;
    }
  }

  // Ngắt kết nối
  Future<void> disconnect() async {
    if (_connection != null && _connected) {
      await _connection!.stop();
      _connected = false;
      print('Đã ngắt kết nối SignalR');
    }
  }

  // Ngắt kết nối và đăng ký lại
  Future<bool> reconnect() async {
    await disconnect();
    return await connect();
  }
}
