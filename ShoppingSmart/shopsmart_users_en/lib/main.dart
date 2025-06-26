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
import 'package:shopsmart_users_en/providers/temp_cart_provider.dart';
import 'package:shopsmart_users_en/providers/theme_provider.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/auth/enhanced_login.dart';
import 'package:shopsmart_users_en/screens/simple_search_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_all_products_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_quiz_question_screen.dart';
import 'package:shopsmart_users_en/screens/orders/enhanced_orders_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_hub_screen.dart';
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
import 'package:shopsmart_users_en/screens/user_reviews_screen.dart';
import 'screens/profile/enhanced_edit_profile_screen.dart';
import 'screens/profile/enhanced_address_screen.dart';
import 'screens/checkout/enhanced_checkout_screen.dart';
import 'screens/enhanced_chat_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_offers_screen.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_viewed_recently.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_blog_detail.dart';
import 'package:shopsmart_users_en/screens/checkout/enhanced_order_success_screen.dart';
import 'screens/auth/enhanced_register.dart';
import 'screens/auth/enhanced_forgot_password.dart';
import 'screens/auth/enhanced_change_password.dart';
import 'package:shopsmart_users_en/screens/cart/enhanced_cart_screen.dart';
import 'package:shopsmart_users_en/screens/orders/enhanced_order_detail_screen.dart';
import 'package:shopsmart_users_en/screens/checkout/vnpay_waiting_screen.dart';
import 'consts/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Main: Flutter binding initialized");
  try {
    debugPrint("Main: Setting up service locator");
    await setupServiceLocator();
    debugPrint("Main: Service locator setup completed");
    runApp(const MyApp());
    debugPrint("Main: App started");
  } catch (e, stackTrace) {
    debugPrint("Main: Error during initialization: $e");
    debugPrint(stackTrace.toString());
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
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri != null && uri.scheme == 'spss' && uri.host == 'vnpay-return') {
        handleVnPayDeepLink(uri);
      }
    });
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
    final context = sl<NavigationService>().navigatorKey.currentContext;

    if (context == null || orderId == null || orderId.isEmpty) {
      debugPrint("VNPay callback: Invalid context or orderId.");
      // Optionally, navigate to a safe screen like home or orders list
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RootScreen()),
          (route) => false,
        );
      }
      return;
    }

    final orderViewModel = Provider.of<EnhancedOrderViewModel>(context, listen: false);
    final cartViewModel = Provider.of<EnhancedCartViewModel>(context, listen: false);

    // Show a loading indicator while we verify the payment
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Give backend a moment to process the webhook from VNPay
      await Future.delayed(const Duration(seconds: 2));

      // **CRITICAL STEP:** Verify the final order status from our own backend
      final response = await ApiService.getOrderDetail(orderId);

      // Always refresh the main order list in the background
      orderViewModel.loadOrders(refresh: true);

      // Close the loading indicator
      Navigator.of(context).pop();

      if (response.success && response.data != null) {
        final orderStatus = response.data!.status.toLowerCase();

        // Check for statuses that confirm payment was successful
        if (orderStatus == 'processing' || orderStatus == 'paid') {
          await cartViewModel.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Handle cases where payment was not successful (e.g., 'awaiting payment', 'cancelled')
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán không thành công hoặc đang chờ xử lý.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Handle API error when fetching order details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xác thực trạng thái đơn hàng: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Navigate to the order detail screen regardless of status
      // so the user can see the final state or retry payment.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => EnhancedOrderDetailScreen(orderId: orderId),
        ),
        (route) => route.isFirst,
      );

    } catch (e) {
      // Handle exceptions during the process
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate to a safe place on error
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RootScreen()),
          (route) => false,
      );
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
        print('App is being terminated, clearing user data...');
        await JwtService.clearAllUserData();
        break;
      case AppLifecycleState.paused:
        print('App moved to background');
        break;
      case AppLifecycleState.resumed:
        print('App resumed from background');
        break;
      case AppLifecycleState.inactive:
        print('App is inactive');
        break;
      case AppLifecycleState.hidden:
        print('App is hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp: Building with providers");
    return MultiProvider(
      providers: [
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
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedCategoriesViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedCartViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedWishlistViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedViewedProductsProvider>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedChatViewModel>();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return sl<EnhancedSkinAnalysisViewModel>();
          },
        ),
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
        ChangeNotifierProvider(create: (_) => TempCartProvider()),
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
              RootScreen.routeName: (context) => const RootScreen(),
              EnhancedLoginScreen.routeName: (context) =>
                  const EnhancedLoginScreen(),
              EnhancedChatAIScreen.routeName: (context) =>
                  const EnhancedChatAIScreen(),
              EnhancedChatScreen.routeName: (context) =>
                  const EnhancedChatScreen(),
              EnhancedProductDetailsScreen.routeName: (context) =>
                  const EnhancedProductDetailsScreen(),
              EnhancedViewedRecentlyScreen.routeName: (context) =>
                  const EnhancedViewedRecentlyScreen(),
              EnhancedAllProductsScreen.routeName: (context) =>
                  const EnhancedAllProductsScreen(),
              SimpleSearchScreen.routeName: (context) =>
                  const SimpleSearchScreen(),
              EnhancedSkinAnalysisHubScreen.routeName: (context) =>
                  const EnhancedSkinAnalysisHubScreen(),
              EnhancedBlogDetailScreen.routeName: (context) =>
                  const EnhancedBlogDetailScreen(),
              EnhancedOffersScreen.routeName: (context) =>
                  const EnhancedOffersScreen(),
              EnhancedOrdersScreen.routeName: (context) =>
                  const EnhancedOrdersScreen(),
              EnhancedOrderSuccessScreen.routeName: (context) =>
                  const EnhancedOrderSuccessScreen(),
              EnhancedSkinAnalysisCameraScreen.routeName: (context) =>
                  const EnhancedSkinAnalysisCameraScreen(),
              EnhancedSkinAnalysisHistoryScreen.routeName: (context) =>
                  const EnhancedSkinAnalysisHistoryScreen(),
              EnhancedPaymentScreen.routeName: (context) =>
                  const EnhancedPaymentScreen(),
              EnhancedRegisterScreen.routeName: (context) =>
                  const EnhancedRegisterScreen(),
              EnhancedForgotPasswordScreen.routeName: (context) =>
                  const EnhancedForgotPasswordScreen(),
              EnhancedChangePasswordScreen.routeName: (context) =>
                  const EnhancedChangePasswordScreen(),
              EnhancedWishlistScreen.routeName: (context) =>
                  const EnhancedWishlistScreen(),
              EnhancedEditProfileScreen.routeName: (ctx) =>
                  const EnhancedEditProfileScreen(),
              EnhancedAddressScreen.routeName: (ctx) =>
                  const EnhancedAddressScreen(),
              EnhancedCheckoutScreen.routeName: (ctx) =>
                  const EnhancedCheckoutScreen(),
              EnhancedUserReviewsScreen.routeName: (ctx) =>
                  const EnhancedUserReviewsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/enhanced-cart') {
                return MaterialPageRoute(
                  builder: (context) => EnhancedCartScreen(),
                );
              }
              if (settings.name == EnhancedSkinAnalysisResultScreen.routeName) {
                return MaterialPageRoute(
                  builder: (context) =>
                      const EnhancedSkinAnalysisResultScreen(),
                );
              }
              if (settings.name == EnhancedReviewsScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => EnhancedReviewsScreen(
                    productId: args['productId'],
                    productName: args['productName'],
                  ),
                );
              }
              if (settings.name == EnhancedQuizQuestionScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => EnhancedQuizQuestionScreen(
                    quizSetId: args['quizSetId'],
                    quizSetName: args['quizSetName'],
                  ),
                );
              }
              if (settings.name ==
                  EnhancedSkinAnalysisHistoryDetailScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) =>
                      EnhancedSkinAnalysisHistoryDetailScreen(
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
