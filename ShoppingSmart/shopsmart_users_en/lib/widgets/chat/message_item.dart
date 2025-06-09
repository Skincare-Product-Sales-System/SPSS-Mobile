import 'package:flutter/material.dart';
// Removed flutter_rating_bar dependency
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../services/chat_service.dart';
import '../../models/chat_message_content.dart';
import '../../screens/inner_screen/product_detail.dart';

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  final Color primaryColor;
  final Color secondaryColor;
  final Function(String) onImageTap;

  const MessageItem({
    Key? key,
    required this.message,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMessageItem(context);
  }

  Widget _buildMessageItem(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(isStaff: true),

          _parseAndBuildMessageContent(context, isUser),

          if (isUser) _buildAvatar(isStaff: false),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isStaff}) {
    return Container(
      width: 32.0,
      height: 32.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Icon(
          isStaff ? Icons.support_agent : Icons.person,
          color: Colors.blue,
          size: 18.0,
        ),
      ),
    );
  }

  Widget _parseAndBuildMessageContent(BuildContext context, bool isUser) {
    try {
      // Try to parse as JSON
      final contentJson = jsonDecode(message.content);

      // Check if it's a product message
      if (contentJson['type'] == 'product') {
        return _buildProductMessage(context, contentJson, isUser);
      }
      // Check if it's an image message
      else if (contentJson['type'] == 'image') {
        return _buildImageMessage(context, contentJson, isUser);
      }
      // Otherwise treat as text
      else {
        return _buildTextMessage(context, message.content, isUser);
      }
    } catch (e) {
      // Not a JSON message, build as regular text
      return _buildTextMessage(context, message.content, isUser);
    }
  }

  Widget _buildTextMessage(BuildContext context, String content, bool isUser) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isUser ? secondaryColor : Colors.white,
        borderRadius:
            isUser
                ? const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                  topRight: Radius.circular(4.0),
                )
                : const BorderRadius.only(
                  topRight: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                  topLeft: Radius.circular(4.0),
                ),
        border: isUser ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            content,
            style: TextStyle(color: isUser ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 4.0),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10.0,
              color: isUser ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(
    BuildContext context,
    Map<String, dynamic> contentJson,
    bool isUser,
  ) {
    final imageUrl = contentJson['url'] as String;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onImageTap(imageUrl),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: 300.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  isUser
                      ? const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        topRight: Radius.circular(4.0),
                      )
                      : const BorderRadius.only(
                        topRight: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        topLeft: Radius.circular(4.0),
                      ),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(fontSize: 10.0, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildProductMessage(
    BuildContext context,
    Map<String, dynamic> contentJson,
    bool isUser,
  ) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final price = contentJson['price'] ?? 0.0;
    final formattedPrice = formatter.format(price) + '₫';
    final productId = contentJson['id'] ?? contentJson['productId'] ?? '';

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (productId.isNotEmpty) {
              Navigator.of(
                context,
              ).pushNamed(ProductDetailsScreen.routName, arguments: productId);
            } else {
              // Hiển thị thông báo nếu không có ID
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể mở sản phẩm này'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: CachedNetworkImage(
                        imageUrl: contentJson['image'] ?? '',
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contentJson['name'] ?? 'Sản phẩm',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Text(
                              '${contentJson['rating'] ?? 4.5}/5',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                final rating =
                                    (contentJson['rating'] ?? 4.5).toDouble();
                                return Icon(
                                  index < rating.floor()
                                      ? Icons.star
                                      : (index < rating && rating % 1 >= 0.5)
                                      ? Icons.star_half
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 12.0,
                                );
                              }),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '|',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Đã bán: ${contentJson['soldCount'] ?? 0}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          formattedPrice,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(fontSize: 10.0, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
