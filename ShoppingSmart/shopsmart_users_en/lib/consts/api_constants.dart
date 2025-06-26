class ApiConstants {
  // Base API URL
  static String baseUrl = 'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String userAddress = '/user/addresses';
  static const String userPaymentMethods = '/user/payment-methods';

  // Product endpoints
  static const String products = '/products';
  static const String productDetails = '/products';
  static const String productCategories = '/categories';
  static const String bestSellers = '/products/best-sellers';
  static const String latestProducts = '/products/latest';
  static const String searchProducts = '/products/search';

  // Cart endpoints
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Order endpoints
  static const String orders = '/orders';
  static const String orderDetails = '/orders';

  // Wishlist endpoints
  static const String wishlist = '/wishlist';
  static const String wishlistItems = '/wishlist/items';

  // Review endpoints
  static const String reviews = '/reviews';
  static const String productReviews = '/reviews/product';
  static const String userReviews = '/reviews/user';
  static const String reviewImages = '/reviews/images';

  // Blog endpoints
  static const String blogs = '/blogs';
  static const String blogDetails = '/blogs';

  // Quiz endpoints
  static const String quizzes = '/quizzes';
  static const String quizDetails = '/quizzes';
  static const String quizResults = '/quizzes/results';

  // Skin analysis endpoints
  static const String skinAnalysis = '/skin-analysis';
  static const String skinAnalysisHistory = '/skin-analysis/history';
  static const String skinAnalysisDetails = '/skin-analysis';

  // Brand endpoints
  static const String brands = '/brands';

  // Skin type endpoints
  static const String skinTypes = '/skin-types';

  // Chat endpoints
  static const String chat = '/chat';
  static const String chatMessages = '/chat/messages';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String createPaymentIntent = '/transactions/payment-intent';

  // Voucher endpoints
  static const String vouchers = '/vouchers';
}
