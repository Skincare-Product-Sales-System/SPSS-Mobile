import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/review_models.dart';
import '../../providers/enhanced_products_view_model.dart';
import '../../providers/products_state.dart';
import '../mvvm_screen_template.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';

class EnhancedReviewsScreen extends StatefulWidget {
  static const routeName = '/enhanced-reviews';
  final String productId;
  final String productName;

  const EnhancedReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<EnhancedReviewsScreen> createState() => _EnhancedReviewsScreenState();
}

class _EnhancedReviewsScreenState extends State<EnhancedReviewsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedProductsViewModel, ProductsState>(
      title: 'Đánh giá sản phẩm',
      onInit: (viewModel) => viewModel.getProductReviews(widget.productId),
      isLoading: (viewModel) => viewModel.isReviewsLoading,
      isEmpty: (viewModel) => viewModel.productReviews.isEmpty,
      getErrorMessage: (viewModel) => viewModel.reviewsErrorMessage,
      onRefresh: (viewModel) => viewModel.getProductReviews(widget.productId),
      buildAppBar:
          (context, viewModel) =>
              _buildAppBar(context, widget.productName, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      buildEmpty: (context, viewModel) => _buildEmptyState(context, viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String productName,
    EnhancedProductsViewModel viewModel,
  ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá', style: Theme.of(context).textTheme.titleMedium),
          Text(
            productName,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_comment),
          onPressed: () => _showAddReviewDialog(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    final reviews = viewModel.productReviews;

    return Column(
      children: [
        _buildRatingFilter(context, viewModel),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) => _buildReviewItem(reviews[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitlesTextWidget(label: 'Lọc theo đánh giá'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, null, 'Tất cả', viewModel),
                const SizedBox(width: 8),
                for (int i = 5; i >= 1; i--)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(context, i, '$i sao', viewModel),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    int? rating,
    String label,
    EnhancedProductsViewModel viewModel,
  ) {
    final isSelected = viewModel.state.selectedRatingFilter == rating;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      showCheckmark: false,
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          viewModel.getProductReviews(widget.productId, ratingFilter: rating);
        }
      },
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    final formattedDate =
        "${review.lastUpdatedTime.day}/${review.lastUpdatedTime.month}/${review.lastUpdatedTime.year}";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.ratingValue
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.reviewImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageGrid(review.reviewImages),
            ],
            if (review.reply != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.support_agent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          review.reply!.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          "${review.reply!.lastUpdatedTime.day}/${review.reply!.lastUpdatedTime.month}/${review.reply!.lastUpdatedTime.year}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review.reply!.replyContent),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullImage(context, imageUrls[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const TitlesTextWidget(label: 'Chưa có đánh giá nào'),
          const SizedBox(height: 8),
          const SubtitleTextWidget(
            label: 'Hãy là người đầu tiên đánh giá sản phẩm này!',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddReviewDialog(context, viewModel),
            icon: const Icon(Icons.add_comment),
            label: const Text('Viết đánh giá'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    int rating = 5;
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Viết đánh giá'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => IconButton(
                              icon: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                              onPressed: () {
                                setState(() {
                                  rating = index + 1;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reviewController,
                          decoration: const InputDecoration(
                            labelText: 'Nhập đánh giá của bạn',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Thêm hình ảnh: '),
                            IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  setState(() {
                                    _selectedImages.add(image);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_selectedImages[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _selectedImages.clear();
                      },
                      child: const Text('Hủy'),
                    ),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () async {
                            if (_reviewController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập nội dung đánh giá',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = true;
                            });

                            // TODO: Trong phiên bản cải thiện sau, cần thêm chức năng upload hình ảnh
                            // trước khi gửi đánh giá

                            final success = await viewModel.submitProductReview(
                              productId: widget.productId,
                              rating: rating,
                              comment: _reviewController.text.trim(),
                            );

                            if (mounted) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }

                            if (success && mounted) {
                              Navigator.of(ctx).pop();
                              _reviewController.clear();
                              _selectedImages.clear();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đánh giá đã được gửi thành công',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Gửi đánh giá'),
                        ),
                  ],
                ),
          ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 50),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
