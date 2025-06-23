import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_chat_view_model.dart';
import '../screens/inner_screen/enhanced_product_detail.dart';
import '../models/chat_message.dart';

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
          appBar: AppBar(
            title: const Text('Chat với AI Gemini'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn cho AI...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: viewModel.setNewMessage,
                          onSubmitted: (_) => viewModel.sendMessageToAI(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed:
                            viewModel.isSending
                                ? null
                                : viewModel.sendMessageToAI,
                      ),
                    ],
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
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, idx) {
        final msg = viewModel.messages[idx];
        final isLastMessage = idx == viewModel.messages.length - 1;

        return Column(
          crossAxisAlignment:
              msg.type == MessageType.user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Align(
              alignment:
                  msg.type == MessageType.user
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color:
                      msg.type == MessageType.user
                          ? Colors.deepPurple.withOpacity(0.1)
                          : Colors.deepPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(msg.content),
              ),
            ),
            if (isLastMessage &&
                msg.type != MessageType.user &&
                viewModel.mentionedProducts != null &&
                viewModel.mentionedProducts!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      viewModel.mentionedProducts!
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
