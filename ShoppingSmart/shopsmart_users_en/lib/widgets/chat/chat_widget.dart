import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../consts/app_colors.dart';
import '../../screens/chat_screen.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Stack(
      children: [
        // Nút chat AI (góc dưới bên trái)
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(28.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/ChatAIScreen');
              },
              borderRadius: BorderRadius.circular(28.0),
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Nút chat với nhân viên (góc dưới bên phải)
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(28.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(ChatScreen.routeName);
              },
              borderRadius: BorderRadius.circular(28.0),
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    // Hiển thị badge nếu có tin nhắn mới
                    if (chatProvider.hasUnreadMessages)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
