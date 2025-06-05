import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/chat_provider.dart';
import '../consts/app_colors.dart';
import '../widgets/chat/message_item.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (!chatProvider.isConnected) {
        chatProvider.initChat();
      }
      // Đánh dấu tin nhắn đã đọc khi vào màn hình chat
      chatProvider.markMessagesAsRead();
    });
  }

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

  // Thử kết nối lại khi mất kết nối
  Future<void> _retryConnection(ChatProvider chatProvider) async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    await chatProvider.initChat();

    setState(() {
      _isRetrying = false;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat với nhân viên Skincede',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Hiển thị trạng thái kết nối
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chatProvider.isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  chatProvider.isConnected ? 'Đã kết nối' : 'Mất kết nối',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          // Menu xóa lịch sử
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_history') {
                // Hiển thị dialog xác nhận
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Xóa lịch sử'),
                        content: const Text(
                          'Bạn có chắc chắn muốn xóa toàn bộ lịch sử trò chuyện không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await chatProvider.clearChatHistory();
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'clear_history',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa lịch sử'),
                      ],
                    ),
                  ),
                ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMessagesArea(context, chatProvider),
          _buildInputArea(context, chatProvider),
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
            // Hiển thị thông báo khi không có tin nhắn
            if (chatProvider.messages.isEmpty && !chatProvider.isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có tin nhắn nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy gửi tin nhắn để bắt đầu cuộc trò chuyện',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

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
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hiển thị nút kết nối lại khi mất kết nối
          if (!chatProvider.isConnected)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton.icon(
                onPressed:
                    _isRetrying ? null : () => _retryConnection(chatProvider),
                icon:
                    _isRetrying
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.refresh),
                label: Text(
                  _isRetrying ? 'Đang kết nối lại...' : 'Kết nối lại',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          Row(
            children: [
              // Image picker button
              IconButton(
                onPressed:
                    chatProvider.isConnected
                        ? () => _showImageSourceOptions(context, chatProvider)
                        : null,
                icon: Icon(
                  Icons.image,
                  color:
                      chatProvider.isConnected
                          ? AppColors.lightPrimary
                          : Colors.grey.shade400,
                ),
                tooltip: 'Send an image',
              ),

              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20.0),
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
              IconButton(
                onPressed:
                    chatProvider.isConnected &&
                            chatProvider.newMessage.trim().isNotEmpty
                        ? () {
                          chatProvider.sendMessage();
                          _messageController.clear();
                        }
                        : null,
                icon: Icon(
                  Icons.send,
                  color:
                      chatProvider.isConnected &&
                              chatProvider.newMessage.trim().isNotEmpty
                          ? AppColors.lightPrimary
                          : Colors.grey.shade400,
                ),
                tooltip: 'Send message',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show bottom sheet to select image source
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
