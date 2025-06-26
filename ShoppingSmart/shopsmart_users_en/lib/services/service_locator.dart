import 'package:get_it/get_it.dart';
import '../repositories/auth_repository.dart';
import '../repositories/blog_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/skin_analysis_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/viewed_products_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../providers/enhanced_products_view_model.dart';
import '../providers/enhanced_quiz_view_model.dart';
import '../providers/enhanced_skin_analysis_view_model.dart';
import '../providers/enhanced_viewed_products_provider.dart';
import '../providers/enhanced_order_view_model.dart';
import '../providers/enhanced_cart_view_model.dart';
import '../providers/enhanced_wishlist_view_model.dart';
import '../providers/enhanced_categories_view_model.dart';
import '../providers/enhanced_chat_view_model.dart';
import '../providers/enhanced_home_view_model.dart';
import '../providers/enhanced_profile_view_model.dart';
import '../providers/enhanced_auth_view_model.dart';
import '../providers/enhanced_brands_view_model.dart';
import '../providers/enhanced_skin_types_view_model.dart';
import 'api_client.dart';
import 'api_service.dart';
import 'app_logger.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'error_handling_service.dart';
import 'jwt_service.dart';
import 'navigation_service.dart';
import 'transaction_signalr_service.dart';
import '../repositories/brand_repository.dart';
import '../repositories/skin_type_repository.dart';
import '../repositories/review_repository.dart';
import '../providers/enhanced_user_reviews_view_model.dart';

final GetIt sl = GetIt.instance;

/// Khởi tạo tất cả dependencies cần thiết cho ứng dụng
Future<void> setupServiceLocator() async {
  // Services - Singleton
  sl.registerLazySingleton(
    () => ApiClient(baseUrl: 'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api'),
  );
  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ChatService());
  sl.registerLazySingleton(() => JwtService());
  sl.registerLazySingleton(() => AppLogger());
  sl.registerLazySingleton(() => TransactionSignalRService());
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton<ErrorHandlingService>(
    () => ErrorHandlingService(navigationService: sl<NavigationService>()),
  );

  // Repositories - Singleton
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => BlogRepository());
  sl.registerLazySingleton(() => CartRepository());
  sl.registerLazySingleton(() => CategoryRepository());
  sl.registerLazySingleton(() => OrderRepository());
  sl.registerLazySingleton(() => ProductRepository());
  sl.registerLazySingleton(() => QuizRepository());
  sl.registerLazySingleton(() => SkinAnalysisRepository());
  sl.registerLazySingleton(
    () =>
        TransactionRepository(signalRService: sl<TransactionSignalRService>()),
  );
  sl.registerLazySingleton(() => UserRepository());
  sl.registerLazySingleton(() => ViewedProductsRepository());
  sl.registerLazySingleton(() => WishlistRepository());
  sl.registerLazySingleton<BrandRepository>(() => BrandRepository());
  sl.registerLazySingleton<SkinTypeRepository>(() => SkinTypeRepository());
  sl.registerLazySingleton(() => ReviewRepository());

  // ViewModels - Factory (tạo mới mỗi khi yêu cầu)
  sl.registerFactory(
    () => EnhancedProductsViewModel(productRepository: sl<ProductRepository>()),
  );
  sl.registerFactory(
    () => EnhancedQuizViewModel(quizRepository: sl<QuizRepository>()),
  );
  sl.registerFactory(
    () => EnhancedSkinAnalysisViewModel(
      skinAnalysisRepository: sl<SkinAnalysisRepository>(),
      transactionRepository: sl<TransactionRepository>(),
    ),
  );
  sl.registerFactory(
    () => EnhancedViewedProductsProvider(
      viewedProductsRepository: sl<ViewedProductsRepository>(),
    ),
  );
  sl.registerFactory(
    () => EnhancedOrderViewModel(orderRepository: sl<OrderRepository>()),
  );
  sl.registerFactory(
    () => EnhancedCartViewModel(cartRepository: sl<CartRepository>()),
  );
  sl.registerFactory(
    () =>
        EnhancedWishlistViewModel(wishlistRepository: sl<WishlistRepository>()),
  );
  sl.registerFactory(
    () => EnhancedCategoriesViewModel(
      categoryRepository: sl<CategoryRepository>(),
    ),
  );
  sl.registerFactory(
    () => EnhancedChatViewModel(chatService: sl<ChatService>()),
  );

  sl.registerFactory(
    () => EnhancedHomeViewModel(
      productRepository: sl<ProductRepository>(),
      categoryRepository: sl<CategoryRepository>(),
      blogRepository: sl<BlogRepository>(),
    ),
  );

  sl.registerFactory(
    () => EnhancedProfileViewModel(userRepository: sl<UserRepository>()),
  );

  sl.registerFactory(
    () => EnhancedAuthViewModel(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<EnhancedBrandsViewModel>(
    () => EnhancedBrandsViewModel(brandRepository: sl<BrandRepository>()),
  );

  sl.registerFactory<EnhancedSkinTypesViewModel>(
    () => EnhancedSkinTypesViewModel(
      skinTypeRepository: sl<SkinTypeRepository>(),
    ),
  );

  // Add the UserReviews ViewModel
  sl.registerFactory(
    () => EnhancedUserReviewsViewModel(reviewRepository: sl<ReviewRepository>()),
  );
}
