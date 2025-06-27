import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/enhanced_user_reviews_view_model.dart';

class EditReviewModal extends StatefulWidget {
  final UserReviewModel review;

  const EditReviewModal({super.key, required this.review});
  // Static method to show the modal
  static Future<bool> show(
    BuildContext context,
    UserReviewModel review,
    EnhancedUserReviewsViewModel viewModel,
  ) async {
    // Prepare the view model for editing this review
    viewModel.prepareForEdit(review);

    // Track if the modal was dismissed using the save button
    bool wasSaved = false;

    // Trả về true nếu đã cập nhật đánh giá thành công
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: EditReviewModal(review: review),
        );
      },
    );

    // If the result is true, it means the save button was pressed
    wasSaved = result ?? false;

    // If the modal was dismissed without saving (by tapping outside or pressing back),
    // we need to clean up any uploaded images
    if (!wasSaved) {
      await viewModel.cleanupReviewImages();
    }

    // Return result or false if null
    return wasSaved;
  }

  @override
  State<EditReviewModal> createState() => _EditReviewModalState();
}

class _EditReviewModalState extends State<EditReviewModal> {
  late TextEditingController commentController;
  late int ratingValue;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController(text: widget.review.comment);
    ratingValue = widget.review.ratingValue;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(EnhancedUserReviewsViewModel viewModel) async {
    if (viewModel.editReviewImages.length >= 5) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tối đa 5 ảnh cho mỗi đánh giá'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduce image quality to save bandwidth
        maxWidth: 1200, // Limit max dimensions
      );

      if (image != null) {
        // Check file size (max 5MB)
        final fileSize = await File(image.path).length();
        final fileSizeInMB = fileSize / (1024 * 1024);

        if (fileSizeInMB > 5.0) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước ảnh quá lớn. Giới hạn tối đa 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Upload the image using the updated repository method
        final uploadedUrl = await viewModel.uploadReviewImage(image);

        if (uploadedUrl == null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                viewModel.reviewError ?? 'Không thể tải lên hình ảnh',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedUserReviewsViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with product info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.18)),
                        image: DecorationImage(
                          image: widget.review.productImageSafe.isNotEmpty
                              ? NetworkImage(widget.review.productImageSafe)
                              : const AssetImage('assets/images/error.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.review.productNameSafe,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF8F5CFF),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.review.variationOptionValues.isNotEmpty)
                            Text(
                              'Phiên bản: ${widget.review.variationOptionValues.join(", ")}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          const Text(
                            'Chỉnh sửa đánh giá',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Rating
                const Text(
                  'Xếp hạng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < ratingValue ? Icons.star : Icons.star_border,
                        color: index < ratingValue ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          ratingValue = index + 1;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Comment
                const Text(
                  'Nội dung đánh giá',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF8F5CFF).withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: const Color(0xFF8F5CFF).withOpacity(0.18)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: const Color(0xFF8F5CFF).withOpacity(0.18)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: const Color(0xFF8F5CFF), width: 2),
                    ),
                    hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm này',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hình ảnh:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${viewModel.editReviewImages.length}/5 ảnh',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Add image button
                      if (viewModel.editReviewImages.length < 5)
                        GestureDetector(
                          onTap: viewModel.isUploadingImage ? null : () => _pickImage(viewModel),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: viewModel.isUploadingImage
                                  ? const Center(child: CircularProgressIndicator())
                                  : const Icon(Icons.add_photo_alternate, color: Color(0xFF8F5CFF), size: 32),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Image previews
                      ...viewModel.editReviewImages.map(
                        (imageUrl) => Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.18)),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap:
                                    viewModel.isDeletingImage
                                        ? null
                                        : () => viewModel.deleteReviewImage(
                                          imageUrl,
                                        ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      viewModel.isDeletingImage
                                          ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.reviewError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      viewModel.reviewError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: OutlinedButton(
                          onPressed: () async {
                            await viewModel.cleanupReviewImages();
                            if (!context.mounted) return;
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Hủy', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: viewModel.isSubmittingReview
                              ? null
                              : () async {
                                  if (commentController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Vui lòng nhập nội dung đánh giá'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    final success = await viewModel.updateReview(
                                      reviewId: widget.review.id,
                                      rating: ratingValue,
                                      comment: commentController.text,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop(success);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? 'Đánh giá đã được cập nhật'
                                            : viewModel.reviewError ?? 'Không thể cập nhật đánh giá'),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop(false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi: \\${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: viewModel.isSubmittingReview
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Bottom spacing
              ],
            ),
          ),
        );
      },
    );
  }
}
