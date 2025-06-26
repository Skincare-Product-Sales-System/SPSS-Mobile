import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/chat_service.dart';
import '../models/view_state.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'chat_state.dart';
import '../models/chat_message.dart' as model;
import 'package:path/path.dart' as path;

/// ViewModel cải tiến cho Chat, kế thừa từ BaseViewModel
class EnhancedChatViewModel extends BaseViewModel<ChatState> {
  final ChatService _chatService;
  static const int MAX_RETRY_ATTEMPTS = 3;

  /// Constructor với dependency injection cho service
  EnhancedChatViewModel({ChatService? chatService})
    : _chatService = chatService ?? sl<ChatService>(),
      super(const ChatState()) {
    _initialize();
  }

  /// Getters tiện ích
  List<model.ChatMessage> get messages => state.messages.data ?? [];
  bool get isLoading => state.messages.isLoading;
  bool get isSending => state.isSending;
  bool get isOpen => state.isOpen;
  bool get isConnected => state.isConnected;
  bool get hasUnreadMessages => state.hasUnreadMessages;
  int get connectionAttempts => state.connectionAttempts;
  String get newMessage => state.newMessage;
  String? get previewImageUrl => state.previewImageUrl;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage != null;
  List<Map<String, dynamic>>? get mentionedProducts => state.mentionedProducts;
  bool get isInitializingAI => state.isInitializingAI;

  /// Khởi tạo ViewModel
  Future<void> _initialize() async {
    await _chatService.initialize();
    _chatService.onMessageReceived = _handleMessageReceived;
  }

  /// Mở/đóng chat
  void toggleChat() {
    final newIsOpen = !state.isOpen;
    updateState(state.copyWith(isOpen: newIsOpen));

    if (newIsOpen && !state.isConnected) {
      _connectToChat();
      _loadChatHistory();
    }
  }

  /// Khởi tạo chat khi vào màn hình chat riêng biệt
  Future<void> initChat() async {
    if (!state.isConnected) {
      await _connectToChat();
      await _loadChatHistory();
    }
  }

  /// Kết nối với chat service
  Future<void> _connectToChat() async {
    // Cập nhật state để hiển thị loading
    updateState(
      state.copyWith(
        messages: ViewState.loading(),
        connectionAttempts: state.connectionAttempts + 1,
      ),
    );

    try {
      final connected = await _chatService.connect();

      updateState(
        state.copyWith(
          isConnected: connected,
          errorMessage: connected ? null : 'Không thể kết nối với server chat',
        ),
      );

      if (connected) {
        _addSystemMessage('Đã kết nối với hỗ trợ viên.');
      } else if (state.connectionAttempts >= MAX_RETRY_ATTEMPTS) {
        _addSystemMessage(
          'Không thể kết nối sau ${state.connectionAttempts} lần thử. Vui lòng thử lại sau.',
        );
      }
    } catch (e) {
      handleError(e, source: 'ChatViewModel._connectToChat');
      updateState(
        state.copyWith(
          isConnected: false,
          errorMessage: 'Lỗi kết nối: ${e.toString()}',
        ),
      );
    }
  }

  /// Tải lịch sử chat
  Future<void> _loadChatHistory() async {
    updateState(state.copyWith(messages: ViewState.loading()));

    try {
      // Chỉ giữ lại tin nhắn hệ thống
      final systemMessages =
          messages
              .where((msg) => msg.type == model.MessageType.system)
              .toList();

      // Tải tin nhắn từ bộ nhớ
      final chatHistory = await _chatService.loadChatHistory();

      // Chuyển đổi từ ChatMessage của service sang ChatMessage của model
      final convertedHistory =
          chatHistory
              .map(
                (msg) => model.ChatMessage(
                  content: msg.content,
                  type: _convertMessageType(msg.type),
                  timestamp: msg.timestamp,
                ),
              )
              .toList();

      // Kết hợp tin nhắn
      final List<model.ChatMessage> allMessages = [
        ...systemMessages,
        ...convertedHistory,
      ];

      updateState(state.copyWith(messages: ViewState.loaded(allMessages)));
    } catch (e) {
      handleError(e, source: 'ChatViewModel._loadChatHistory');
      updateState(
        state.copyWith(
          messages: ViewState.error('Không thể tải lịch sử chat'),
          errorMessage: 'Lỗi khi tải lịch sử chat: ${e.toString()}',
        ),
      );
    }
  }

