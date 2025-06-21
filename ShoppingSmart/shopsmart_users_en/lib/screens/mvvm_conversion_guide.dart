import 'package:flutter/material.dart';

/// Hướng dẫn chuyển đổi màn hình sang kiến trúc MVVM
///
/// Tài liệu này mô tả các bước để chuyển đổi một màn hình hiện có sang kiến trúc MVVM.
class MvvmConversionGuide extends StatelessWidget {
  const MvvmConversionGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn chuyển đổi MVVM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hướng dẫn chuyển đổi màn hình sang MVVM',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSection(
              '1. Tạo State',
              'Tạo một lớp State để quản lý trạng thái của màn hình. '
                  'Lớp này nên được đặt trong thư mục lib/providers/. '
                  'Ví dụ: AuthState, CartState, ProductsState, v.v.',
            ),
            _buildSection(
              '2. Tạo ViewModel',
              'Tạo một lớp ViewModel kế thừa từ BaseViewModel. '
                  'Lớp này nên được đặt trong thư mục lib/providers/. '
                  'Ví dụ: EnhancedAuthViewModel, EnhancedCartViewModel, v.v.',
            ),
            _buildSection(
              '3. Đăng ký ViewModel',
              'Đăng ký ViewModel trong service_locator.dart và main.dart. '
                  'Trong service_locator.dart, sử dụng sl.registerFactory() để đăng ký ViewModel. '
                  'Trong main.dart, thêm ChangeNotifierProvider cho ViewModel.',
            ),
            _buildSection(
              '4. Tạo màn hình MVVM',
              'Tạo một màn hình mới sử dụng MvvmScreenTemplate. '
                  'Đặt tên màn hình với tiền tố "Enhanced" để phân biệt với màn hình cũ. '
                  'Ví dụ: EnhancedLoginScreen, EnhancedCartScreen, v.v.',
            ),
            _buildSection(
              '5. Chuyển đổi UI',
              'Chuyển đổi UI từ màn hình cũ sang màn hình mới. '
                  'Sử dụng MvvmScreenTemplate để xây dựng UI. '
                  'Đảm bảo UI mới có cùng chức năng với UI cũ.',
            ),
            _buildSection(
              '6. Chuyển đổi logic',
              'Chuyển đổi logic từ màn hình cũ sang ViewModel. '
                  'Đảm bảo logic mới có cùng chức năng với logic cũ. '
                  'Sử dụng các phương thức trong ViewModel để xử lý logic.',
            ),
            _buildSection(
              '7. Cập nhật routes',
              'Cập nhật routes trong main.dart để sử dụng màn hình mới. '
                  'Đảm bảo các màn hình khác vẫn có thể điều hướng đến màn hình mới.',
            ),
            _buildSection(
              '8. Kiểm thử',
              'Kiểm thử màn hình mới để đảm bảo nó hoạt động đúng. '
                  'Kiểm tra các trường hợp đặc biệt như loading, error, empty, v.v.',
            ),
            _buildSection(
              '9. Loại bỏ màn hình cũ',
              'Sau khi đã kiểm thử và đảm bảo màn hình mới hoạt động đúng, '
                  'có thể loại bỏ màn hình cũ và cập nhật tất cả các tham chiếu đến nó.',
            ),
            _buildSection(
              '10. Cập nhật tài liệu',
              'Cập nhật tài liệu để phản ánh các thay đổi. '
                  'Cập nhật mvvm_implementation_summary.md để ghi nhận màn hình đã được chuyển đổi.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Ví dụ mẫu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ví dụ 1: Màn hình đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCode('''
// 1. Tạo State
class AuthState {
  final ViewState<AuthResponse> loginState;
  final String? errorMessage;

  const AuthState({
    this.loginState = const ViewState<AuthResponse>(),
    this.errorMessage,
  });

  AuthState copyWith({
    ViewState<AuthResponse>? loginState,
    String? errorMessage,
  }) {
    return AuthState(
      loginState: loginState ?? this.loginState,
      errorMessage: errorMessage,
    );
  }
}

// 2. Tạo ViewModel
class EnhancedAuthViewModel extends BaseViewModel<AuthState> {
  final AuthRepository _authRepository;

  EnhancedAuthViewModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? sl<AuthRepository>(),
       super(const AuthState());

  Future<bool> login(String usernameOrEmail, String password) async {
    updateState(
      state.copyWith(
        loginState: ViewState.loading(),
        errorMessage: null,
      ),
    );

    try {
      final response = await _authRepository.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            loginState: ViewState.loaded(response.data!),
          ),
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
          loginState: ViewState.error(
            'Đã xảy ra lỗi khi đăng nhập',
          ),
          errorMessage: 'Đã xảy ra lỗi khi đăng nhập: \${error.toString()}',
        ),
      );
      return false;
    }
  }
}

