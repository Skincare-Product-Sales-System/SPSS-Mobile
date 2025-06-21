import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
// Đã thay thế bằng enhanced_cart_view_model.dart
import 'package:shopsmart_users_en/providers/enhanced_auth_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_cart_view_model.dart';
import 'package:shopsmart_users_en/screens/auth/enhanced_login.dart';
import 'package:shopsmart_users_en/screens/cart/enhanced_cart_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_home_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_profile_screen.dart';
import 'package:shopsmart_users_en/screens/enhanced_quiz_screen.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_intro_screen.dart';
import 'package:shopsmart_users_en/services/jwt_service.dart';
import 'package:shopsmart_users_en/widgets/chat/chat_widget.dart';

class RootScreen extends StatefulWidget {
  static const routeName = '/RootScreen';
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late List<Widget> screens;
  int currentScreen = 0;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    screens = const [
      EnhancedHomeScreen(),
      EnhancedQuizScreen(),
      EnhancedSkinAnalysisIntroScreen(),
      EnhancedCartScreen(),
      EnhancedProfileScreen(),
    ];
    controller = PageController(initialPage: currentScreen);

    // Tải giỏ hàng từ server khi ứng dụng khởi động
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kiểm tra trạng thái đăng nhập
      final authViewModel = Provider.of<EnhancedAuthViewModel>(
        context,
        listen: false,
      );

      // Kiểm tra token và cập nhật trạng thái đăng nhập
      final isAuth = await JwtService.isAuthenticated();
      if (isAuth) {
        final token = await JwtService.getStoredToken();
        if (token != null) {
          final tokenData = JwtService.getUserFromToken(token);
          if (tokenData != null) {
            // Cập nhật trạng thái đăng nhập trong AuthViewModel
            await authViewModel.refreshLoginState();
          }
        }
      }

      // Chỉ cần tải giỏ hàng từ EnhancedCartViewModel vì đây là provider chính
      final enhancedCartViewModel = Provider.of<EnhancedCartViewModel>(
        context,
        listen: false,
      );

      // Tải giỏ hàng nếu đã đăng nhập
      if (authViewModel.isLoggedIn) {
        enhancedCartViewModel.fetchCartFromServer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final enhancedCartViewModel = Provider.of<EnhancedCartViewModel>(context);
    final authViewModel = Provider.of<EnhancedAuthViewModel>(context);

    // Tính tổng số lượng sản phẩm trong giỏ hàng
    int cartItemCount = enhancedCartViewModel.totalQuantity;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: screens,
          ),

          // Chat widget
          const ChatWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 10,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index) {
          // Kiểm tra nếu người dùng chưa đăng nhập và đang cố gắng truy cập vào Quiz hoặc Phân tích da
          if (!authViewModel.isLoggedIn && (index == 1 || index == 2)) {
            // Hiển thị dialog yêu cầu đăng nhập
            _showLoginRequiredDialog(context);
          } else {
            setState(() {
              currentScreen = index;
            });
            controller.jumpToPage(currentScreen);
          }
        },
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Trang Chủ",
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.quiz, color: Colors.deepPurple),
            icon: Icon(Icons.quiz_outlined),
            label: "Trắc nghiệm",
          ),
          const NavigationDestination(
            selectedIcon: Icon(
              Icons.face_retouching_natural,
              color: Colors.pink,
            ),
            icon: Icon(Icons.face_retouching_natural_outlined),
            label: "Phân Tích Da",
          ),
          NavigationDestination(
            selectedIcon: const Icon(IconlyBold.bag_2),
            icon: Badge(
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(IconlyLight.bag_2),
            ),
            label: "Giỏ Hàng",
          ),
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.profile),
            icon: Icon(IconlyLight.profile),
            label: "Cá Nhân",
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog yêu cầu đăng nhập
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yêu cầu đăng nhập'),
          content: const Text('Bạn cần đăng nhập để sử dụng tính năng này.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pushNamed(EnhancedLoginScreen.routeName);
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        );
      },
    );
  }
}
