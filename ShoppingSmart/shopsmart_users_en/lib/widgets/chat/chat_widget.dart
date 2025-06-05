import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../consts/app_colors.dart';
import 'message_item.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to bottom when new messages arrive
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    // Scroll to bottom when messages change
    if (chatProvider.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return _buildChatWidget(context, chatProvider);
  }

  Widget _buildChatWidget(BuildContext context, ChatProvider chatProvider) {
    // Chat floating button
    if (!chatProvider.isOpen) {
      return _buildChatButton(chatProvider);
    }

    // Full chat interface
    return _buildChatInterface(context, chatProvider);
  }

  Widget _buildChatButton(ChatProvider chatProvider) {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(28.0),
        child: InkWell(
          onTap: () => chatProvider.toggleChat(),
          borderRadius: BorderRadius.circular(28.0),
          child: Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: const Center(
              child: Icon(Icons.chat_bubble, color: Colors.white, size: 24.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatInterface(BuildContext context, ChatProvider chatProvider) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      bottom: 16.0,
      left: 16.0,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: size.width > 600 ? 600 : size.width - 32,
          height: size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildChatHeader(chatProvider),
              _buildMessagesArea(context, chatProvider),
              _buildInputArea(context, chatProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader(ChatProvider chatProvider) {
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.chat, color: Colors.white, size: 20.0),
          const SizedBox(width: 8.0),
          const Text(
            'Chat với nhân viên Skincede',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => chatProvider.toggleChat(),
            icon: const Icon(Icons.close, color: Colors.white, size: 20.0),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(BuildContext context, ChatProvider chatProvider) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // Messages list
            ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                return MessageItem(
                  message: message,
                  primaryColor: AppColors.lightPrimary,
                  secondaryColor: AppColors.lightPrimary,
                  onImageTap: chatProvider.setPreviewImage,
                );
              },
            ),

            // Loading indicator
            if (chatProvider.isLoading)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                      SizedBox(width: 12.0),
                      Text('Đang tải...'),
                    ],
                  ),
                ),
              ),

            // Image preview overlay
            if (chatProvider.previewImageUrl != null)
              _buildImagePreview(context, chatProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, ChatProvider chatProvider) {
    return GestureDetector(
      onTap: () => chatProvider.setPreviewImage(null),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  child: Image.network(
                    chatProvider.previewImageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => chatProvider.setPreviewImage(null),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image upload button
              _buildImageButton(chatProvider),

              // Text input
              Expanded(
                child: Container(
                  height: 56.0,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    enabled: chatProvider.isConnected,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      hintText: 'Nhập tin nhắn của bạn...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => chatProvider.setNewMessage(value),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        chatProvider.sendMessage();
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ),

              // Send button
              _buildSendButton(chatProvider),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            chatProvider.isConnected
                ? 'Bạn đang kết nối với nhân viên Skincede'
                : 'Đang kết nối...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(ChatProvider chatProvider) {
    return InkWell(
      onTap:
          chatProvider.isConnected
              ? () => _showImageSourceOptions(context, chatProvider)
              : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 48.0,
        height: 56.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightPrimary.withOpacity(
              chatProvider.isConnected ? 1.0 : 0.5,
            ),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child:
              chatProvider.isUploading
                  ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.lightPrimary,
                      ),
                    ),
                  )
                  : Icon(
                    Icons.image,
                    color: AppColors.lightPrimary.withOpacity(
                      chatProvider.isConnected ? 1.0 : 0.5,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSendButton(ChatProvider chatProvider) {
    final bool canSend =
        chatProvider.isConnected &&
        chatProvider.newMessage.trim().isNotEmpty &&
        !chatProvider.isLoading;

    return Material(
      color: AppColors.lightPrimary,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      child: InkWell(
        onTap:
            canSend
                ? () {
                  chatProvider.sendMessage();
                  _messageController.clear();
                }
                : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        child: Container(
          width: 56.0,
          height: 56.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
            color:
                canSend
                    ? AppColors.lightPrimary
                    : AppColors.lightPrimary.withOpacity(0.5),
          ),
          child:
              chatProvider.isLoading
                  ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.send, color: Colors.white),
        ),
      ),
    );
  }

  void _showImageSourceOptions(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.pop(context);
                    chatProvider.pickAndSendImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    chatProvider.pickAndSendImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
