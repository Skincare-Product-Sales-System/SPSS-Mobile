import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chat_message_content.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  bool _isOpen = false;
  bool _isConnected = false;
  bool _isLoading = false;
  bool _isUploading = false;
  String _newMessage = '';
  final List<ChatMessage> _messages = [];
  String? _previewImageUrl;
  bool _hasUnreadMessages = false;
  int _connectionAttempts = 0;
  static const int MAX_RETRY_ATTEMPTS = 3;

  // Getters
  bool get isOpen => _isOpen;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String get newMessage => _newMessage;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get previewImageUrl => _previewImageUrl;
  bool get hasUnreadMessages => _hasUnreadMessages;
  int get connectionAttempts => _connectionAttempts;

  ChatProvider() {
    _chatService.onMessageReceived = _handleMessageReceived;
    _chatService.initialize();
  }

  // Initialize the provider
  Future<void> initialize() async {
    await _chatService.initialize();

    // Set up callback for received messages
    _chatService.onMessageReceived = _handleMessageReceived;
  }

  // Toggle chat window
  void toggleChat() {
    _isOpen = !_isOpen;
    if (_isOpen && !_isConnected) {
      _connectToChat();
      _loadChatHistory();
    }
    notifyListeners();
  }

  // Khởi tạo chat khi vào màn hình chat riêng biệt
  Future<void> initChat() async {
    if (!_isConnected) {
      await _connectToChat();
      await _loadChatHistory();
    }
  }

  // Connect to chat service
  Future<void> _connectToChat() async {
    _setLoading(true);
    _connectionAttempts++;

    // Add connecting message
    _addSystemMessage('Kết nối với nhân viên hỗ trợ của Skincede...');

    // Connect to SignalR hub
    final connected = await _chatService.connect();
    _isConnected = connected;

    if (connected) {
      _connectionAttempts = 0;
      _addSystemMessage(
        'Đã kết nối với hỗ trợ viên. Bạn có thể bắt đầu nhắn tin.',
      );
    } else {
      if (_connectionAttempts < MAX_RETRY_ATTEMPTS) {
        _addSystemMessage(
          'Không thể kết nối với hỗ trợ viên. Đang thử lại lần $_connectionAttempts/$MAX_RETRY_ATTEMPTS...',
        );
        // Tự động thử lại sau 3 giây
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isConnected && _isOpen) {
            _connectToChat();
          }
        });
      } else {
        _addSystemMessage(
          'Không thể kết nối với hỗ trợ viên sau nhiều lần thử. Vui lòng kiểm tra kết nối mạng và thử lại sau.',
        );
        _connectionAttempts = 0;
      }
    }

    _setLoading(false);
  }

  // Load chat history
  Future<void> _loadChatHistory() async {
    _setLoading(true);

    // Clear messages except system ones
    final systemMessages =
        _messages.where((msg) => msg.type == MessageType.system).toList();
    _messages.clear();
    _messages.addAll(systemMessages);

    // Load messages from storage
    final chatHistory = await _chatService.loadChatHistory();

    // Add loaded messages
    _messages.addAll(chatHistory);

    _setLoading(false);
  }

  // Xóa lịch sử chat
  Future<void> clearChatHistory() async {
    _setLoading(true);

    // Xóa tin nhắn từ bộ nhớ
    await _chatService.clearChatHistory();

    // Xóa tin nhắn từ danh sách hiện tại, chỉ giữ lại tin nhắn hệ thống
    final systemMessages =
        _messages.where((msg) => msg.type == MessageType.system).toList();
    _messages.clear();
    _messages.addAll(systemMessages);

    _addSystemMessage('Lịch sử trò chuyện đã được xóa.');

    _setLoading(false);
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Handle message received from server
  void _handleMessageReceived(ChatMessage message) {
    _messages.add(message);

    // Nếu tin nhắn đến từ nhân viên và chat không mở, đánh dấu có tin mới
    if (message.type == MessageType.staff && !_isOpen) {
      _hasUnreadMessages = true;
    }

    notifyListeners();
  }

  // Add system message
  void _addSystemMessage(String content) {
    _messages.add(
      ChatMessage(
        content: content,
        type: MessageType.system,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Set new message text
  void setNewMessage(String message) {
    _newMessage = message;
    notifyListeners();
  }

  // Send text message
  Future<void> sendMessage() async {
    if (_newMessage.trim().isEmpty) return;

    final messageText = _newMessage.trim();
    _newMessage = '';
    notifyListeners();

    // Add message to list immediately for UI response
    _messages.add(
      ChatMessage(
        content: messageText,
        type: MessageType.user,
        timestamp: DateTime.now(),
      ),
    );

    // Try to reconnect if not connected
    if (!_isConnected) {
      _addSystemMessage('Đang thử kết nối lại...');
      final connected = await _chatService.connect();
      _isConnected = connected;

      if (connected) {
        _addSystemMessage('Đã kết nối lại. Tin nhắn của bạn sẽ được gửi.');
      } else {
        _addSystemMessage(
          'Không thể kết nối. Tin nhắn của bạn sẽ được gửi khi có kết nối.',
        );
        notifyListeners();
        return;
      }
    }

    // Send message to server
    try {
      await _chatService.sendMessage(messageText);
    } catch (e) {
      print('Error sending message: $e');
      _isConnected = false;
      _addSystemMessage('Không thể gửi tin nhắn. Vui lòng thử lại sau.');
    }

    notifyListeners();
  }

  // Upload and send image
  Future<void> uploadAndSendImage(XFile image) async {
    if (!_isConnected) return;

    _isUploading = true;
    notifyListeners();

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:5041/api/images'),
      );

      // Add file to request
      final file = await http.MultipartFile.fromPath('files', image.path);
      request.files.add(file);

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (data['success'] && data['data'] != null) {
        // Get image URL
        final imageUrl = data['data'][0];

        // Create image message
        final imageMessage = ImageMessage(url: imageUrl);
        final jsonMessage = jsonEncode(imageMessage.toJson());

        // Add message to list
        _messages.add(
          ChatMessage(
            content: jsonMessage,
            type: MessageType.user,
            timestamp: DateTime.now(),
          ),
        );

        // Send to server
        await _chatService.sendMessage(jsonMessage);
      }
    } catch (e) {
      print('Error uploading image: $e');
      _addSystemMessage('Không thể tải lên hình ảnh. Vui lòng thử lại sau.');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Pick image from gallery or camera
  Future<void> pickAndSendImage(ImageSource source) async {
    if (!_isConnected) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        await uploadAndSendImage(pickedFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      _addSystemMessage('Không thể chọn hình ảnh. Vui lòng thử lại sau.');
    }
  }

  // Set preview image
  void setPreviewImage(String? url) {
    _previewImageUrl = url;
    notifyListeners();
  }

  // Send product message
  Future<void> sendProductMessage({
    required String productId,
    required String productName,
    required String imageUrl,
    required double price,
    double rating = 4.5,
    int soldCount = 0,
  }) async {
    if (!_isConnected) {
      _addSystemMessage('Không thể gửi sản phẩm. Vui lòng kết nối lại.');
      return;
    }

    try {
      // Create product message
      final productMessage = {
        'type': 'product',
        'id': productId,
        'name': productName,
        'image': imageUrl,
        'price': price,
        'rating': rating,
        'soldCount': soldCount,
        'url': '', // Có thể thêm URL nếu cần
      };

      final jsonMessage = jsonEncode(productMessage);

      // Add message to list immediately for UI response
      _messages.add(
        ChatMessage(
          content: jsonMessage,
          type: MessageType.user,
          timestamp: DateTime.now(),
        ),
      );

      // Send to server
      await _chatService.sendMessage(jsonMessage);

      notifyListeners();
    } catch (e) {
      print('Error sending product message: $e');
      _addSystemMessage(
        'Không thể gửi thông tin sản phẩm. Vui lòng thử lại sau.',
      );
    }
  }

  // Đánh dấu đã đọc tin nhắn
  void markMessagesAsRead() {
    if (_hasUnreadMessages) {
      _hasUnreadMessages = false;
      notifyListeners();
    }
  }

  // Disconnect from chat service
  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}
