import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/enhanced_chat_view_model.dart';
import '../../providers/enhanced_auth_view_model.dart';
import '../../consts/app_colors.dart';
import '../../screens/enhanced_chat_screen.dart';
import '../../screens/enhanced_chat_ai_screen.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<EnhancedChatViewModel>(context);
    final authProvider = Provider.of<EnhancedAuthViewModel>(context, listen: false);

    void showLoginRequiredDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Yêu cầu đăng nhập'),
            content: const Text('Bạn cần đăng nhập để sử dụng tính năng này.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/EnhancedLoginScreen');
                },
                child: const Text('Đăng nhập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF3EDFF),
                  foregroundColor: Color(0xFF7C4DFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          );
        },
      );
    }

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
                if (!authProvider.isLoggedIn) {
                  showLoginRequiredDialog();
                } else {
                  Navigator.of(context).pushNamed(EnhancedChatAIScreen.routeName);
                }
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
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 28.0),
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
                if (!authProvider.isLoggedIn) {
                  showLoginRequiredDialog();
                } else {
                  Navigator.of(context).pushNamed(EnhancedChatScreen.routeName);
                }
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
