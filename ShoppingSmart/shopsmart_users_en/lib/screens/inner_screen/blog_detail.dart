import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import '../../models/blog_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_name_text.dart';

class BlogDetailScreen extends StatefulWidget {
  static const routeName = "/BlogDetailScreen";
  const BlogDetailScreen({super.key});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  DetailedBlogModel? _detailedBlog;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? blogId =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (blogId != null) {
        _loadBlogDetails(blogId);
      }
    });
  }

  Future<void> _loadBlogDetails(String blogId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getBlogById(blogId);
      if (response.success && response.data != null) {
        setState(() {
          _detailedBlog = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load blog details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading blog: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final String? blogId =
                            ModalRoute.of(context)!.settings.arguments
                                as String?;
                        if (blogId != null) {
                          _loadBlogDetails(blogId);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _detailedBlog == null
              ? Center(
                child: Text(
                  'Blog not found',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blog Header Image
                    FancyShimmerImage(
                      imageUrl: _detailedBlog!.thumbnail,
                      height: size.height * 0.3,
                      width: double.infinity,
                      boxFit: BoxFit.cover,
                      errorWidget: Container(
                        height: size.height * 0.3,
                        width: double.infinity,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        child: Icon(
                          Icons.article,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.5),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blog Title
                          Text(
                            _detailedBlog!.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Author and Date Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'By ${_detailedBlog!.author}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _detailedBlog!.formattedDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Blog Description
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _detailedBlog!.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Blog Sections
                          Text(
                            'Article Content',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Display all sections in order
                          ...(_detailedBlog!.sections
                                ..sort((a, b) => a.order.compareTo(b.order)))
                              .map((section) => _buildSection(section)),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSection(BlogSection section) {
    if (section.contentType.toLowerCase() == 'text') {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.subtitle.isNotEmpty) ...[
              Text(
                section.subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              section.content,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    } else if (section.contentType.toLowerCase() == 'image') {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FancyShimmerImage(
                imageUrl: section.content,
                width: double.infinity,
                height: 200,
                boxFit: BoxFit.cover,
                errorWidget: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            if (section.subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                section.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    } else {
      // Handle other content types if needed
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              section.content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
  }
}
