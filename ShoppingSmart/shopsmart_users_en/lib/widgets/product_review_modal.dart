import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_order_view_model.dart';

class ProductReviewModal extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final String? orderId;

  const ProductReviewModal({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    this.orderId,
  });

  // Static method to show the modal
  static Future<void> show(
    BuildContext context,
    String productId,
    String productName,
    String productImage, {
    String? orderId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProductReviewModal(
          productId: productId,
          productName: productName,
          productImage: productImage,
          orderId: orderId,
        );
      },
    );
  }

  @override
  State<ProductReviewModal> createState() => _ProductReviewModalState();
}

class _ProductReviewModalState extends State<ProductReviewModal> {
  int rating = 0;
  late TextEditingController commentController;
  final imagePicker = ImagePicker();
  bool isDisposed = false;
  bool reviewSubmitted = false; // Track if review was submitted successfully

  // Track local image files for UI display
  final List<XFile> imageFiles = [];
  final Map<String, String> imageUrlByPath = {};
  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();

    // Đảm bảo xóa state liên quan đến review ngay khi mở form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EnhancedOrderViewModel>(
        context,
        listen: false,
      );
      // Reset state trong ViewModel
      viewModel.cleanupReviewImages();
      // Reset biến cục bộ
      setState(() {
        imageFiles.clear();
        imageUrlByPath.clear();
        rating = 0;
      });

      // Debug log
      debugPrint('PRODUCT REVIEW MODAL INITIALIZED - ALL STATES CLEARED');
    });
  }

  @override
  void dispose() {
    if (!isDisposed) {
      commentController.dispose();

      // Check if we need to clean up images when the modal is dismissed
      // Only do this if the review wasn't successfully submitted
      if (!reviewSubmitted) {
        final viewModel = Provider.of<EnhancedOrderViewModel>(
          context,
          listen: false,
        );

        // If there are images to clean up, schedule the cleanup after the dispose
        if (viewModel.reviewImages.isNotEmpty) {
          debugPrint('Cleaning up images in dispose');
          // Use a post-frame callback to avoid calling setState during dispose
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _deleteUploadedImages(viewModel);
          });
        }
      }

      isDisposed = true;
    }
    super.dispose();
  }

  // Upload image method
  Future<void> uploadImage(XFile image) async {
    if (!mounted) return;

    final viewModel = Provider.of<EnhancedOrderViewModel>(
      context,
      listen: false,
    );
    final uploadedUrl = await viewModel.uploadReviewImage(image);

    if (uploadedUrl != null && mounted) {
      setState(() {
        imageUrlByPath[image.path] = uploadedUrl;
        imageFiles.add(image);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.reviewError ??
                'Không thể tải lên hình ảnh. Vui lòng thử lại!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Remove image method
  Future<void> removeImage(XFile image) async {
    if (!mounted) return;

    final viewModel = Provider.of<EnhancedOrderViewModel>(
      context,
      listen: false,
    );
    final url = imageUrlByPath[image.path];

    if (url != null) {
      final success = await viewModel.deleteReviewImage(url);
      if (success && mounted) {
        setState(() {
          imageFiles.remove(image);
          imageUrlByPath.remove(image.path);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.reviewError ??
                  'Không thể xóa hình ảnh. Vui lòng thử lại!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (mounted) {
      setState(() {
        imageFiles.remove(image);
        imageUrlByPath.remove(image.path);
      });
    }
  }

  // Submit review method
  Future<void> submitReview() async {
    if (!mounted) return;

    final viewModel = Provider.of<EnhancedOrderViewModel>(
      context,
      listen: false,
    );

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn xếp hạng sao'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Trước khi submit, log ra số lượng hình ảnh để debug
      debugPrint(
        'SUBMITTING REVIEW - LOCAL IMAGES: ${imageFiles.length}, URL MAPPING: ${imageUrlByPath.length}',
      );

      final success = await viewModel.createProductReview(
        productItemId: widget.productId,
        rating: rating,
        comment: commentController.text.trim(),
        orderId: widget.orderId,
      );
      if (success && mounted) {
        // Clean up local image tracking state
        setState(() {
          imageFiles.clear();
          imageUrlByPath.clear();
          reviewSubmitted = true; // Mark review as submitted successfully
        });

        // Thêm lần reset state từ ViewModel
        viewModel.cleanupReviewImages();

        debugPrint('REVIEW SUBMITTED SUCCESSFULLY - ALL STATES CLEARED');

        Navigator.of(
          context,
        ).pop(true); // Return true to indicate successful review
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        // Nếu submit thất bại, vẫn clear state
        setState(() {
          imageFiles.clear();
          imageUrlByPath.clear();
        });

        // Thêm lần reset state từ ViewModel
        viewModel.cleanupReviewImages();

        debugPrint('REVIEW SUBMISSION FAILED - ALL STATES CLEARED ANYWAY');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.reviewError ??
                  'Không thể gửi đánh giá. Vui lòng thử lại!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Nếu có lỗi, vẫn clear state
        setState(() {
          imageFiles.clear();
          imageUrlByPath.clear();
        });

        // Thêm lần reset state từ ViewModel
        viewModel.cleanupReviewImages();

        debugPrint('REVIEW SUBMISSION ERROR - ALL STATES CLEARED ANYWAY: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Helper method to delete all uploaded images when user cancels
  Future<void> _deleteUploadedImages(EnhancedOrderViewModel viewModel) async {
    // Create a copy of the images list to avoid modification during iteration
    final imagesToDelete = List<String>.from(viewModel.reviewImages);

    if (imagesToDelete.isNotEmpty) {
      debugPrint('Deleting ${imagesToDelete.length} unused review images');

      // Delete each image on the server
      for (final imageUrl in imagesToDelete) {
        try {
          await viewModel.deleteReviewImage(imageUrl);
          debugPrint('Successfully deleted image: $imageUrl');
        } catch (e) {
          debugPrint('Failed to delete image: $imageUrl, error: $e');
          // Continue with next image even if one fails
        }
      }

      // Make sure the images list is cleared from the state
      viewModel.cleanupReviewImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EnhancedOrderViewModel>(context);

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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Đánh giá sản phẩm',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Xếp hạng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhận xét của bạn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Chia sẻ cảm nhận của bạn về sản phẩm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thêm hình ảnh (có thể chọn nhiều ảnh)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add image button
                  InkWell(
                    onTap:
                        !viewModel.isSubmittingReview
                            ? () async {
                              try {
                                final List<XFile> pickedImages =
                                    await imagePicker.pickMultiImage(
                                      imageQuality: 70,
                                    );

                                if (pickedImages.isNotEmpty) {
                                  for (final image in pickedImages) {
                                    await uploadImage(image);
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi khi chọn ảnh: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                            : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 36,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Selected images (showing local files with upload status)
                  ...imageFiles.map((image) {
                    final isUploading = viewModel.isUploadingImage;

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 5,
                          right: 13,
                          child: InkWell(
                            onTap:
                                isUploading || viewModel.isSubmittingReview
                                    ? null
                                    : () => removeImage(image),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        !viewModel.isSubmittingReview
                            ? () {
                              // Delete all uploaded images before closing the modal
                              _deleteUploadedImages(viewModel);
                              Navigator.of(context).pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        !viewModel.isSubmittingReview &&
                                rating > 0 &&
                                !viewModel.isUploadingImage
                            ? submitReview
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        !viewModel.isSubmittingReview
                            ? const Text(
                              'Gửi đánh giá',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                            : const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
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
  }
}
