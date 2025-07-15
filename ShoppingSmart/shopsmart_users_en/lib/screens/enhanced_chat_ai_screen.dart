import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_chat_view_model.dart';
import '../screens/inner_screen/enhanced_product_detail.dart';
import '../models/chat_message.dart';
import '../widgets/app_name_text.dart';
import '../services/assets_manager.dart';

class EnhancedChatAIScreen extends StatefulWidget {
  static const routeName = '/enhanced-chat-ai';

  const EnhancedChatAIScreen({super.key});

  @override
  State<EnhancedChatAIScreen> createState() => _EnhancedChatAIScreenState();
}

class _EnhancedChatAIScreenState extends State<EnhancedChatAIScreen> {
  @override
  void initState() {
    super.initState();
    // Lấy ViewModel từ Service Locator và khởi tạo chat AI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnhancedChatViewModel>(context, listen: false).initChatAI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedChatViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F3FF),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      child: Image.asset(
                        AssetsManager.shoppingCart,
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const Expanded(
                      child: AppNameTextWidget(
                        fontSize: 22,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Tạo phiên chat mới',
                      onPressed: () async {
                        await viewModel.createNewSession();
                        await viewModel.initChatAI();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessageList(context, viewModel)),
              if (viewModel.isSending)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Nhập tin nhắn cho AI...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            onChanged: viewModel.setNewMessage,
                            onSubmitted: (_) => viewModel.sendMessageToAI(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF8F5CFF), size: 28),
                          onPressed: viewModel.isSending ? null : viewModel.sendMessageToAI,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    EnhancedChatViewModel viewModel,
  ) {
    if (viewModel.isLoading || viewModel.isInitializingAI) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.messages.isEmpty) {
      return const Center(child: Text('Không có tin nhắn'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, idx) {
        final msg = viewModel.messages[idx];
        final isLastMessage = idx == viewModel.messages.length - 1;
        final isUser = msg.type == MessageType.user;
        return Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Align(
              alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 18,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white
                      : const Color(0xFFE6DEFF),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? Colors.deepPurple : Colors.black87,
                    fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (isLastMessage &&
                !isUser &&
                msg.mentionedProducts != null &&
                msg.mentionedProducts!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children:
                      msg.mentionedProducts!
                          .map((prod) => _ProductCard(product: prod))
                          .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          EnhancedProductDetailsScreen.routeName,
          arguments: product['id'],
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          border: Border.all(color: Colors.deepPurple.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['thumbnail'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['thumbnail'],
                  height: 60,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, size: 40),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              product['name'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              product['price'] != null ? '${product['price']} đ' : '',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
