import 'package:flutter/material.dart';
import 'enhanced_login.dart';


class LoginScreen extends StatelessWidget {
  static const routeName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedLoginScreen();
  }
}
