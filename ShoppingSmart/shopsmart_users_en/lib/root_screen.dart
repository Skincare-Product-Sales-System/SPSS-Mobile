import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/cart_provider.dart';
import 'package:shopsmart_users_en/screens/cart/cart_screen.dart';
import 'package:shopsmart_users_en/screens/home_screen.dart';
import 'package:shopsmart_users_en/screens/profile_screen.dart';
import 'package:shopsmart_users_en/screens/search_screen.dart';
import 'package:shopsmart_users_en/screens/quiz_screen.dart';
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
      HomeScreen(),
      SearchScreen(),
      QuizScreen(),
      CartScreen(),
      ProfileScreen(),
    ];
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
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
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(currentScreen);
        },
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Trang Chủ",
          ),
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.search),
            icon: Icon(IconlyLight.search),
            label: "Tìm Kiếm",
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.quiz, color: Colors.deepPurple),
            icon: Icon(Icons.quiz_outlined),
            label: "Câu Đố",
          ),
          NavigationDestination(
            selectedIcon: const Icon(IconlyBold.bag_2),
            icon: Badge(
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              label: Text(cartProvider.getCartitems.length.toString()),
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
}