// 3. Tạo màn hình MVVM
class EnhancedLoginScreen extends StatefulWidget {
  static const routeName = '/EnhancedLoginScreen';
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedAuthViewModel, AuthState>(
      title: 'Đăng nhập',
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      buildAppBar: (context, viewModel) => AppBar(
        title: const Text('Đăng nhập'),
        elevation: 0,
      ),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedAuthViewModel viewModel,
  ) {
    // Xây dựng UI
    return Container();
  }
}
'''),
            const SizedBox(height: 32),
            const Text(
              'Ví dụ 2: Màn hình tìm kiếm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCode('''
// 1. Cập nhật ProductsState để hỗ trợ tìm kiếm
class ProductsState {
  final ViewState<List<ProductModel>> products;
  final ViewState<List<ProductModel>> searchResults;
  final String? selectedCategoryId;
  final String? sortOption;
  final String? searchQuery;
  final bool isSearching;
  // ... các thuộc tính khác ...

  const ProductsState({
    this.products = const ViewState<List<ProductModel>>(),
    this.searchResults = const ViewState<List<ProductModel>>(),
    this.selectedCategoryId,
    this.sortOption,
    this.searchQuery,
    this.isSearching = false,
    // ... các tham số khác ...
  });

  // ... các phương thức khác ...
}

// 2. Cập nhật ViewModel để thêm các phương thức tìm kiếm
class EnhancedProductsViewModel extends BaseViewModel<ProductsState> {
  // ... các thuộc tính và phương thức khác ...

  /// Search products
  Future<void> searchProducts({required String searchText}) async {
    if (searchText.trim().isEmpty) {
      updateState(
        state.copyWith(
          searchResults: const ViewState<List<ProductModel>>(),
          searchQuery: '',
          isSearching: false,
        ),
      );
      return;
    }

    updateState(
      state.copyWith(
        searchResults: ViewState.loading(),
        searchQuery: searchText,
        isSearching: true,
      ),
    );

    try {
      final response = await _productRepository.searchProducts(
        searchQuery: searchText,
        pageNumber: 1,
        pageSize: 20,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            searchResults: ViewState.loaded(response.data!.items),
            isSearching: false,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            searchResults: ViewState.error(
              response.message ?? 'Failed to search products',
            ),
            isSearching: false,
          ),
        );
      }
    } catch (e) {
      updateState(
        state.copyWith(
          searchResults: ViewState.error(
            'Failed to search products: \${e.toString()}',
          ),
          isSearching: false,
        ),
      );
    }
  }

  /// Clear search results
  void clearSearchResults() {
    updateState(
      state.copyWith(
        searchResults: const ViewState<List<ProductModel>>(),
        searchQuery: '',
        isSearching: false,
      ),
    );
  }
}

// 3. Tạo màn hình tìm kiếm sử dụng MVVM
class EnhancedSearchScreen extends StatefulWidget {
  static const routeName = '/enhanced-search';
  final String? categoryName;

  const EnhancedSearchScreen({
    super.key,
    this.categoryName,
  });

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedProductsViewModel, ProductsState>(
      title: 'Tìm kiếm',
      buildAppBar: (context, viewModel) => _buildAppBar(context, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      isLoading: (viewModel) => viewModel.isSearching && viewModel.searchResults.isEmpty,
      isEmpty: (viewModel) => !viewModel.isSearching && 
                              viewModel.searchResults.isEmpty && 
                              viewModel.currentSearchQuery != null,
      getErrorMessage: (viewModel) => viewModel.hasSearchError ? viewModel.searchErrorMessage : null,
      buildEmpty: (context, viewModel) => _buildEmptyResults(context),
      onRefresh: (viewModel) async {
        if (viewModel.currentSearchQuery != null) {
          await viewModel.searchProducts(searchText: viewModel.currentSearchQuery!);
        }
      },
    );
  }

