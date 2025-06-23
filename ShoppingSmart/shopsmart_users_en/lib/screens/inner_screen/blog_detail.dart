import 'package:flutter/material.dart';
import 'enhanced_blog_detail.dart';

class BlogDetailsScreen extends StatelessWidget {
  static const routeName = '/BlogDetailsScreen';
  const BlogDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blogId = ModalRoute.of(context)!.settings.arguments as String?;

    // Redirect to the enhanced version
    return EnhancedBlogDetailScreen(blogId: blogId);
  }
}
