import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  // Getters
  bool get isOpen => _isOpen;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String get newMessage => _newMessage;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get previewImageUrl => _previewImageUrl;

  // Initialize the provider
  Future<void> initialize() async {
    await _chatService.initialize();

    // Set up callback for received messages
    _chatService.onMessageReceived = _handleMessageReceived;
  }

  // Toggle chat window
  void toggleChat() async {
    _isOpen = !_isOpen;

    if (_isOpen && !_isConnected) {
      await _loadChatHistory();
      await _connectToChat();
    }

    notifyListeners();
  }

  // Connect to chat service
  Future<void> _connectToChat() async {
    _setLoading(true);

    // Add connecting message
    _addSystemMessage('Kết nối với nhân viên hỗ trợ của Skincede...');

    // Connect to SignalR hub
    final connected = await _chatService.connect();
    _isConnected = connected;

    if (connected) {
      _addSystemMessage(
        'Đã kết nối với hỗ trợ viên. Bạn có thể bắt đầu nhắn tin.',
      );
    } else {
      _addSystemMessage(
        'Không thể kết nối với hỗ trợ viên. Vui lòng thử lại sau.',
      );
      // Tự động thử lại sau 5 giây
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected && _isOpen) {
          _addSystemMessage('Kết nối với nhân viên hỗ trợ của Skincede...');
          _connectToChat();
        }
      });
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

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Handle message received from server
  void _handleMessageReceived(ChatMessage message) {
    _messages.add(message);
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

  // Disconnect from chat service
  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}