  // ... các phương thức xây dựng UI khác ...
}
'''),
            const SizedBox(height: 32),
            const Text(
              '## Chuyển đổi các màn hình phân tích da',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chúng ta đã chuyển đổi các màn hình phân tích da sang kiến trúc MVVM:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildSection(
              '1. **EnhancedSkinAnalysisIntroScreen**',
              'Sử dụng Consumer để lắng nghe các thay đổi từ EnhancedSkinAnalysisViewModel '
                  'UI không thay đổi so với phiên bản cũ '
                  'Điều hướng đến các màn hình MVVM khác',
            ),
            _buildSection(
              '2. **EnhancedPaymentScreen**',
              'Sử dụng Consumer để lắng nghe trạng thái thanh toán từ EnhancedSkinAnalysisViewModel '
                  'Hiển thị các view khác nhau dựa trên trạng thái (initial, waiting, approved, error) '
                  'Gọi các phương thức từ ViewModel thay vì xử lý trực tiếp',
            ),
            _buildSection(
              '3. **EnhancedSkinAnalysisCameraScreen**',
              'Sử dụng Consumer để lắng nghe trạng thái từ EnhancedSkinAnalysisViewModel '
                  'Hiển thị giao diện chụp ảnh hoặc đang phân tích dựa trên trạng thái '
                  'Gọi setSelectedImage và analyzeSkinWithPayment từ ViewModel',
            ),
            _buildSection(
              '4. **EnhancedSkinAnalysisResultScreen**',
              'Hiển thị kết quả phân tích da từ EnhancedSkinAnalysisViewModel '
                  'Xử lý các trạng thái khác nhau (loading, error, empty, loaded) '
                  'Hiển thị thông tin chi tiết về loại da, vấn đề da, sản phẩm đề xuất và lộ trình chăm sóc',
            ),
            _buildSection(
              '5. **EnhancedSkinAnalysisHistoryScreen**',
              'Hiển thị lịch sử phân tích da từ EnhancedSkinAnalysisViewModel '
                  'Hỗ trợ tải thêm dữ liệu khi cuộn xuống (infinite scrolling) '
                  'Xử lý các trạng thái khác nhau (loading, error, empty, loaded)',
            ),
            const SizedBox(height: 8),
            const Text(
              'Các màn hình này sử dụng EnhancedSkinAnalysisViewModel để quản lý trạng thái và logic nghiệp vụ.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'EnhancedSkinAnalysisViewModel sử dụng SkinAnalysisRepository để giao tiếp với API.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            const Text(
              '## Chuyển đổi màn hình chi tiết sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chúng ta đã chuyển đổi màn hình chi tiết sản phẩm sang kiến trúc MVVM:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildSection(
              '1. **EnhancedProductDetailsScreen**',
              'Sử dụng Consumer để lắng nghe các thay đổi từ EnhancedProductsViewModel '
                  'Hiển thị thông tin chi tiết sản phẩm, phân loại, đánh giá và các chức năng khác '
                  'Tách biệt UI và logic nghiệp vụ',
            ),
            _buildSection(
              '2. **Cập nhật EnhancedProductsViewModel**',
              'Thêm các phương thức để lấy chi tiết sản phẩm và đánh giá '
                  'Quản lý trạng thái loading, error, và data '
                  'Xử lý logic nghiệp vụ thay vì trong màn hình',
            ),
            _buildSection(
              '3. **Cập nhật ProductsState**',
              'Thêm các trường để lưu trữ chi tiết sản phẩm và đánh giá '
                  'Hỗ trợ lọc đánh giá theo số sao '
                  'Cung cấp các getter tiện ích',
            ),
            const SizedBox(height: 8),
            const Text(
              'Màn hình này sử dụng EnhancedProductsViewModel để quản lý trạng thái và logic nghiệp vụ.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'EnhancedProductsViewModel sử dụng ProductRepository để giao tiếp với API.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCode(String code) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        code,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      ),
    );
  }
}
