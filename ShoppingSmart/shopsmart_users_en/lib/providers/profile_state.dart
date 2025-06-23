import 'package:shopsmart_users_en/models/auth_models.dart';
import 'package:shopsmart_users_en/models/user_profile_model.dart';
import '../models/api_response_model.dart';
import '../models/view_state.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';

/// State cho màn hình Profile
class ProfileState {
  /// Trạng thái đăng nhập
  final bool isLoggedIn;

  /// Thông tin người dùng cơ bản
  final UserInfo? userInfo;

  /// Thông tin profile đầy đủ
  final ViewState<UserProfileModel> userProfile;

  /// Đang tải dữ liệu
  final bool isLoading;

  /// Đang cập nhật profile
  final bool isUpdating;

  /// Thông báo lỗi
  final String? errorMessage;

  /// User addresses
  final ViewState<PaginatedResponse<AddressModel>> addresses;

  /// Payment methods
  final ViewState<PaginatedResponse<PaymentMethodModel>> paymentMethods;

  /// Constructor
  const ProfileState({
    this.isLoggedIn = false,
    this.userInfo,
    this.userProfile = const ViewState<UserProfileModel>(),
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.addresses = const ViewState<PaginatedResponse<AddressModel>>(),
    this.paymentMethods =
        const ViewState<PaginatedResponse<PaymentMethodModel>>(),
  });

  /// Tạo bản sao với các giá trị mới
  ProfileState copyWith({
    bool? isLoggedIn,
    UserInfo? userInfo,
    ViewState<UserProfileModel>? userProfile,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    ViewState<PaginatedResponse<AddressModel>>? addresses,
    ViewState<PaginatedResponse<PaymentMethodModel>>? paymentMethods,
  }) {
    return ProfileState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userInfo: userInfo ?? this.userInfo,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  /// Clear error message
  ProfileState clearError() {
    return copyWith(errorMessage: null);
  }
}
