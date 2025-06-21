# Hướng dẫn Dependency Injection trong ShopSmart

## Giới thiệu

Dependency Injection (DI) là một kỹ thuật thiết kế phần mềm giúp tách biệt việc tạo và sử dụng các đối tượng phụ thuộc. Trong ShopSmart, chúng ta sử dụng thư viện **GetIt** để triển khai Service Locator, một dạng của Dependency Injection.

## Lợi ích của Dependency Injection

1. **Tách biệt các thành phần**: Giảm sự phụ thuộc trực tiếp giữa các lớp
2. **Dễ dàng thay thế**: Có thể thay thế các implementation mà không cần thay đổi code sử dụng
3. **Dễ dàng kiểm thử**: Có thể mock các dependencies trong quá trình kiểm thử
4. **Quản lý vòng đời**: Kiểm soát vòng đời của các đối tượng (singleton, factory, etc.)
5. **Code sạch hơn**: Giảm code boilerplate và tăng tính tái sử dụng

## Service Locator với GetIt

Service Locator là một pattern giúp quản lý và cung cấp các dependencies trong ứng dụng. Trong ShopSmart, chúng ta sử dụng GetIt làm Service Locator.

### Thiết lập GetIt

File `lib/services/service_locator.dart` chứa thiết lập Service Locator:

```dart
import 'package:get_it/get_it.dart';
// Import các lớp cần đăng ký

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Đăng ký các dependencies
  
  // Services
  sl.registerLazySingleton(() => ApiClient(baseUrl: 'http://10.0.2.2:5041/api'));
  sl.registerLazySingleton(() => NavigationService());
  
  // Repositories
  sl.registerLazySingleton(() => ProductRepository(apiClient: sl()));
  
  // ViewModels
  sl.registerFactory(() => EnhancedProductsViewModel(productRepository: sl()));
}
```

### Khởi tạo Service Locator

Trong `main.dart`, chúng ta khởi tạo Service Locator trước khi chạy ứng dụng:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(MyApp());
}
```

## Các loại đăng ký trong GetIt

### 1. Singleton

Singleton là một đối tượng được tạo một lần và sử dụng lại trong toàn bộ ứng dụng.

```dart
// Đăng ký Singleton
sl.registerSingleton<ApiClient>(ApiClient());

// Đăng ký Lazy Singleton (chỉ tạo khi được yêu cầu lần đầu)
sl.registerLazySingleton<NavigationService>(() => NavigationService());
```

**Sử dụng cho**: Services, Repositories, và các đối tượng cần được chia sẻ toàn cục.

### 2. Factory

Factory tạo một instance mới mỗi khi được yêu cầu.

```dart
// Đăng ký Factory
sl.registerFactory<ProductsViewModel>(() => ProductsViewModel(repository: sl()));
```

**Sử dụng cho**: ViewModels và các đối tượng cần tạo mới mỗi khi sử dụng.

### 3. Factory với tham số

Factory có thể nhận tham số khi được gọi:

```dart
// Đăng ký Factory với tham số
sl.registerFactoryParam<ProductDetailViewModel, String, void>(
  (productId, _) => ProductDetailViewModel(productId: productId, repository: sl()),
);

// Sử dụng
final viewModel = sl<ProductDetailViewModel, String, void>(productId, null);
```

## Quy tắc đăng ký dependencies

Trong ShopSmart, chúng ta tuân theo các quy tắc sau khi đăng ký dependencies:

1. **Services**: Đăng ký dưới dạng Singleton hoặc LazySingleton
2. **Repositories**: Đăng ký dưới dạng Singleton hoặc LazySingleton
3. **ViewModels**: Đăng ký dưới dạng Factory
4. **Utils/Helpers**: Đăng ký dưới dạng Singleton hoặc LazySingleton

## Sử dụng dependencies trong code

### 1. Constructor Injection

Đây là cách ưu tiên để inject dependencies:

```dart
class ProductRepository {
  final ApiClient _apiClient;
  
  ProductRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? sl<ApiClient>();
      
  // Methods using _apiClient
}
```

### 2. Direct Injection

Sử dụng Service Locator trực tiếp:

```dart
class SomeClass {
  void someMethod() {
    final apiClient = sl<ApiClient>();
    // Use apiClient
  }
}
```

### 3. Provider với GetIt

Kết hợp Provider và GetIt:

```dart
ChangeNotifierProvider(
  create: (_) => sl<EnhancedProductsViewModel>(),
  child: ProductsScreen(),
),
```

## Kiểm thử với Dependency Injection

Dependency Injection giúp kiểm thử dễ dàng hơn bằng cách cho phép mock các dependencies:

```dart
void main() {
  late ProductRepository repository;
  late MockApiClient mockApiClient;
  
  setUp(() {
    mockApiClient = MockApiClient();
    repository = ProductRepository(apiClient: mockApiClient);
  });
  
  test('getProducts returns products when API call succeeds', () async {
    // Setup mock
    when(mockApiClient.getProducts())
        .thenAnswer((_) async => SuccessResponse([product1, product2]));
        
    // Call method
    final result = await repository.getProducts();
    
    // Verify
    expect(result.data, [product1, product2]);
  });
}
```

## Các lỗi thường gặp và cách khắc phục

### 1. Circular Dependencies

**Vấn đề**: A phụ thuộc vào B, B phụ thuộc vào A.

**Giải pháp**: Tái cấu trúc code để tránh phụ thuộc vòng, hoặc sử dụng interface để giảm sự phụ thuộc trực tiếp.

### 2. Unregistered Dependencies

**Vấn đề**: Cố gắng lấy một dependency chưa được đăng ký.

**Giải pháp**: Đảm bảo tất cả dependencies được đăng ký trước khi sử dụng, hoặc sử dụng `sl.isRegistered<T>()` để kiểm tra.

### 3. Singleton Lifecycle Issues

**Vấn đề**: Singleton giữ state quá lâu, gây memory leak hoặc lỗi logic.

**Giải pháp**: Sử dụng `sl.reset()` khi cần thiết (ví dụ: khi đăng xuất), hoặc sử dụng Factory thay vì Singleton.

## Tổng kết

Dependency Injection với GetIt giúp tổ chức code một cách rõ ràng, dễ bảo trì và kiểm thử. Bằng cách tuân theo các quy tắc và mẫu thiết kế đã nêu, ShopSmart có thể dễ dàng mở rộng và phát triển trong tương lai. 