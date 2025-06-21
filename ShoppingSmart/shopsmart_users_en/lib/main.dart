import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:shopsmart_users_en/providers/enhanced_auth_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_cart_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_categories_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_chat_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_home_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_order_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_products_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_profile_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_quiz_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_analysis_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_viewed_products_provider.dart';
import 'package:shopsmart_users_en/providers/enhanced_wishlist_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_brands_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_types_view_model.dart';
import 'package:shopsmart_users_en/providers/theme_provider.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/auth/enhanced_login.dart';
import 'package:shopsmart_users_en/screens/simple_search_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_all_products_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_quiz_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_quiz_question_screen.dart';
import 'package:shopsmart_users_en/screens/orders/enhanced_orders_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_intro_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_camera_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_result_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_history_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_history_detail_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/payment/enhanced_payment_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_chat_ai_screen.dart';
import 'package:shopsmart_users_en/services/service_locator.dart';
import 'package:shopsmart_users_en/services/navigation_service.dart';
import 'package:shopsmart_users_en/services/api_service.dart';
import 'package:shopsmart_users_en/services/jwt_service.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_wishlist.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_reviews_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_product_detail.dart';
import 'screens/profile/enhanced_edit_profile_screen.dart';
import 'screens/profile/enhanced_address_screen.dart';
import 'screens/checkout/enhanced_checkout_screen.dart';
import 'screens/orders/enhanced_order_detail_screen.dart';
import 'screens/enhanced_chat_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_offers_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_viewed_recently.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_blog_detail.dart';
import 'package:shopsmart_users_en/screens/checkout/enhanced_order_success_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/vnpay_success_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/vnpay_failure_screen.dart';
import 'screens/auth/enhanced_register.dart';
import 'screens/auth/enhanced_forgot_password.dart';
import 'screens/auth/enhanced_change_password.dart';

import 'consts/theme_data.dart';
// Các providers đã được thay thế bằng MVVM providers mới
// import 'providers/cart_provider.dart';
// import 'providers/viewed_recently_provider.dart';
// import 'providers/wishlist_provider.dart';

