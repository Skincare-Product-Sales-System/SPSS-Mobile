import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/enhanced_chat_view_model.dart';
import '../consts/app_colors.dart';
import '../widgets/chat/message_item.dart';
import '../services/chat_service.dart' as service;
import '../models/chat_message.dart' as model;

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
      final chatViewModel = Provider.of<EnhancedChatViewModel>(
        context,
        listen: false,
      );
      if (!chatViewModel.isConnected) {
        chatViewModel.initChat();
      }
      // Đánh dấu tin nhắn đã đọc khi vào màn hình chat
      chatViewModel.markMessagesAsRead();
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
  Future<void> _retryConnection(EnhancedChatViewModel chatViewModel) async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    await chatViewModel.initChat();

    setState(() {
      _isRetrying = false;
    });
  }

  // Chuyển đổi từ model.ChatMessage sang service.ChatMessage
  service.ChatMessage _convertChatMessage(model.ChatMessage modelMessage) {
    service.MessageType serviceType;
    switch (modelMessage.type) {
      case model.MessageType.user:
        serviceType = service.MessageType.user;
        break;
      case model.MessageType.staff:
        serviceType = service.MessageType.staff;
        break;
      case model.MessageType.system:
        serviceType = service.MessageType.system;
        break;
      default:
        serviceType = service.MessageType.user;
    }

    return service.ChatMessage(
      content: modelMessage.content,
      type: serviceType,
      timestamp: modelMessage.timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<EnhancedChatViewModel>(
                context,
                listen: false,
              ).clearChatHistory();
            },
          ),
        ],
      ),
      body: Consumer<EnhancedChatViewModel>(
        builder: (context, chatViewModel, child) {
          // Scroll to bottom when new messages arrive
          if (chatViewModel.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              // Kết nối bị mất - hiển thị nút thử lại
              if (!chatViewModel.isConnected && !chatViewModel.isLoading)
                Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Mất kết nối với máy chủ'),
                      const SizedBox(width: 8),
                      _isRetrying
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : TextButton(
                            onPressed: () => _retryConnection(chatViewModel),
                            child: const Text('Thử lại'),
                          ),
                    ],
                  ),
                ),

              // Danh sách tin nhắn
              Expanded(
                child:
                    chatViewModel.isLoading && chatViewModel.messages.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatViewModel.messages.length,
                          itemBuilder: (context, index) {
                            final modelMessage = chatViewModel.messages[index];
                            // Chuyển đổi từ model.ChatMessage sang service.ChatMessage
                            final serviceMessage = _convertChatMessage(
                              modelMessage,
                            );
                            return MessageItem(
                              message: serviceMessage,
                              primaryColor: AppColors.lightPrimary,
                              secondaryColor: AppColors.lightAccent,
                            );
                          },
                        ),
              ),

              // Input tin nhắn
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Nút chọn ảnh
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed:
                          chatViewModel.isSending
                              ? null
                              : () {
                                chatViewModel.pickImage();
                              },
                    ),
                    // Input text
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: InputBorder.none,
                        ),
                        enabled: !chatViewModel.isSending,
                        onChanged: (value) {
                          chatViewModel.setNewMessage(value);
                        },
                      ),
                    ),
                    // Nút gửi
                    IconButton(
                      icon:
                          chatViewModel.isSending
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(Icons.send, color: AppColors.lightAccent),
                      onPressed:
                          chatViewModel.isSending
                              ? null
                              : () {
                                if (_messageController.text.trim().isNotEmpty) {
                                  chatViewModel.sendMessage();
                                  _messageController.clear();
                                }
                              },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
