import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:iconly/iconly.dart';
import '../models/blog_model.dart';
import '../services/api_service.dart';
import '../screens/inner_screen/enhanced_blog_detail.dart';

class BlogSection extends StatefulWidget {
  const BlogSection({super.key});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection> {
  List<BlogModel> _blogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print('Starting to load blogs...'); // Debug log

    try {
      final response = await ApiService.getBlogs(pageNumber: 1, pageSize: 10);
      print(
        'Blog API response: success=${response.success}, message=${response.message}',
      ); // Debug log

      if (!mounted) return;

      if (response.success && response.data != null) {
        print(
          'Successfully loaded ${response.data!.items.length} blogs',
        ); // Debug log
        setState(() {
          _blogs = response.data!.items;
          _isLoading = false;
        });
      } else {
        print('Failed to load blogs: ${response.message}'); // Debug log
        print('Response errors: ${response.errors}'); // Debug log

        // Add temporary mock data for UI testing
        print('Loading mock blog data for UI testing...'); // Debug log
        setState(() {
          _blogs = [
            BlogModel(
              id: '1',
              title: 'Expert Tips for Caring For Men\'s Skin',
              thumbnail:
                  'https://images.unsplash.com/photo-1506629905607-bda39cee5c4d?w=400',
              description:
                  'Caring for men\'s skin isn\'t too complicated. If you\'re a beginner who has had your other half nag your skin...',
              author: 'Dr. Alex',
              lastUpdatedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
            BlogModel(
              id: '2',
              title: 'How to Layer Skincare Ingredients',
              thumbnail:
                  'https://images.unsplash.com/photo-1556909075-f3e7e8c33de4?w=400',
              description:
                  'Many ingredients react heavily with skincare, so it\'s important to know which ones don\'t belong together...',
              author: 'Dr. Sarah',
              lastUpdatedAt: DateTime.now().subtract(const Duration(days: 5)),
            ),
            BlogModel(
              id: '3',
              title: 'Complete Guide to Anti-Aging',
              thumbnail:
                  'https://images.unsplash.com/photo-1571772805616-942fa6b9d7e9?w=400',
              description:
                  'Discover the best anti-aging practices and products that actually work for your skin type...',
              author: 'Dr. Emma',
              lastUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ];
          _isLoading = false;
          // Still keep the error message but with reduced severity
          _errorMessage =
              'API temporarily unavailable - showing sample content';
        });
      }
    } catch (e) {
      print('Exception loading blogs: $e'); // Debug log
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading blogs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blog Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFFAFBFC)
                      : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.15)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Theme.of(context).brightness == Brightness.light
                                  ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    width: 1,
                                  )
                                  : null,
                        ),
                        child: Icon(
                          IconlyBold.document,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📰 Latest Articles",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF1A202C)
                                      : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Discover our latest insights & tips",
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF4A5568)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_blogs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.12)
                                : Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.25)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${_blogs.length} articles',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Blog List
          if (_isLoading)
            Container(
              height: size.height * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => _buildShimmerCard(),
              ),
            )
          else if (_errorMessage != null)
            Container(
              height: size.height * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFFEF5F5)
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.red.withOpacity(0.2)
                          : Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow:
                    Theme.of(context).brightness == Brightness.light
                        ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.red.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        size: 48,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.red.shade600
                                : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải bài viết',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF1A202C)
                                : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFF4A5568)
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadBlogs,
                      icon: Icon(Icons.refresh, size: 18),
                      label: const Text('Thử Lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_blogs.isEmpty)
            Container(
              height: size.height * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFF7FAFC)
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Theme.of(context).brightness == Brightness.light
                        ? Border.all(
                          color: Colors.grey.withOpacity(0.15),
                          width: 1,
                        )
                        : null,
                boxShadow:
                    Theme.of(context).brightness == Brightness.light
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.08)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        IconlyBold.document,
                        size: 48,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.7)
                                : Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có bài viết',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF2D3748)
                                : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng quay lại sau để xem nội dung mới',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF718096)
                                : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: size.height * 0.45,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _blogs.length,
                itemBuilder: (context, index) {
                  return BlogCard(blog: _blogs[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final BlogModel blog;

  const BlogCard({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.65,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border:
            Theme.of(context).brightness == Brightness.light
                ? Border.all(color: Colors.grey.withOpacity(0.15), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.06)
                    : Colors.black.withOpacity(0.08),
            blurRadius:
                Theme.of(context).brightness == Brightness.light ? 12 : 20,
            offset: const Offset(0, 4),
            spreadRadius:
                Theme.of(context).brightness == Brightness.light ? 0 : 0,
          ),
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                EnhancedBlogDetailScreen.routeName,
                arguments: blog.id,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blog Image
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        FancyShimmerImage(
                          imageUrl: blog.thumbnail,
                          width: double.infinity,
                          height: double.infinity,
                          boxFit: BoxFit.cover,
                          errorWidget: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              IconlyBold.document,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              IconlyBold.bookmark,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Blog Content
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blog Title
                        Text(
                          blog.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF1A202C)
                                    : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                            height: 1.3,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Blog Description
                        Text(
                          blog.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF4A5568)
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),

                        // Author and Date Row
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      IconlyBold.profile,
                                      size: 14,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog.author,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          blog.formattedDate,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
