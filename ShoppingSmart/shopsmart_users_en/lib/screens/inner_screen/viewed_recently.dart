import 'package:flutter/material.dart';
import 'enhanced_viewed_recently.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = '/ViewedRecentlyScreen';
  const ViewedRecentlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedViewedRecentlyScreen();
  }
}
