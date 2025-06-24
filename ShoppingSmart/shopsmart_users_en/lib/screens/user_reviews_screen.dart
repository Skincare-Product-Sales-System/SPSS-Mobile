import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/enhanced_user_reviews_view_model.dart';
import '../services/service_locator.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/edit_review_modal.dart';

class EnhancedUserReviewsScreen extends StatefulWidget {
  const EnhancedUserReviewsScreen({super.key});

  static const routeName = '/user-reviews';

  @override
  State<EnhancedUserReviewsScreen> createState() =>
      _EnhancedUserReviewsScreenState();
}

class _EnhancedUserReviewsScreenState extends State<EnhancedUserReviewsScreen> {
  late final EnhancedUserReviewsViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _viewModel = sl<EnhancedUserReviewsViewModel>();
    // Load reviews immediately to show loading state
    _viewModel.loadUserReviews(refresh: true);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_viewModel.isLoading &&
          !_viewModel.isLoadingMore &&
          _viewModel.hasMoreData) {
        _viewModel.loadUserReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Đánh giá của tôi',
          automaticallyImplyLeading: true,
        ),
        body: Consumer<EnhancedUserReviewsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.reviews.isEmpty) {
              return const LoadingIndicator();
            }

            if (viewModel.hasError && viewModel.reviews.isEmpty) {
              return ErrorState(
                message: viewModel.errorMessage ?? 'Có lỗi xảy ra',
                onRetry: () => viewModel.loadUserReviews(refresh: true),
              );
            }

            if (viewModel.reviews.isEmpty) {
              return EmptyState(
                icon: Icons.rate_review_outlined,
                title: 'Không có đánh giá nào',
                subtitle:
                    'Bạn chưa có đánh giá nào. Hãy đánh giá sản phẩm để chia sẻ trải nghiệm của mình.',
                buttonText: 'Tải lại',
                onActionPressed: () => viewModel.loadUserReviews(refresh: true),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.loadUserReviews(refresh: true),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          viewModel.reviews.length +
                          (viewModel.isLoadingMore ? 1 : 0),
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index >= viewModel.reviews.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final review = viewModel.reviews[index];
                        return _buildReviewItem(context, review, viewModel);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    UserReviewModel review,
    EnhancedUserReviewsViewModel viewModel,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product row with image and name
            InkWell(
              onTap: () {
                // Navigate to product details when tapped
                if (review.productIdSafe.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: review.productIdSafe,
                  );
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image:
                            review.productImageSafe.isNotEmpty
                                ? NetworkImage(review.productImageSafe)
                                : const AssetImage('assets/images/error.png')
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product name and variant info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.productNameSafe,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Variant info
                        if (review.variationOptionValues.isNotEmpty)
                          Text(
                            'Phiên bản: ${review.variationOptionValues.join(", ")}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Editable badge
                        if (review.isEditbleSafe)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Có thể chỉnh sửa',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Rating and date
            Row(
              children: [
                // Star rating visual representation
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.ratingValue
                          ? Icons.star
                          : Icons.star_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Rating value as text
                Text(
                  '${review.ratingValue}/5',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Date
                Text(
                  _formatDate(review.lastUpdatedTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review by user
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  backgroundImage:
                      review.avatarUrl != null
                          ? NetworkImage(review.avatarUrl!)
                          : null,
                  radius: 16,
                  child:
                      review.avatarUrl == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                ),
                const SizedBox(width: 8),
                // Username
                Text(
                  review.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review comment
            Text(review.comment, style: const TextStyle(fontSize: 15)),
            // Review images
            if (review.reviewImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Hình ảnh đính kèm:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.reviewImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap:
                          () => _showFullImage(
                            context,
                            review.reviewImages[index],
                          ),
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(review.reviewImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // Reply (if any)
            if (review.reply != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              review.reply!.avatarUrl != null
                                  ? NetworkImage(review.reply!.avatarUrl!)
                                  : null,
                          radius: 12,
                          child:
                              review.reply!.avatarUrl == null
                                  ? const Icon(Icons.person, size: 10)
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review.reply!.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(review.reply!.lastUpdatedTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.reply!.replyContent,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            // Action buttons
            if (review.isEditbleSafe)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit Button
                    OutlinedButton.icon(
                      onPressed:
                          () =>
                              _showEditReviewModal(context, review, viewModel),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.shade300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // // Delete Button
                    // OutlinedButton.icon(
                    //   onPressed:
                    //       () => _confirmDelete(context, review.id, viewModel),
                    //   icon: const Icon(Icons.delete, size: 16),
                    //   label: const Text('Xóa'),
                    //   style: OutlinedButton.styleFrom(
                    //     foregroundColor: Colors.red,
                    //     side: BorderSide(color: Colors.red.shade300),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 8,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Get current time
    final now = DateTime.now();
    final difference = now.difference(date);

    // If less than 24 hours ago, show relative time
    if (difference.inHours < 24) {
      if (difference.inMinutes < 1) {
        return 'Vừa xong';
      }
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    }
    // If less than 7 days ago, show day of week
    else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }
    // Otherwise show full date
    else {
      // Format: 01/01/2023
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: -16,
                  right: -16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 5.0),
                        ],
                      ),
                      child: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Confirm delete dialog
  // Future<void> _confirmDelete(
  //   BuildContext context,
  //   String reviewId,
  //   EnhancedUserReviewsViewModel viewModel,
  // ) async {
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Xác nhận xóa'),
  //         content: const Text(
  //           'Bạn có chắc chắn muốn xóa đánh giá này? Hành động này không thể hoàn tác.',
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Hủy'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Xóa', style: TextStyle(color: Colors.red)),
  //             onPressed: () async {
  //               Navigator.of(context).pop();

  //               // Show loading indicator
  //               if (context.mounted) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Đang xóa đánh giá...'),
  //                     duration: Duration(seconds: 2),
  //                   ),
  //                 );
  //               }

  //               final success = await viewModel.deleteReview(reviewId);
  //               if (!success && context.mounted) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text(
  //                       viewModel.reviewError ?? 'Không thể xóa đánh giá',
  //                     ),
  //                     backgroundColor: Colors.red,
  //                   ),
  //                 );
  //               } else if (success && context.mounted) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Đánh giá đã được xóa thành công'),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                 );
  //               }  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // Show the edit review modal
  void _showEditReviewModal(
    BuildContext context,
    UserReviewModel review,
    EnhancedUserReviewsViewModel viewModel,
  ) async {
    // Use the EditReviewModal to show a bottom sheet
    final result = await EditReviewModal.show(context, review, viewModel);

    // Refresh reviews after editing to update isEditible status
    if (result) {
      viewModel.loadUserReviews(refresh: true);
    }
  }
}
