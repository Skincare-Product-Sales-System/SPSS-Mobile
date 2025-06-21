import 'package:flutter/material.dart';
import 'enhanced_change_password.dart';

class ChangePasswordScreen extends StatelessWidget {
  static const routeName = '/ChangePasswordScreen';
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedChangePasswordScreen();
  }
}
