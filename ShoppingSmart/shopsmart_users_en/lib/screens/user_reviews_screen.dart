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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              title: const Text('Đánh giá của tôi'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: true,
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBCA7FF).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product row with image and name
          InkWell(
            onTap: () {
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
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: review.productImageSafe.isNotEmpty
                          ? NetworkImage(review.productImageSafe)
                          : const AssetImage('assets/images/error.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBCA7FF).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Phiên bản: ${review.variationOptionValues.join(", ")}',
                            style: const TextStyle(
                              color: Color(0xFF8F5CFF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Editable badge
                      if (review.isEditbleSafe)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Có thể chỉnh sửa',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Rating row
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                Icons.star,
                color: i < review.ratingValue
                    ? const Color(0xFF8F5CFF)
                    : Colors.grey[300],
                size: 22,
              )),
              const SizedBox(width: 8),
              Text(
                '${review.ratingValue}/5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _formatDate(review.lastUpdatedTime),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // User row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                review.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Review content
          Text(
            review.comment,
            style: const TextStyle(fontSize: 15),
          ),
          // Review images
          if (review.reviewImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Hình ảnh đính kèm:',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.reviewImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullImage(context, review.reviewImages[index]),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showEditReviewModal(context, review, viewModel),
              icon: const Icon(Icons.edit, color: Color(0xFF8F5CFF)),
              label: const Text(
                'Sửa',
                style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              ),
            ),
          ),
        ],
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
