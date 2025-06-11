import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatAIScreen extends StatefulWidget {
  static const routeName = '/ChatAIScreen';
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Lấy danh sách sản phẩm từ API
      final products = await _fetchProducts();
      // Tạo prompt giới thiệu
      final introPrompt = _buildIntroPrompt(products);
      // Gửi prompt cho Gemini để AI chào khách
      final aiReply = await _callGeminiAPI(introPrompt);
      setState(() {
        _messages.add(_Message(aiReply, false));
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message('Lỗi khi lấy dữ liệu sản phẩm hoặc chào AI: $e', false));
        _initialized = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final url = Uri.parse('http://10.0.2.2:5041/api/products?pageNumber=1&pageSize=10&sortBy=newest');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final items = data['data']['items'] as List<dynamic>;
      return items.cast<Map<String, dynamic>>();
    } else {
      throw 'Không lấy được danh sách sản phẩm: ${res.body}';
    }
  }

  String _buildIntroPrompt(List<Map<String, dynamic>> products) {
    final productList = products.map((p) =>
      '${p['name']}: ${p['description'] ?? ''}').join('\n');
    return '''
Bạn là trợ lý ảo của Skincede - một website thương mại điện tử chuyên bán đồ skincare chính hãng. 
Tên web/app là Skincede. Khi khách hỏi về sản phẩm, chỉ được trả lời dựa trên danh sách sản phẩm dưới đây, không được bịa ra sản phẩm khác, không trả lời về thương hiệu khác, không nói mình là AI của Google.

Danh sách sản phẩm hiện có:
$productList

Khi khách nhắn tin lần đầu, hãy chào đúng mẫu sau (có thể thêm icon cảm xúc):
"Chào bạn yêu skincare! Mình là Skincede đây ạ. 🥰\nRất vui vì bạn đã ghé thăm Skincede - thiên đường skincare chính hãng! ✨\nBạn đang quan tâm đến sản phẩm nào hay có bất kỳ vấn đề về da cần tư vấn không ạ? Hãy cho Skincede biết để mình có thể giúp bạn lựa chọn được sản phẩm phù hợp nhất nha! 💬"

Nếu khách hỏi ngoài phạm vi sản phẩm trên, hãy trả lời: "Xin lỗi, mình chỉ hỗ trợ tư vấn các sản phẩm của Skincede thôi ạ."
Luôn xưng là Skincede, trả lời thân thiện, ngắn gọn, đúng trọng tâm.
''';
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true));
      _isLoading = true;
      _controller.clear();
    });
    try {
      // Lấy lại sản phẩm mới nhất mỗi lần gửi
      final products = await _fetchProducts();
      final introPrompt = _buildIntroPrompt(products);

      // Tạo danh sách messages gửi lên Gemini: prompt hệ thống + hội thoại
      final List<Map<String, dynamic>> geminiMessages = [
        {
          "role": "user",
          "parts": [
            {"text": introPrompt}
          ]
        },
        ..._messages.map((msg) => {
          "role": msg.isUser ? "user" : "model",
          "parts": [
            {"text": msg.text}
          ]
        }).toList(),
        {
          "role": "user",
          "parts": [
            {"text": text}
          ]
        },
      ];

      final aiReply = await _callGeminiAPIWithMessages(geminiMessages);
      // Tìm các sản phẩm được nhắc đến trong câu trả lời
      final mentioned = extractMentionedProducts(aiReply, products);
      setState(() {
        _messages.add(_Message(aiReply, false, mentionedProducts: mentioned));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message('Lỗi khi gọi AI: $e', false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> extractMentionedProducts(String aiReply, List<Map<String, dynamic>> products) {
    final mentioned = <Map<String, dynamic>>[];
    for (final p in products) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty && aiReply.toLowerCase().contains(name)) {
        mentioned.add(p);
      }
    }
    return mentioned;
  }

  Future<String> _callGeminiAPI(String prompt) async {
    const apiKey = 'AIzaSyBDX1bPxSJl5U3riYSjS9JCs1pyfb3B4AE';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      "contents": [
        {"parts": [{"text": prompt}]}
      ]
    });
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'Không nhận được phản hồi từ AI.';
    } else {
      throw 'Gemini API trả về lỗi: ${res.body}';
    }
  }

  Future<String> _callGeminiAPIWithMessages(List<Map<String, dynamic>> messages) async {
    const apiKey = 'AIzaSyBDX1bPxSJl5U3riYSjS9JCs1pyfb3B4AE';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      "contents": messages,
    });
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'Không nhận được phản hồi từ AI.';
    } else {
      throw 'Gemini API trả về lỗi: ${res.body}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat với AI Gemini'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return Column(
                  crossAxisAlignment: msg.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? Colors.deepPurple.withOpacity(0.1)
                              : Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(msg.text),
                      ),
                    ),
                    if (!msg.isUser && msg.mentionedProducts != null && msg.mentionedProducts!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: msg.mentionedProducts!.map((prod) => _ProductCard(product: prod)).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading)
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
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn cho AI...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final List<Map<String, dynamic>>? mentionedProducts;
  _Message(this.text, this.isUser, {this.mentionedProducts});
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/ProductDetailsScreen', arguments: product['id']);
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
              style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
} 