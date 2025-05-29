import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/screens/auth/login.dart';
import 'package:shopsmart_users_en/screens/auth/change_password.dart';
import 'package:shopsmart_users_en/screens/inner_screen/viewed_recently.dart';
import 'package:shopsmart_users_en/screens/inner_screen/wishlist.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/services/auth_service.dart';
import 'package:shopsmart_users_en/services/my_app_function.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/models/auth_models.dart';

import '../providers/theme_provider.dart';
import '../widgets/app_name_text.dart';
import '../widgets/title_text.dart';
import 'inner_screen/orders/orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final userInfo = await AuthService.getStoredUserInfo();

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _userInfo = userInfo;
      });
    }
  }

  Future<void> _logout() async {
    await MyAppFunctions.showErrorOrWarningDialog(
      context: context,
      subtitle: "Are you sure you want to logout?",
      fct: () async {
        await AuthService.logout();
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _userInfo = null;
          });
        }
      },
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: !_isLoggedIn,
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: TitlesTextWidget(
                  label: "Please login to have unlimited access",
                ),
              ),
            ),
            Visibility(
              visible: _isLoggedIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(label: _userInfo?.userName ?? "User"),
                        const SizedBox(height: 6),
                        SubtitleTextWidget(
                          label: _userInfo?.email ?? "user@example.com",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  const TitlesTextWidget(label: "General"),
                  const SizedBox(height: 10),
                  CustomListTile(
                    text: "All Order",
                    imagePath: AssetsManager.orderSvg,
                    function: () {
                      Navigator.pushNamed(context, OrdersScreenFree.routeName);
                    },
                  ),
                  CustomListTile(
                    text: "Wishlist",
                    imagePath: AssetsManager.wishlistSvg,
                    function: () {
                      Navigator.pushNamed(context, WishlistScreen.routName);
                    },
                  ),
                  CustomListTile(
                    text: "Viewed recently",
                    imagePath: AssetsManager.recent,
                    function: () {
                      Navigator.pushNamed(
                        context,
                        ViewedRecentlyScreen.routName,
                      );
                    },
                  ),
                  CustomListTile(
                    text: "Address",
                    imagePath: AssetsManager.address,
                    function: () {},
                  ),
                  if (_isLoggedIn)
                    CustomListTile(
                      text: "Change Password",
                      imagePath: AssetsManager.orderSvg,
                      function: () {
                        Navigator.pushNamed(
                          context,
                          ChangePasswordScreen.routeName,
                        );
                      },
                    ),
                  const SizedBox(height: 6),
                  const Divider(thickness: 1),
                  const SizedBox(height: 6),
                  const TitlesTextWidget(label: "Settings"),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    secondary: Image.asset(AssetsManager.theme, height: 34),
                    title: Text(
                      themeProvider.getIsDarkTheme ? "Dark Mode" : "Light Mode",
                    ),
                    value: themeProvider.getIsDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(themeValue: value);
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoggedIn ? Colors.red : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                icon: Icon(_isLoggedIn ? Icons.logout : Icons.login),
                label: Text(_isLoggedIn ? "Logout" : "Login"),
                onPressed: () async {
                  if (_isLoggedIn) {
                    await _logout();
                  } else {
                    Navigator.pushNamed(context, LoginScreen.routeName).then((
                      _,
                    ) {
                      _checkLoginStatus();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.imagePath,
    required this.text,
    required this.function,
  });
  final String imagePath, text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      title: SubtitleTextWidget(label: text),
      leading: Image.asset(imagePath, height: 34),
      trailing: const Icon(IconlyLight.arrow_right_2),
    );
  }
}
