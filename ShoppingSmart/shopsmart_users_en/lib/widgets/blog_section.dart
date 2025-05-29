import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import '../models/blog_model.dart';
import '../services/api_service.dart';
import '../screens/inner_screen/blog_detail.dart';

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getBlogs(pageNumber: 1, pageSize: 10);
      if (response.success && response.data != null) {
        setState(() {
          _blogs = response.data!.items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load blogs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading blogs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blog Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Blogs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: 0.3,
                ),
              ),
              if (_blogs.isNotEmpty)
                Text(
                  '${_blogs.length} articles',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Blog List
        if (_isLoading)
          SizedBox(
            height: size.height * 0.25,
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SizedBox(
            height: size.height * 0.25,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load blogs',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadBlogs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_blogs.isEmpty)
          SizedBox(
            height: size.height * 0.25,
            child: Center(
              child: Text(
                'No blogs available',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: size.height * 0.28,
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
      width: size.width * 0.75,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blog Image
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: FancyShimmerImage(
                    imageUrl: blog.thumbnail,
                    width: double.infinity,
                    height: double.infinity,
                    boxFit: BoxFit.cover,
                    errorWidget: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      child: Icon(
                        Icons.article,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Blog Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blog Title
                      Expanded(
                        flex: 2,
                        child: Text(
                          blog.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Author and Date
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              blog.author,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            blog.formattedDate,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Read More Button
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              BlogDetailScreen.routeName,
                              arguments: blog.id,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF9C88FF,
                            ), // Light purple
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Read More',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
