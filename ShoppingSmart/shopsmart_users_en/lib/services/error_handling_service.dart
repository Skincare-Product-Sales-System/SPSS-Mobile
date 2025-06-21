import 'dart:io';
import 'package:flutter/material.dart';
import 'app_logger.dart';
import 'navigation_service.dart';
import 'service_locator.dart';

/// Mức độ nghiêm trọng của lỗi
enum ErrorSeverity {
  /// Lỗi nhẹ, không ảnh hưởng đến luồng chính của ứng dụng
  low,

  /// Lỗi trung bình, có thể ảnh hưởng đến một số chức năng
  medium,

  /// Lỗi nghiêm trọng, ảnh hưởng đến toàn bộ ứng dụng
  high,

  /// Lỗi nghiêm trọng không thể khôi phục
  critical,
}

/// Service xử lý lỗi tập trung cho toàn bộ ứng dụng
class ErrorHandlingService {
  final NavigationService _navigationService;
  final AppLogger _logger;

  // Constructor có thể inject các dependencies
  ErrorHandlingService({
    NavigationService? navigationService,
    AppLogger? logger,
  }) : _navigationService = navigationService ?? sl<NavigationService>(),
       _logger = logger ?? sl<AppLogger>();

  /// Xử lý lỗi với các cấp độ khác nhau
  void handleError(
    dynamic error, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final errorMessage = error.toString();
    final sourceInfo = source != null ? '[$source]' : '';

    // Log lỗi
    debugPrint('ERROR $sourceInfo: $errorMessage');

    // Xử lý theo mức độ nghiêm trọng
    switch (severity) {
      case ErrorSeverity.low:
        // Chỉ log lỗi, không hiển thị gì cho người dùng
        break;

      case ErrorSeverity.medium:
        // Hiển thị snackbar nếu có context
        if (_navigationService.navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(
            _navigationService.navigatorKey.currentContext!,
          ).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: $errorMessage'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        break;

      case ErrorSeverity.high:
        // Hiển thị dialog thông báo lỗi
        if (_navigationService.navigatorKey.currentContext != null) {
          showDialog(
            context: _navigationService.navigatorKey.currentContext!,
            builder:
                (context) => AlertDialog(
                  title: const Text('Lỗi'),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
          );
        }
        break;

      case ErrorSeverity.critical:
        // Hiển thị dialog và điều hướng về trang chủ
        if (_navigationService.navigatorKey.currentContext != null) {
          showDialog(
            context: _navigationService.navigatorKey.currentContext!,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('Lỗi nghiêm trọng'),
                  content: Text(
                    '$errorMessage\n\nỨng dụng sẽ quay về trang chủ.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigationService.navigateToRoot();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
        break;
    }
  }

  /// Phân loại và trích xuất thông báo lỗi
  String _getErrorMessage(dynamic error, String? source) {
    if (error is SocketException) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (error is HttpException) {
      return 'Yêu cầu không hợp lệ. Vui lòng thử lại sau.';
    } else if (error is FormatException) {
      return 'Định dạng dữ liệu không hợp lệ. Vui lòng liên hệ hỗ trợ.';
    } else if (error is String) {
      return error;
    } else {
      return source != null
          ? 'Đã xảy ra lỗi tại $source'
          : 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
    }
  }
}
