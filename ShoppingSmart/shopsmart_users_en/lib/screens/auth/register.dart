import 'package:flutter/material.dart';
import 'enhanced_register.dart';

class RegisterScreen extends StatelessWidget {
  static const routName = '/RegisterScreen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedRegisterScreen();
  }
}
