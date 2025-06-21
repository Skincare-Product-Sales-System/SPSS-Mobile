import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/providers/theme_provider.dart';
import 'package:shopsmart_users_en/providers/categories_provider.dart';
import 'package:shopsmart_users_en/providers/order_provider.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_detail.dart';
import 'package:shopsmart_users_en/screens/inner_screen/viewed_recently.dart';
import 'package:shopsmart_users_en/screens/inner_screen/blog_detail.dart';
import 'package:shopsmart_users_en/screens/inner_screen/offers_screen.dart';
import 'package:shopsmart_users_en/screens/all_products_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/checkout_screen.dart';
import 'package:shopsmart_users_en/services/jwt_service.dart';
import 'package:shopsmart_users_en/screens/orders/orders_screen.dart';
import 'package:shopsmart_users_en/providers/chat_provider.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_provider.dart';
import 'package:shopsmart_users_en/screens/chat_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_intro_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_camera_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_result_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/payment/payment_screen.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/screens/orders/order_detail_screen.dart';
import 'package:shopsmart_users_en/screens/chat_ai_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/vnpay_success_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/vnpay_failure_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'consts/theme_data.dart';
import 'providers/cart_provider.dart';
import 'providers/viewed_recently_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/auth/forgot_password.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/auth/change_password.dart';
import 'screens/inner_screen/orders/orders_screen.dart';
import 'screens/inner_screen/wishlist.dart';
import 'screens/search_screen.dart';
import 'screens/checkout/order_success_screen.dart';
import 'screens/skin_analysis/skin_analysis_history_screen.dart';
import 'services/api_service.dart';
import 'models/order_models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
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
      if (initialUri != null && initialUri.scheme == 'spss' && initialUri.host == 'vnpay-return') {
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

    final context = navigatorKey.currentContext;
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
            builder: (context) => VNPayFailureScreen(
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return ProductsProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return CategoriesProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return CartProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return WishlistProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return ViewedProdProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ChatProvider();
            provider.initialize();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return SkinAnalysisProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return OrderProvider();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ShopSmart EN',
            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTheme,
              context: context,
            ),
            home: const RootScreen(),
            navigatorKey: navigatorKey,
            routes: {
              RootScreen.routeName: (context) => const RootScreen(),
              ProductDetailsScreen.routName:
                  (context) => const ProductDetailsScreen(),
              WishlistScreen.routName: (context) => const WishlistScreen(),
              ViewedRecentlyScreen.routName:
                  (context) => const ViewedRecentlyScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              ForgotPasswordScreen.routeName:
                  (context) => const ForgotPasswordScreen(),
              SearchScreen.routeName: (context) => const SearchScreen(),
              AllProductsScreen.routeName:
                  (context) => const AllProductsScreen(),
              BlogDetailScreen.routeName: (context) => const BlogDetailScreen(),
              ChangePasswordScreen.routeName:
                  (context) => const ChangePasswordScreen(),
              CheckoutScreen.routeName: (context) => const CheckoutScreen(),
              OffersScreen.routeName: (context) => const OffersScreen(),
              ChatScreen.routeName: (context) => const ChatScreen(),
              SkinAnalysisIntroScreen.routeName:
                  (context) => const SkinAnalysisIntroScreen(),
              SkinAnalysisCameraScreen.routeName:
                  (context) => const SkinAnalysisCameraScreen(),
              SkinAnalysisResultScreen.routeName: (context) {
                final result =
                    ModalRoute.of(context)!.settings.arguments
                        as SkinAnalysisResult;
                return SkinAnalysisResultScreen(result: result);
              },
              SkinAnalysisPaymentScreen.routeName:
                  (context) => const SkinAnalysisPaymentScreen(),
              '/order-success': (context) => const OrderSuccessScreen(),
              SkinAnalysisHistoryScreen.routeName:
                  (context) => const SkinAnalysisHistoryScreen(),
              ChatAIScreen.routeName: (context) => const ChatAIScreen(),
              VNPaySuccessScreen.routeName: (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                return VNPaySuccessScreen(
                  orderId: args?['orderId'],
                  amount: args?['amount'],
                );
              },
              VNPayFailureScreen.routeName: (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                return VNPayFailureScreen(
                  orderId: args?['orderId'],
                  errorMessage: args?['errorMessage'],
                );
              },
            },
            onGenerateRoute: (RouteSettings settings) {
              // Handle dynamic routes with parameters
              if (settings.name == OrderDetailScreen.routeName) {
                // Extract orderId from arguments
                final orderId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(orderId: orderId),
                  settings: settings,
                );
              }
              return null; // Let the default routes handle other cases
            },
          );
        },
      ),
    );
  }
}
