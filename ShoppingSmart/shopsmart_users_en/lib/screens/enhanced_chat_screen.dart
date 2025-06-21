import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

import '../consts/app_colors.dart';
import '../models/chat_message.dart' as model;
import '../providers/enhanced_chat_view_model.dart';
import '../providers/chat_state.dart';
import '../screens/mvvm_screen_template.dart';
import '../services/chat_service.dart' as service;
import '../widgets/chat/message_item.dart';

class EnhancedChatScreen extends StatelessWidget {
  static const routeName = '/enhanced-chat';

  const EnhancedChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedChatViewModel, ChatState>(
      title: 'Hỗ trợ khách hàng',
      onInit: (viewModel) => viewModel.initChat(),
      isLoading:
          (viewModel) => viewModel.isLoading && viewModel.messages.isEmpty,
      getErrorMessage:
          (viewModel) => viewModel.hasError ? viewModel.errorMessage : null,
      buildAppBar: (context, viewModel) => _buildAppBar(context, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EnhancedChatViewModel viewModel,
  ) {
    return AppBar(
      title: const Text('Hỗ trợ khách hàng'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: viewModel.clearChatHistory,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, EnhancedChatViewModel viewModel) {
    final ScrollController scrollController = ScrollController();

    // Scroll to bottom when new messages arrive
    if (viewModel.messages.isNotEmpty) {
      _scrollToBottom(scrollController);
    }

    return Column(
      children: [
        // Kết nối bị mất - hiển thị nút thử lại
        if (!viewModel.isConnected) _buildConnectionError(context, viewModel),

        // Danh sách tin nhắn
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.messages.length,
            itemBuilder: (context, index) {
              final modelMessage = viewModel.messages[index];
              // Chuyển đổi từ model.ChatMessage sang service.ChatMessage
              final serviceMessage = _convertChatMessage(modelMessage);
              return MessageItem(
                message: serviceMessage,
                primaryColor: AppColors.lightPrimary,
                secondaryColor: AppColors.lightAccent,
              );
            },
          ),
        ),

        // Input tin nhắn
        _buildMessageInput(context, viewModel),
      ],
    );
  }

  Widget _buildConnectionError(
    BuildContext context,
    EnhancedChatViewModel viewModel,
  ) {
    return Container(
      color: Colors.red.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          const Text('Mất kết nối với máy chủ'),
          const SizedBox(width: 8),
          TextButton(
            onPressed: viewModel.initChat,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    EnhancedChatViewModel viewModel,
  ) {
    final TextEditingController messageController = TextEditingController(
      text: viewModel.newMessage,
    );

    return Container(
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
            onPressed: viewModel.isSending ? null : viewModel.pickImage,
          ),
          // Input text
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: InputBorder.none,
              ),
              enabled: !viewModel.isSending,
              onChanged: viewModel.setNewMessage,
            ),
          ),
          // Nút gửi
          IconButton(
            icon:
                viewModel.isSending
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(Icons.send, color: AppColors.lightAccent),
            onPressed:
                viewModel.isSending
                    ? null
                    : () {
                      if (messageController.text.trim().isNotEmpty) {
                        viewModel.sendMessage();
                        messageController.clear();
                      }
                    },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
}
