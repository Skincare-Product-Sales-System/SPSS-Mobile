import 'package:flutter/material.dart';
// Removed flutter_rating_bar dependency
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../services/chat_service.dart';
import '../../screens/inner_screen/product_detail.dart';
import '../../consts/app_colors.dart';

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Function(String)? onImageTap;

  const MessageItem({
    super.key,
    required this.message,
    this.primaryColor,
    this.secondaryColor,
    this.onImageTap,
  });

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
    final actualSecondaryColor = secondaryColor ?? AppColors.lightAccent;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isUser ? actualSecondaryColor : Colors.white,
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
    final actualPrimaryColor = primaryColor ?? AppColors.lightPrimary;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onImageTap != null ? () => onImageTap!(imageUrl) : null,
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
    final formattedPrice = '${formatter.format(price)}₫';
    final productId = contentJson['id'] ?? contentJson['productId'] ?? '';
    final actualPrimaryColor = primaryColor ?? AppColors.lightPrimary;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      margin: const EdgeInsets.only(bottom: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(ProductDetailsScreen.routeName, arguments: productId);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: actualPrimaryColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          elevation: 2.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contentJson['image'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: contentJson['image'],
                    height: 120.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contentJson['name'] ?? 'Sản phẩm',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        color: actualPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Đã bán: ${contentJson['soldCount'] ?? 0}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return DateFormat.Hm().format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${DateFormat.Hm().format(timestamp)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }
}
