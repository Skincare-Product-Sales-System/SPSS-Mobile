# Hướng dẫn kiến trúc MVVM trong ShopSmart

## Giới thiệu

Kiến trúc MVVM (Model-View-ViewModel) là một mẫu thiết kế phần mềm giúp tách biệt logic nghiệp vụ và giao diện người dùng, giúp code dễ bảo trì, kiểm thử và mở rộng. Tài liệu này mô tả cách triển khai MVVM trong dự án ShopSmart.

## Cấu trúc thư mục

```
lib/
  ├── models/             # Các model dữ liệu
  ├── repositories/       # Các repository giao tiếp với API và local storage
  ├── providers/          # ViewModels và State classes
  │   ├── base_view_model.dart
  │   ├── *_state.dart    # State classes
  │   └── enhanced_*_view_model.dart  # ViewModel classes
  ├── screens/            # Các màn hình (View)
  ├── services/           # Các service
  │   ├── api_service.dart
  │   ├── service_locator.dart
  │   └── ...
  └── widgets/            # Các widget tái sử dụng
```

## Các thành phần chính

### 1. Models

Models là các lớp đại diện cho dữ liệu trong ứng dụng. Chúng thường là các POJO (Plain Old Java Objects) hoặc các lớp immutable.

```dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  // ...
  
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    // ...
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ...
  }
}
```

### 2. Repositories

Repositories là lớp trung gian giữa ViewModels và nguồn dữ liệu (API, database, local storage). Chúng cung cấp các phương thức để truy xuất và cập nhật dữ liệu.

```dart
class ProductRepository {
  final ApiService _apiService;
  
  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? sl<ApiService>();
  
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _apiService.getProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
  
  // ...
}
```

### 3. ViewState

ViewState là lớp quản lý trạng thái của UI. Nó giúp xử lý các trạng thái như loading, error, success một cách nhất quán.

```dart
class ViewState<T> {
  final ViewStateStatus status;
  final T? data;
  final String? message;
  final List<String>? errors;
  
  const ViewState({
    this.status = ViewStateStatus.initial,
    this.data,
    this.message,
    this.errors,
  });
  
  factory ViewState.loading() => ViewState<T>(status: ViewStateStatus.loading);
  factory ViewState.loaded(T data) => ViewState<T>(status: ViewStateStatus.loaded, data: data);
  factory ViewState.error(String message) => ViewState<T>(status: ViewStateStatus.error, message: message);
  
  // ...
}
```

### 4. State Classes

State Classes là các lớp chứa trạng thái của một tính năng cụ thể. Chúng thường là immutable để dễ dàng theo dõi thay đổi.

```dart
class ProductsState {
  final ViewState<List<ProductModel>> products;
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;
  
  const ProductsState({
    this.products = const ViewState<List<ProductModel>>(),
    this.currentPage = 1,
    this.pageSize = 10,
    this.hasMoreData = true,
  });
  
  ProductsState copyWith({
    ViewState<List<ProductModel>>? products,
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,
  }) {
    return ProductsState(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
```

### 5. BaseViewModel

BaseViewModel là lớp cơ sở cho tất cả các ViewModel. Nó cung cấp các chức năng chung như quản lý state, xử lý lỗi.

```dart
abstract class BaseViewModel<T> with ChangeNotifier {
  T _state;
  final ErrorHandlingService _errorHandlingService;
  
  BaseViewModel(this._state, {ErrorHandlingService? errorHandlingService})
      : _errorHandlingService = errorHandlingService ?? sl<ErrorHandlingService>();
  
  T get state => _state;
  
  @protected
  void updateState(T newState) {
    _state = newState;
    notifyListeners();
  }
  
  @protected
  void handleError(dynamic error, {String? source, ErrorSeverity severity = ErrorSeverity.medium}) {
    _errorHandlingService.handleError(error, source: source, severity: severity);
  }
}
```

### 6. EnhancedViewModels

EnhancedViewModels là các lớp kế thừa từ BaseViewModel và cung cấp logic cụ thể cho từng tính năng.