  /// Chuyển đổi MessageType từ service sang model
  model.MessageType _convertMessageType(MessageType type) {
    switch (type) {
      case MessageType.user:
        return model.MessageType.user;
      case MessageType.staff:
        return model.MessageType.staff;
      case MessageType.system:
        return model.MessageType.system;
      default:
        return model.MessageType.system;
    }
  }

  /// Xóa lịch sử chat
  Future<void> clearChatHistory() async {
    updateState(state.copyWith(messages: ViewState.loading()));

    try {
      // Xóa tin nhắn từ bộ nhớ
      await _chatService.clearChatHistory();

      // Chỉ giữ lại tin nhắn hệ thống
      final systemMessages =
          messages
              .where((msg) => msg.type == model.MessageType.system)
              .toList();

      _addSystemMessage('Lịch sử trò chuyện đã được xóa.');

      updateState(state.copyWith(messages: ViewState.loaded(systemMessages)));
    } catch (e) {
      handleError(e, source: 'ChatViewModel.clearChatHistory');
      updateState(
        state.copyWith(
          errorMessage: 'Lỗi khi xóa lịch sử chat: ${e.toString()}',
        ),
      );
    }
  }

  /// Xử lý tin nhắn nhận được từ server
  void _handleMessageReceived(ChatMessage message) {
    // Chuyển đổi từ ChatMessage của service sang ChatMessage của model
    final modelMessage = model.ChatMessage(
      content: message.content,
      type: _convertMessageType(message.type),
      timestamp: message.timestamp,
    );

    final updatedMessages = [...messages, modelMessage];

    // Nếu tin nhắn đến từ nhân viên và chat không mở, đánh dấu có tin mới
    final hasUnread =
        message.type == MessageType.staff && !state.isOpen
            ? true
            : state.hasUnreadMessages;

    updateState(
      state.copyWith(
        messages: ViewState.loaded(updatedMessages),
        hasUnreadMessages: hasUnread,
      ),
    );
  }

  /// Thêm tin nhắn hệ thống
  void _addSystemMessage(String content) {
    final systemMessage = model.ChatMessage(
      content: content,
      type: model.MessageType.system,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...messages, systemMessage];
    updateState(state.copyWith(messages: ViewState.loaded(updatedMessages)));
  }

  /// Cập nhật nội dung tin nhắn mới
  void setNewMessage(String message) {
    updateState(state.copyWith(newMessage: message));
  }

  /// Gửi tin nhắn văn bản
  Future<void> sendMessage() async {
    if (state.newMessage.trim().isEmpty) return;

    final messageText = state.newMessage.trim();

    // Cập nhật state để xóa tin nhắn đang soạn và hiển thị đang gửi
    updateState(state.copyWith(newMessage: '', isSending: true));

    // Thêm tin nhắn vào danh sách ngay lập tức để phản hồi UI
    final userMessage = model.ChatMessage(
      content: messageText,
      type: model.MessageType.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...messages, userMessage];
    updateState(state.copyWith(messages: ViewState.loaded(updatedMessages)));

    try {
      // Thử kết nối lại nếu chưa kết nối
      if (!state.isConnected) {
        _addSystemMessage('Đang thử kết nối lại...');
        final connected = await _chatService.connect();
        updateState(state.copyWith(isConnected: connected));
      }

      // Gửi tin nhắn đến server
      await _chatService.sendMessage(messageText);

      // Cập nhật state sau khi gửi thành công
      updateState(state.copyWith(isSending: false));
    } catch (e) {
      handleError(e, source: 'ChatViewModel.sendMessage');

      _addSystemMessage('Không thể gửi tin nhắn. Vui lòng thử lại sau.');

      updateState(
        state.copyWith(
          isSending: false,
          errorMessage: 'Lỗi khi gửi tin nhắn: ${e.toString()}',
        ),
      );
    }
  }

  /// Chọn ảnh từ thư viện
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Cập nhật state để hiển thị đang gửi
        updateState(state.copyWith(isSending: true));

        final file = File(pickedFile.path);

        // Upload ảnh lên Firebase Storage
        final uploadedUrl = await uploadImageToFirebase(file);

        if (uploadedUrl == null) {
          // Nếu upload thất bại, hiển thị thông báo lỗi
          _addSystemMessage('Không thể tải lên ảnh. Vui lòng thử lại sau.');
          updateState(state.copyWith(isSending: false));
          return;
        }

        // Thêm tin nhắn ảnh vào danh sách với URL từ Firebase
        final imageContent = jsonEncode({
          'type': 'image',
          'url': uploadedUrl, // Sử dụng URL từ Firebase
        });

        final imageMessage = model.ChatMessage(
          content: imageContent,
          type: model.MessageType.user,
          timestamp: DateTime.now(),
        );

