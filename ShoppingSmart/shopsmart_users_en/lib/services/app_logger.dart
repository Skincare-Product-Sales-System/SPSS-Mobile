import 'package:flutter/foundation.dart';

/// Định nghĩa các mức độ log
enum LogLevel {
  /// Thông tin chi tiết, chỉ hữu ích khi debug
  verbose,

  /// Thông tin chung
  info,

  /// Cảnh báo không nghiêm trọng
  warning,

  /// Lỗi nghiêm trọng
  error,

  /// Lỗi rất nghiêm trọng
  critical,
}

/// Service ghi log cho ứng dụng
class AppLogger {
  /// Singleton instance
  static final AppLogger _instance = AppLogger._internal();

  /// Factory constructor
  factory AppLogger() => _instance;

  /// Private constructor
  AppLogger._internal();

  /// Mức log tối thiểu sẽ được hiển thị
  LogLevel _minimumLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;

  /// Thiết lập mức log tối thiểu
  void setMinimumLogLevel(LogLevel level) {
    _minimumLevel = level;
  }

  /// Ghi log với mức Verbose
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message, tag, error, stackTrace);
  }

  /// Ghi log với mức Info
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag, error, stackTrace);
  }

  /// Ghi log với mức Warning
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag, error, stackTrace);
  }

  /// Ghi log với mức Error
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, error, stackTrace);
  }

  /// Ghi log với mức Critical
  void c(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag, error, stackTrace);
  }

  /// Phương thức ghi log nội bộ
  void _log(
    LogLevel level,
    String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Kiểm tra xem có nên ghi log không
    if (level.index < _minimumLevel.index) {
      return;
    }

    // Định dạng tag
    final logTag = tag != null ? '[$tag]' : '';

    // Định dạng timestamp
    final timestamp = DateTime.now().toIso8601String();

    // Định dạng mức log
    final levelStr = _getLevelString(level);

    // Tạo thông điệp log
    final logMessage = '$timestamp $levelStr $logTag $message';

    // In ra console
    debugPrint(logMessage);

    // In ra error và stack trace nếu có
    if (error != null) {
      debugPrint('ERROR: $error');
    }

    if (stackTrace != null) {
      debugPrint('STACK TRACE: \n$stackTrace');
    }

    // Ở đây có thể thêm mã gửi log đến dịch vụ bên ngoài như Firebase Crashlytics
    // hoặc lưu vào file nếu cần thiết
  }

  /// Chuyển đổi mức log thành chuỗi
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '[VERBOSE]';
      case LogLevel.info:
        return '[INFO   ]';
      case LogLevel.warning:
        return '[WARNING]';
      case LogLevel.error:
        return '[ERROR  ]';
      case LogLevel.critical:
        return '[CRITICAL]';
    }
  }
}