```dart
class EnhancedProductsViewModel extends BaseViewModel<ProductsState> {
  final ProductRepository _productRepository;
  
  EnhancedProductsViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? sl<ProductRepository>(),
        super(const ProductsState());
        
  // Getters
  List<ProductModel> get products => state.products.data ?? [];
  bool get isLoading => state.products.isLoading;
  bool get hasError => state.products.hasError;
  
  Future<void> loadProducts({bool refresh = false, String? sortBy}) async {
    if (refresh) {
      updateState(
        state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
        ),
      );
    } else {
      updateState(
        state.copyWith(
          products: ViewState.loadingMore(state.products.data ?? []),
        ),
      );
    }
    
    try {
      final response = await _productRepository.getProducts(
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
        sortBy: sortBy,
      );
      
      if (response.success && response.data != null) {
        final newData = response.data!;
        final currentData = refresh ? [] : (state.products.data ?? []);
        final allProducts = [...currentData, ...newData.items];
        
        updateState(
          state.copyWith(
            products: ViewState.loaded(allProducts),
            currentPage: state.currentPage + 1,
            hasMoreData: newData.hasNextPage,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            products: ViewState.error(response.message ?? 'Không thể tải sản phẩm'),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'EnhancedProductsViewModel.loadProducts');
      updateState(
        state.copyWith(
          products: ViewState.error('Lỗi khi tải sản phẩm: ${e.toString()}'),
        ),
      );
    }
  }
}
```

### 7. Service Locator

Service Locator là một pattern giúp quản lý các dependency trong ứng dụng. Chúng ta sử dụng thư viện get_it để triển khai Service Locator.

```dart
final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton(() => ErrorHandlingService(navigationService: sl<NavigationService>()));
  
  // Repositories
  sl.registerLazySingleton(() => ProductRepository());
  sl.registerLazySingleton(() => CartRepository());
  
  // ViewModels
  sl.registerFactory(() => EnhancedProductsViewModel(productRepository: sl<ProductRepository>()));
  sl.registerFactory(() => EnhancedCartViewModel(cartRepository: sl<CartRepository>()));
}
```

### 8. Sử dụng trong View

Trong View (màn hình), chúng ta sử dụng Provider để truy cập ViewModel và hiển thị dữ liệu.

```dart
class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedProductsViewModel>(
      builder: (context, viewModel, child) {
        final products = viewModel.products;
        final isLoading = viewModel.isLoading;
        
        if (isLoading && products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (products.isEmpty) {
          return const Center(child: Text('Không có sản phẩm nào'));
        }
        
        return ListView.builder(
          itemCount: products.length + (viewModel.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              viewModel.loadMoreProducts();
              return const Center(child: CircularProgressIndicator());
            }
            
            final product = products[index];
            return ProductItem(product: product);
          },
        );
      },
    );
  }
}
```

## Quy trình phát triển tính năng mới

1. **Tạo Model**: Định nghĩa các model dữ liệu cần thiết.
2. **Tạo Repository**: Triển khai các phương thức để truy xuất và cập nhật dữ liệu.
3. **Tạo State Class**: Định nghĩa trạng thái của tính năng.
4. **Tạo ViewModel**: Triển khai logic nghiệp vụ và quản lý state.
5. **Đăng ký trong Service Locator**: Đăng ký Repository và ViewModel trong Service Locator.
6. **Tạo View**: Triển khai giao diện người dùng và sử dụng ViewModel.

## Lợi ích của kiến trúc MVVM

1. **Tách biệt rõ ràng các lớp**: Mỗi thành phần có trách nhiệm rõ ràng.
2. **Dễ kiểm thử**: ViewModel và Repository có thể được kiểm thử độc lập với UI.
3. **Dễ bảo trì**: Thay đổi một thành phần không ảnh hưởng đến các thành phần khác.
4. **Tái sử dụng code**: Repository và ViewModel có thể được sử dụng bởi nhiều View.
5. **Quản lý state tập trung**: ViewState giúp quản lý trạng thái UI một cách nhất quán.

## Kết luận

Kiến trúc MVVM giúp tổ chức code một cách rõ ràng, dễ bảo trì và mở rộng. Bằng cách tuân thủ các nguyên tắc và quy ước đã nêu trong tài liệu này, chúng ta có thể phát triển ứng dụng một cách hiệu quả và bền vững. 