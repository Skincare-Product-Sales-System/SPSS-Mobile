import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import '../../providers/enhanced_home_view_model.dart';
import '../../providers/home_state.dart';
import '../../models/blog_model.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../widgets/app_name_text.dart';

class EnhancedBlogDetailScreen extends StatefulWidget {
  static const routeName = "/enhanced-blog-detail";
  final String? blogId;

  const EnhancedBlogDetailScreen({super.key, this.blogId});

  @override
  State<EnhancedBlogDetailScreen> createState() =>
      _EnhancedBlogDetailScreenState();
}

class _EnhancedBlogDetailScreenState extends State<EnhancedBlogDetailScreen> {
  String? _blogId;

  @override
  void initState() {
    super.initState();
    _blogId = widget.blogId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If blogId wasn't passed as a constructor parameter, try to get it from route arguments
    _blogId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedHomeViewModel, HomeState>(
      title: "Chi tiết bài viết",
      onInit: (viewModel) {
        if (_blogId != null) {
          viewModel.loadBlogDetails(_blogId!);
        }
      },
      isLoading: (viewModel) => viewModel.isBlogDetailLoading,
      isEmpty: (viewModel) => viewModel.detailedBlog == null,
      getErrorMessage: (viewModel) => viewModel.blogDetailError,
      buildAppBar:
          (context, viewModel) => AppBar(
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
            title: const AppNameTextWidget(fontSize: 20),
          ),
      buildContent:
          (context, viewModel) => _buildBlogDetail(context, viewModel),
      buildEmpty:
          (context, viewModel) => Center(
            child: Text(
              'Không tìm thấy bài viết',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
      onRefresh:
          (viewModel) =>
              _blogId != null
                  ? viewModel.loadBlogDetails(_blogId!)
                  : Future.value(),
    );
  }

  Widget _buildBlogDetail(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
  ) {
    final detailedBlog = viewModel.detailedBlog;
    Size size = MediaQuery.of(context).size;

    if (detailedBlog == null) {
      return const Center(child: Text('Không tìm thấy dữ liệu'));
    }

    // Combine sections content for display
    final String content =
        detailedBlog.sections.isNotEmpty
            ? detailedBlog.sections.map((s) => s.content).join('\n\n')
            : detailedBlog.description;

    // Get categories and tags
    final category =
        detailedBlog.sections.isNotEmpty
            ? detailedBlog.sections
                .firstWhere(
                  (s) => s.contentType.toLowerCase() == 'category',
                  orElse:
                      () => BlogSection(
                        contentType: '',
                        subtitle: '',
                        content: '',
                        order: 0,
                      ),
                )
                .subtitle
            : '';

    final tags =
        detailedBlog.sections
            .where((s) => s.contentType.toLowerCase() == 'tag')
            .map((s) => s.subtitle)
            .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blog Header Image
          FancyShimmerImage(
            imageUrl: detailedBlog.thumbnail,
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
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
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
                  detailedBlog.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
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
                        'Bởi ${detailedBlog.author}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        detailedBlog.formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Blog Content
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category and Tags
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Danh mục: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              category.isNotEmpty ? category : 'Chưa phân loại',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Tags
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.tag,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tags: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format the date for display
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Không rõ ngày';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
