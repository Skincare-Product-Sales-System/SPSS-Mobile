import '../models/view_state.dart';
import '../models/auth_models.dart';

/// State cho các màn hình xác thực
class AuthState {
  /// Trạng thái đăng nhập
  final ViewState<AuthResponse> loginState;

  /// Trạng thái đăng ký
  final ViewState<AuthResponse> registerState;

  /// Trạng thái quên mật khẩu
  final ViewState<bool> forgotPasswordState;

  /// Trạng thái đổi mật khẩu
  final ViewState<bool> changePasswordState;

  /// Thông báo lỗi
  final String? errorMessage;

  /// Constructor
  const AuthState({
    this.loginState = const ViewState<AuthResponse>(),
    this.registerState = const ViewState<AuthResponse>(),
    this.forgotPasswordState = const ViewState<bool>(),
    this.changePasswordState = const ViewState<bool>(),
    this.errorMessage,
  });

  /// Tạo bản sao với các giá trị mới
  AuthState copyWith({
    ViewState<AuthResponse>? loginState,
    ViewState<AuthResponse>? registerState,
    ViewState<bool>? forgotPasswordState,
    ViewState<bool>? changePasswordState,
    String? errorMessage,
  }) {
    return AuthState(
      loginState: loginState ?? this.loginState,
      registerState: registerState ?? this.registerState,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      changePasswordState: changePasswordState ?? this.changePasswordState,
      errorMessage: errorMessage,
    );
  }
}
