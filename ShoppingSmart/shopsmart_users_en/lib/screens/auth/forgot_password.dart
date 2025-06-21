import 'package:flutter/material.dart';
import 'enhanced_forgot_password.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const routeName = '/ForgotPasswordScreen';
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedForgotPasswordScreen();
  }
}
