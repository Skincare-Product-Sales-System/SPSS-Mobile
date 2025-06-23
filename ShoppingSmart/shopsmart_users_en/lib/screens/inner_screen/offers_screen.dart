import 'package:flutter/material.dart';
import 'enhanced_offers_screen.dart';

class OffersScreen extends StatelessWidget {
  static const routeName = '/OffersScreen';
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedOffersScreen();
  }
}
