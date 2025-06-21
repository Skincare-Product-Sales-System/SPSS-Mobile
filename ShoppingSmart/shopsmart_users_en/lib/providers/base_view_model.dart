import 'package:flutter/material.dart';
import '../services/error_handling_service.dart';
import '../services/service_locator.dart';

/// Lớp cơ sở cho các ViewModel, cung cấp các chức năng chung
///
/// Các lớp con cần phải định nghĩa loại T là loại của State
abstract class BaseViewModel<T> with ChangeNotifier {
  T _state;

  // Service xử lý lỗi
  final ErrorHandlingService _errorHandlingService;

  /// Constructor nhận state ban đầu và các dependencies tùy chọn
  BaseViewModel(this._state, {ErrorHandlingService? errorHandlingService})
    : _errorHandlingService =
          errorHandlingService ?? sl<ErrorHandlingService>();

  /// Getter cho state hiện tại
  T get state => _state;

  /// Phương thức cập nhật state và thông báo cho người nghe
  /// Các lớp con nên gọi phương thức này thay vì cập nhật _state trực tiếp
  @protected
  void updateState(T newState) {
    _state = newState;
    notifyListeners();
  }

  /// Phương thức cập nhật state mà không thông báo cho người nghe
  /// Hữu ích khi muốn cập nhật state mà không gây ra rebuild
  @protected
  void updateStateWithoutNotify(T newState) {
    _state = newState;
  }

  /// Phương thức giải phóng tài nguyên
  /// Các lớp con cần override phương thức này để giải phóng tài nguyên
  @override
  void dispose() {
    super.dispose();
  }

  /// Phương thức xử lý lỗi cơ bản sử dụng ErrorHandlingService
  /// Các lớp con có thể override phương thức này để xử lý lỗi theo cách phù hợp
  @protected
  void handleError(
    dynamic error, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    // Sử dụng service để xử lý lỗi tập trung
    final errorSource = source ?? runtimeType.toString();
    _errorHandlingService.handleError(
      error,
      source: errorSource,
      severity: severity,
    );
  }
}