        final updatedMessages = [...messages, imageMessage];
        updateState(
          state.copyWith(messages: ViewState.loaded(updatedMessages)),
        );

        // Thử kết nối lại nếu chưa kết nối
        if (!state.isConnected) {
          _addSystemMessage('Đang thử kết nối lại...');
          final connected = await _chatService.connect();
          updateState(state.copyWith(isConnected: connected));
        }

        // Gửi ảnh đến server với URL từ Firebase
        final imageData = {'type': 'image', 'url': uploadedUrl};
        await _chatService.sendMessage(jsonEncode(imageData));

        // Cập nhật state sau khi gửi thành công
        updateState(state.copyWith(isSending: false));
      }
    } catch (e) {
      handleError(e, source: 'ChatViewModel.pickImage');

      _addSystemMessage('Không thể gửi ảnh. Vui lòng thử lại sau.');

      updateState(
        state.copyWith(
          isSending: false,
          errorMessage: 'Lỗi khi chọn ảnh: ${e.toString()}',
        ),
      );
    }
  }

  /// Gửi ảnh - Phương thức này không còn được sử dụng trực tiếp
  /// vì ảnh được gửi ngay trong pickImage()
  Future<void> sendImage() async {
    if (state.previewImageUrl == null) return;

    updateState(state.copyWith(isSending: true));

    try {
      final file = File(state.previewImageUrl!);

      // Upload ảnh lên Firebase Storage
      final uploadedUrl = await uploadImageToFirebase(file);

      if (uploadedUrl == null) {
        // Nếu upload thất bại, hiển thị thông báo lỗi
        _addSystemMessage('Không thể tải lên ảnh. Vui lòng thử lại sau.');
        updateState(state.copyWith(isSending: false, previewImageUrl: null));
        return;
      }

      // Thêm tin nhắn ảnh vào danh sách với URL từ Firebase
      final imageContent = jsonEncode({
        'type': 'image',
        'url': uploadedUrl, // Sử dụng URL từ Firebase
      });

      final imageMessage = model.ChatMessage(
        content: imageContent,
        type: model.MessageType.user,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...messages, imageMessage];
      updateState(
        state.copyWith(
          messages: ViewState.loaded(updatedMessages),
          previewImageUrl: null,
        ),
      );

      // Thử kết nối lại nếu chưa kết nối
      if (!state.isConnected) {
        _addSystemMessage('Đang thử kết nối lại...');
        final connected = await _chatService.connect();
        updateState(state.copyWith(isConnected: connected));
      }

      // Gửi ảnh đến server với URL từ Firebase
      final imageData = {'type': 'image', 'url': uploadedUrl};
      await _chatService.sendMessage(jsonEncode(imageData));

      updateState(state.copyWith(isSending: false));
    } catch (e) {
      handleError(e, source: 'ChatViewModel.sendImage');

      _addSystemMessage('Không thể gửi ảnh. Vui lòng thử lại sau.');

      updateState(
        state.copyWith(
          isSending: false,
          previewImageUrl: null,
          errorMessage: 'Lỗi khi gửi ảnh: ${e.toString()}',
        ),
      );
    }
  }

  /// Hủy gửi ảnh
  void cancelImageSend() {
    updateState(state.copyWith(previewImageUrl: null));
  }

  /// Upload ảnh lên Firebase Storage và lấy URL
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      // Tạo tên file duy nhất dựa trên thời gian
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      // Sử dụng API endpoint để upload ảnh
      final url = Uri.parse('https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api/images');

      // Tạo multipart request
      final request = http.MultipartRequest('POST', url);

      // Thêm file vào request với tên tham số đúng là 'files' thay vì 'file'
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'files', // Sửa tên tham số thành 'files' theo API
        fileStream,
        fileLength,
        filename: fileName,
      );

      request.files.add(multipartFile);

      // Gửi request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Đọc response
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        // Kiểm tra success
        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          // Lấy URL từ response (phần tử đầu tiên trong mảng data)
          final fileUrl = jsonData['data'][0];
          print('Upload ảnh thành công: $fileUrl');
          return fileUrl;
        } else {
          print('Response không có URL: $jsonData');
          return null;
        }
      } else {
        // Đọc response body để debug
        final responseBody = await response.stream.bytesToString();
        print('Lỗi upload ảnh: ${response.statusCode}, Body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }

  /// Đánh dấu đã đọc tin nhắn
  void markMessagesAsRead() {
    if (state.hasUnreadMessages) {
      updateState(state.copyWith(hasUnreadMessages: false));
    }
  }

  /// Phương thức cho ChatAI
  Future<void> initChatAI() async {
    updateState(
      state.copyWith(isInitializingAI: true, messages: ViewState.loading()),
    );
    try {
      // Lấy danh sách sản phẩm từ API
      final products = await _fetchProducts();
      // Tạo prompt giới thiệu
      final introPrompt = _buildIntroPrompt(products);
      // Gửi prompt cho Gemini để AI chào khách
      final aiReply = await _callGeminiAPI(introPrompt);

      final aiMessage = model.ChatMessage(
        content: aiReply,
        type: model.MessageType.staff,
        timestamp: DateTime.now(),
      );

      updateState(
        state.copyWith(
          messages: ViewState.loaded([aiMessage]),
          isInitializingAI: false,
        ),
      );
    } catch (e) {
      handleError(e, source: 'ChatViewModel.initChatAI');

      final errorMessage = model.ChatMessage(
        content: 'Lỗi khi lấy dữ liệu sản phẩm hoặc chào AI: ${e.toString()}',
        type: model.MessageType.system,
        timestamp: DateTime.now(),
      );

      updateState(
        state.copyWith(
          messages: ViewState.loaded([errorMessage]),
          isInitializingAI: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final url = Uri.parse(
      'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api/products?pageNumber=1&pageSize=10&sortBy=newest',
    );
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
    final productList = products
        .map((p) => '${p['name']}: ${p['description'] ?? ''}')
        .join('\n');
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

  Future<String> _callGeminiAPI(String prompt) async {
    const apiKey = 'AIzaSyBDX1bPxSJl5U3riYSjS9JCs1pyfb3B4AE';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
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

  Future<void> sendMessageToAI() async {
    if (state.newMessage.trim().isEmpty) return;

    final text = state.newMessage.trim();
    updateState(state.copyWith(newMessage: '', isSending: true));

    try {
      // Thêm tin nhắn người dùng vào danh sách
      final userMessage = model.ChatMessage(
        content: text,
        type: model.MessageType.user,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...messages, userMessage];
      updateState(state.copyWith(messages: ViewState.loaded(updatedMessages)));

      // Lấy lại sản phẩm mới nhất mỗi lần gửi
      final products = await _fetchProducts();
      final introPrompt = _buildIntroPrompt(products);

      // Tạo danh sách messages gửi lên Gemini: prompt hệ thống + hội thoại
      final List<Map<String, dynamic>> geminiMessages = [
        {
          "role": "user",
          "parts": [
            {"text": introPrompt},
          ],
        },
      ];

      // Thêm tin nhắn trước đó vào danh sách
      for (final msg in messages) {
        geminiMessages.add({
          "role": msg.type == model.MessageType.user ? "user" : "model",
          "parts": [
            {"text": msg.content},
          ],
        });
      }

      // Thêm tin nhắn mới
      geminiMessages.add({
        "role": "user",
        "parts": [
          {"text": text},
        ],
      });

      final aiReply = await _callGeminiAPIWithMessages(geminiMessages);

      // Tìm các sản phẩm được nhắc đến trong câu trả lời
      final mentioned = _extractMentionedProducts(aiReply, products);

      // Thêm tin nhắn AI vào danh sách
      final aiMessage = model.ChatMessage(
        content: aiReply,
        type: model.MessageType.staff,
        timestamp: DateTime.now(),
      );

      updatedMessages.add(aiMessage);

      updateState(
        state.copyWith(
          messages: ViewState.loaded(updatedMessages),
          isSending: false,
          mentionedProducts: mentioned,
        ),
      );
    } catch (e) {
      handleError(e, source: 'ChatViewModel.sendMessageToAI');

      final errorMessage = model.ChatMessage(
        content: 'Lỗi khi gọi AI: ${e.toString()}',
        type: model.MessageType.system,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...messages, errorMessage];

      updateState(
        state.copyWith(
          messages: ViewState.loaded(updatedMessages),
          isSending: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<String> _callGeminiAPIWithMessages(
    List<Map<String, dynamic>> messages,
  ) async {
    const apiKey = 'AIzaSyBDX1bPxSJl5U3riYSjS9JCs1pyfb3B4AE';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({"contents": messages});
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

  List<Map<String, dynamic>> _extractMentionedProducts(
    String aiReply,
    List<Map<String, dynamic>> products,
  ) {
    final mentioned = <Map<String, dynamic>>[];
    for (final p in products) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty && aiReply.toLowerCase().contains(name)) {
        mentioned.add(p);
      }
    }
    return mentioned;
  }

  /// Giải phóng tài nguyên
  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}