void main() async {
  // Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Main: Flutter binding initialized");

  try {
    // Khởi tạo Service Locator
    debugPrint("Main: Setting up service locator");
    await setupServiceLocator();
    debugPrint("Main: Service locator setup completed");

    runApp(const MyApp());
    debugPrint("Main: App started");
  } catch (e, stackTrace) {
    debugPrint("Main: Error during initialization: $e");
    debugPrint(stackTrace.toString());
    // Create a minimal app that displays the error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Initialization Error",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    // Listen for incoming deep links
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri != null && uri.scheme == 'spss' && uri.host == 'vnpay-return') {
        handleVnPayDeepLink(uri);
      }
    });

    // Get the initial deep link if the app was opened with one
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (!mounted) return;
      if (initialUri != null &&
          initialUri.scheme == 'spss' &&
          initialUri.host == 'vnpay-return') {
        handleVnPayDeepLink(initialUri);
      }
    } catch (e) {
      // Handle error
    }
  }

  void handleVnPayDeepLink(Uri uri) async {
    final orderId = uri.queryParameters['id'];
    if (orderId == null) return;

    // Thêm delay để backend có thời gian cập nhật trạng thái đơn hàng
    await Future.delayed(const Duration(seconds: 2));

    // Gọi API backend để lấy trạng thái đơn hàng thực tế
    final orderDetailResponse = await ApiService.getOrderDetail(orderId);
    String? orderStatus;
    if (orderDetailResponse.success && orderDetailResponse.data != null) {
      orderStatus = orderDetailResponse.data!.status.toLowerCase();
    }

    final context = sl<NavigationService>().navigatorKey.currentContext;
    if (context != null) {
      if (orderStatus == 'processing' || orderStatus == 'paid') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => VNPaySuccessScreen(orderId: orderId),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) => VNPayFailureScreen(
                  orderId: orderId,
                  errorMessage: "Thanh toán không thành công hoặc đã bị hủy.",
                ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        // App is being terminated - clear all user data for security
        print('App is being terminated, clearing user data...');
        await JwtService.clearAllUserData();
        break;
      case AppLifecycleState.paused:
        // App is in background - you can optionally clear sensitive data here
        print('App moved to background');
        // Uncomment the line below if you want to clear data when app goes to background
        // await JwtService.clearAllUserData();
        break;
      case AppLifecycleState.resumed:
        // App is back in foreground
        print('App resumed from background');
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during phone call)
        print('App is inactive');
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        print('App is hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp: Building with providers");
    return MultiProvider(
      providers: [
        // Ensure providers are created in the correct order
        ChangeNotifierProvider(
          create: (_) {
            debugPrint("MyApp: Creating ThemeProvider");
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint("MyApp: Creating EnhancedBrandsViewModel");
            try {
              final provider = sl<EnhancedBrandsViewModel>();
              debugPrint("MyApp: EnhancedBrandsViewModel created successfully");
              return provider;
            } catch (e) {
              debugPrint("MyApp: Error creating EnhancedBrandsViewModel: $e");
              rethrow;
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint("MyApp: Creating EnhancedSkinTypesViewModel");
            try {
              final provider = sl<EnhancedSkinTypesViewModel>();
              debugPrint(
                "MyApp: EnhancedSkinTypesViewModel created successfully",
              );
              return provider;
            } catch (e) {
              debugPrint(
                "MyApp: Error creating EnhancedSkinTypesViewModel: $e",
              );
              rethrow;
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint("MyApp: Creating EnhancedProductsViewModel");
            try {
              final provider = sl<EnhancedProductsViewModel>();
              debugPrint(
                "MyApp: EnhancedProductsViewModel created successfully",
              );
              return provider;
            } catch (e) {
              debugPrint("MyApp: Error creating EnhancedProductsViewModel: $e");
              rethrow;
            }
          },
        ),
        // Đã thay thế bằng EnhancedCategoriesViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return CategoriesProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedCategoriesViewModel>();
          },
        ),
        // Đã thay thế bằng EnhancedCartViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return CartProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedCartViewModel>();
          },
        ),
        // Đã thay thế bằng EnhancedWishlistViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return WishlistProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedWishlistViewModel>();
          },
        ),
        // Đã thay thế bằng EnhancedViewedProductsProvider
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return ViewedProdProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedViewedProductsProvider>();
          },
        ),
        // Đã thay thế bằng EnhancedChatViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     final provider = ChatProvider();
        //     provider.initialize();
        //     return provider;
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedChatViewModel>();
          },
        ),
        // Đã thay thế bằng EnhancedSkinAnalysisViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return SkinAnalysisProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedSkinAnalysisViewModel>();
          },
        ),
        // Đã thay thế bằng EnhancedOrderViewModel
        // ChangeNotifierProvider(
        //   create: (_) {
        //     return OrderProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedOrderViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedHomeViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedProfileViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedAuthViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedQuizViewModel>();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: sl<NavigationService>().navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'ShopSmart',
            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTheme,
              context: context,
            ),
            home: const RootScreen(),
            routes: {
              // Root screen
              RootScreen.routeName: (context) => const RootScreen(),

              // Auth screens
              // LoginScreen.routeName: (context) => const LoginScreen(), // Sử dụng Enhanced thay thế
              EnhancedLoginScreen.routeName:
                  (context) => const EnhancedLoginScreen(),

              // Chat screens
              // ChatScreen.routeName: (context) => const ChatScreen(), // Sử dụng Enhanced thay thế
              // ChatAIScreen.routeName: (context) => const ChatAIScreen(), // Sử dụng Enhanced thay thế
              EnhancedChatAIScreen.routeName:
                  (context) => const EnhancedChatAIScreen(),
              EnhancedChatScreen.routeName:
                  (context) => const EnhancedChatScreen(),

              // Product screens
              // ProductDetailsScreen.routName:              //     (context) => const ProductDetailsScreen(), // Sử dụng Enhanced thay thế
              EnhancedProductDetailsScreen.routeName:
                  (context) => const EnhancedProductDetailsScreen(),
              // ViewedRecentlyScreen.routName:
              //     (context) => const ViewedRecentlyScreen(), // Sử dụng Enhanced thay thế
              EnhancedViewedRecentlyScreen.routeName:
                  (context) => const EnhancedViewedRecentlyScreen(),
              // AllProductsScreen.routeName:
              //     (context) => const AllProductsScreen(), // Sử dụng Enhanced thay thế
              EnhancedAllProductsScreen.routeName:
                  (context) => const EnhancedAllProductsScreen(),
              // SearchScreen.routeName: (context) => const SearchScreen(), // Sử dụng SimpleSearchScreen thay thế
              SimpleSearchScreen.routeName:
                  (context) => const SimpleSearchScreen(),

              // Quiz screens
              // QuizScreen.routeName: (context) => const QuizScreen(), // Sử dụng Enhanced thay thế
              EnhancedQuizScreen.routeName:
                  (context) => const EnhancedQuizScreen(),

              // Blog screens
              // BlogDetailsScreen.routeName:
              //     (context) => const BlogDetailsScreen(), // Sử dụng Enhanced thay thế
              EnhancedBlogDetailScreen.routeName:
                  (context) => const EnhancedBlogDetailScreen(),
              // OffersScreen.routeName: (context) => const OffersScreen(), // Sử dụng Enhanced thay thế
              EnhancedOffersScreen.routeName:
                  (context) => const EnhancedOffersScreen(),

              // Order screens
              // CheckoutScreen.routeName: (context) => const CheckoutScreen(), // Sử dụng Enhanced thay thế
              // OrdersScreen.routeName: (context) => const OrdersScreen(), // Sử dụng Enhanced thay thế
              EnhancedOrdersScreen.routeName:
                  (context) => const EnhancedOrdersScreen(),
              EnhancedOrderSuccessScreen.routeName:
                  (context) => const EnhancedOrderSuccessScreen(),

              // Skin analysis screens
              // SkinAnalysisIntroScreen.routeName:
              //     (context) => const SkinAnalysisIntroScreen(), // Sử dụng Enhanced thay thế
              // SkinAnalysisCameraScreen.routeName:
              //     (context) => const SkinAnalysisCameraScreen(), // Sử dụng Enhanced thay thế
              // SkinAnalysisHistoryScreen.routeName:
              //     (context) => const SkinAnalysisHistoryScreen(), // Sử dụng Enhanced thay thế
              // SkinAnalysisPaymentScreen.routeName:
              //     (context) => const SkinAnalysisPaymentScreen(), // Sử dụng Enhanced thay thế

              // Enhanced skin analysis screens
              EnhancedSkinAnalysisIntroScreen.routeName:
                  (context) => const EnhancedSkinAnalysisIntroScreen(),
              EnhancedSkinAnalysisCameraScreen.routeName:
                  (context) => const EnhancedSkinAnalysisCameraScreen(),
              EnhancedSkinAnalysisHistoryScreen.routeName:
                  (context) => const EnhancedSkinAnalysisHistoryScreen(),
              // EnhancedSkinAnalysisHistoryDetailScreen.routeName is handled in onGenerateRoute because it requires parameters
              EnhancedPaymentScreen.routeName:
                  (context) => const EnhancedPaymentScreen(),

              // Auth screens
              // ForgotPasswordScreen.routeName:
              //     (context) => const ForgotPasswordScreen(), // Sử dụng Enhanced thay thế
              // RegisterScreen.routName: (context) => const RegisterScreen(), // Sử dụng Enhanced thay thế
              // ChangePasswordScreen.routeName:
              //     (context) => const ChangePasswordScreen(), // Sử dụng Enhanced thay thế
              EnhancedRegisterScreen.routeName:
                  (context) => const EnhancedRegisterScreen(),
              EnhancedForgotPasswordScreen.routeName:
                  (context) => const EnhancedForgotPasswordScreen(),
              EnhancedChangePasswordScreen.routeName:
                  (context) => const EnhancedChangePasswordScreen(),

              // Other screens
              // WishlistScreen.routName: (context) => const WishlistScreen(), // Sử dụng Enhanced thay thế
              EnhancedWishlistScreen.routeName:
                  (context) => const EnhancedWishlistScreen(),
              EnhancedEditProfileScreen.routeName:
                  (ctx) => const EnhancedEditProfileScreen(),
              EnhancedAddressScreen.routeName:
                  (ctx) => const EnhancedAddressScreen(),
              EnhancedCheckoutScreen.routeName:
                  (ctx) => const EnhancedCheckoutScreen(),
              // EnhancedQuizQuestionScreen is handled in onGenerateRoute because it requires parameters
            },
            // Xử lý các route đặc biệt cần tham số
            onGenerateRoute: (settings) {
              // if (settings.name == SkinAnalysisResultScreen.routeName) {
              //   final result = settings.arguments as SkinAnalysisResult;
              //   return MaterialPageRoute(
              //     builder:
              //         (context) => SkinAnalysisResultScreen(result: result),
              //   );
              // } // Sử dụng Enhanced thay thế
              if (settings.name == EnhancedSkinAnalysisResultScreen.routeName) {
                return MaterialPageRoute(
                  builder:
                      (context) => const EnhancedSkinAnalysisResultScreen(),
                );
              }
              // if (settings.name == OrderDetailScreen.routeName) {
              //   final orderId = settings.arguments as String;
              //   return MaterialPageRoute(
              //     builder: (context) => OrderDetailScreen(orderId: orderId),
              //   );
              // } // Sử dụng Enhanced thay thế
              if (settings.name == EnhancedOrderDetailScreen.routeName) {
                final orderId = settings.arguments as String;
                return MaterialPageRoute(
                  builder:
                      (context) => EnhancedOrderDetailScreen(orderId: orderId),
                );
              }
              if (settings.name == EnhancedReviewsScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder:
                      (context) => EnhancedReviewsScreen(
                        productId: args['productId'],
                        productName: args['productName'],
                      ),
                );
              }
              if (settings.name == EnhancedQuizQuestionScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder:
                      (context) => EnhancedQuizQuestionScreen(
                        quizSetId: args['quizSetId'],
                        quizSetName: args['quizSetName'],
                      ),
                );
              }
              if (settings.name ==
                  EnhancedSkinAnalysisHistoryDetailScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder:
                      (context) => EnhancedSkinAnalysisHistoryDetailScreen(
                        analysisId: args['analysisId'],
                      ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
