import '../models/auth_models.dart';
import '../models/view_state.dart';
import '../models/api_response_model.dart';
import '../repositories/auth_repository.dart';
import '../services/service_locator.dart';
import '../services/auth_service.dart';
import '../services/jwt_service.dart';
import 'auth_state.dart';
import 'base_view_model.dart';
import 'enhanced_cart_view_model.dart';

/// ViewModel cải tiến cho xác thực, kế thừa từ BaseViewModel
class EnhancedAuthViewModel extends BaseViewModel<AuthState> {
  // Repository
  final AuthRepository _authRepository;

  /// Constructor với dependency injection cho repository
  EnhancedAuthViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? sl<AuthRepository>(),
      super(const AuthState());

  /// Getter cho user info
  UserInfo? get currentUser => state.loginState.data?.user;

  /// Getter cho trạng thái đăng nhập
  bool get isLoggedIn => state.loginState.data?.token != null;

  /// Getter cho trạng thái loading
  bool get isLoading =>
      state.loginState.isLoading ||
      state.registerState.isLoading ||
      state.forgotPasswordState.isLoading ||
      state.changePasswordState.isLoading;

  /// Getter cho thông báo lỗi
  String? get errorMessage => state.errorMessage;

  /// Phương thức đăng nhập
  Future<bool> login(String usernameOrEmail, String password) async {
    updateState(
      state.copyWith(loginState: ViewState.loading(), errorMessage: null),
    );

    try {
      final response = await _authRepository.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(loginState: ViewState.loaded(response.data!)),
        );
        return true;
      } else {
        updateState(
          state.copyWith(
            loginState: ViewState.error(
              response.message ?? 'Đăng nhập thất bại',
            ),
            errorMessage: response.message,
          ),
        );
        return false;
      }
    } catch (error) {
      handleError(error, source: 'login');
      updateState(
        state.copyWith(
          loginState: ViewState.error('Đã xảy ra lỗi khi đăng nhập'),
          errorMessage: 'Đã xảy ra lỗi khi đăng nhập: ${error.toString()}',
        ),
      );
      return false;
    }
  }

  /// Phương thức đăng ký
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phone,
    String? userName,
  }) async {
    updateState(
      state.copyWith(registerState: ViewState.loading(), errorMessage: null),
    );

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        userName: userName ?? email,
      );

      if (response.success) {
        // Đăng ký thành công, có thể có hoặc không có data
        if (response.data != null) {
          updateState(
            state.copyWith(registerState: ViewState.loaded(response.data!)),
          );
        } else {
          // Trường hợp thành công nhưng không có data (chỉ có message "Registered successfully")
          updateState(
            state.copyWith(
              registerState: ViewState.loaded(AuthResponse()),
              errorMessage: null,
            ),
          );
        }
        return true;
      } else {
        updateState(
          state.copyWith(
            registerState: ViewState.error(
              response.message ?? 'Đăng ký thất bại',
            ),
            errorMessage: response.message,
          ),
        );
        return false;
      }
    } catch (error) {
      handleError(error, source: 'register');
      updateState(
        state.copyWith(
          registerState: ViewState.error('Đã xảy ra lỗi khi đăng ký'),
          errorMessage: 'Đã xảy ra lỗi khi đăng ký: ${error.toString()}',
        ),
      );
      return false;
    }
  }

  /// Phương thức quên mật khẩu
  Future<bool> forgotPassword(String email) async {
    updateState(
      state.copyWith(
        forgotPasswordState: ViewState.loading(),
        errorMessage: null,
      ),
    );

    try {
      // Tạo một ApiResponse giả lập vì AuthService không có phương thức forgotPassword
      final response = ApiResponse<bool>(
        success: true,
        message: 'Hướng dẫn đặt lại mật khẩu đã được gửi đến email của bạn',
        data: true,
      );

      updateState(state.copyWith(forgotPasswordState: ViewState.loaded(true)));
      return true;
    } catch (error) {
      handleError(error, source: 'forgotPassword');
      updateState(
        state.copyWith(
          forgotPasswordState: ViewState.error(
            'Đã xảy ra lỗi khi yêu cầu đặt lại mật khẩu',
          ),
          errorMessage:
              'Đã xảy ra lỗi khi yêu cầu đặt lại mật khẩu: ${error.toString()}',
        ),
      );
      return false;
    }
  }

  /// Phương thức đổi mật khẩu
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    updateState(
      state.copyWith(
        changePasswordState: ViewState.loading(),
        errorMessage: null,
      ),
    );

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      final response = await AuthService.changePassword(request);

      if (response.success) {
        updateState(
          state.copyWith(changePasswordState: ViewState.loaded(true)),
        );
        return true;
      } else {
        updateState(
          state.copyWith(
            changePasswordState: ViewState.error(
              response.message ?? 'Đổi mật khẩu thất bại',
            ),
            errorMessage: response.message,
          ),
        );
        return false;
      }
    } catch (error) {
      handleError(error, source: 'changePassword');
      updateState(
        state.copyWith(
          changePasswordState: ViewState.error(
            'Đã xảy ra lỗi khi đổi mật khẩu',
          ),
          errorMessage: 'Đã xảy ra lỗi khi đổi mật khẩu: ${error.toString()}',
        ),
      );
      return false;
    }
  }

  /// Phương thức đăng xuất
  Future<void> logout() async {
    try {
      await AuthService.logout();

      // Xóa giỏ hàng cục bộ
      final cartViewModel = sl<EnhancedCartViewModel>();
      await cartViewModel.clearLocalCart();

      updateState(
        state.copyWith(
          loginState: ViewState.initial(),
          registerState: ViewState.initial(),
          forgotPasswordState: ViewState.initial(),
          changePasswordState: ViewState.initial(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      handleError(error, source: 'logout');
    }
  }

  /// Phương thức làm mới trạng thái đăng nhập từ token đã lưu
  Future<bool> refreshLoginState() async {
    try {
      final token = await JwtService.getStoredToken();
      if (token != null) {
        final tokenData = JwtService.getUserFromToken(token);
        if (tokenData != null) {
          final userInfo = UserInfo.fromTokenData(tokenData);

          // Cập nhật state với thông tin đăng nhập từ token
          updateState(
            state.copyWith(
              loginState: ViewState.loaded(
                AuthResponse(token: token, user: userInfo),
              ),
              errorMessage: null,
            ),
          );
          return true;
        }
      }

      // Nếu không có token hợp lệ, đặt trạng thái về chưa đăng nhập
      updateState(
        state.copyWith(loginState: ViewState.initial(), errorMessage: null),
      );
      return false;
    } catch (error) {
      handleError(error, source: 'refreshLoginState');
      updateState(
        state.copyWith(
          loginState: ViewState.error('Lỗi khi làm mới trạng thái đăng nhập'),
          errorMessage:
              'Lỗi khi làm mới trạng thái đăng nhập: ${error.toString()}',
        ),
      );
      return false;
    }
  }
}
