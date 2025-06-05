import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum MessageType { user, staff, system }

class ChatMessage {
  final String content;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.type,
    required this.timestamp,
  });

  // Convert message to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create message from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType messageType;
    if (json['type'] == 'user') {
      messageType = MessageType.user;
    } else if (json['type'] == 'staff') {
      messageType = MessageType.staff;
    } else {
      messageType = MessageType.system;
    }

    return ChatMessage(
      content: json['content'],
      type: messageType,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatService {
  HubConnection? _connection;
  bool isConnected = false;
  String? userId;
  final String hubUrl = 'http://10.0.2.2:5041/chathub';

  // Callback for message received
  Function(ChatMessage message)? onMessageReceived;

  // Initialize the service
  Future<void> initialize() async {
    await _setupUserId();
  }

  // Setup user ID from preferences or create new one
  Future<void> _setupUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('chatUserId');

    if (userId == null) {
      userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('chatUserId', userId!);
    }
  }

  // Connect to SignalR hub
  Future<bool> connect() async {
    if (userId == null) {
      await _setupUserId();
    }

    // Nếu đã kết nối, không cần kết nối lại
    if (isConnected && _connection != null) {
      return true;
    }

    try {
      // Đóng kết nối cũ nếu có
      if (_connection != null) {
        await _connection!.stop();
      }

      _connection =
          HubConnectionBuilder()
              .withUrl(hubUrl)
              .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 30000])
              .build();

      // Handle received messages
      _connection!.on('ReceiveMessage', _handleReceivedMessage);

      // Handle reconnecting
      _connection!.onreconnecting(({error}) {
        print('Reconnecting to SignalR hub... Error: $error');
        isConnected = false;
      });

      // Handle reconnected
      _connection!.onreconnected(({connectionId}) {
        print('Reconnected to SignalR hub with ID: $connectionId');
        isConnected = true;
        // Re-register user after reconnection
        if (userId != null) {
          _connection!
              .invoke('RegisterUser', args: <Object>[userId!])
              .catchError(
                (e) => print('Error registering user after reconnection: $e'),
              );
        }
      });

      // Handle closed connection
      _connection!.onclose(({error}) {
        print('SignalR connection closed. Error: $error');
        isConnected = false;
      });

      await _connection!.start();
      isConnected = true;

      // Register user with server
      if (userId != null) {
        await _connection!.invoke('RegisterUser', args: <Object>[userId!]);
      }

      return true;
    } catch (e) {
      print('Error connecting to SignalR: $e');
      isConnected = false;
      return false;
    }
  }

  // Handle messages from server
  void _handleReceivedMessage(List<Object?>? parameters) {
    if (parameters != null && parameters.length >= 2) {
      final message = parameters[0]?.toString() ?? '';
      final userType = parameters[1]?.toString() ?? 'staff';

      final messageType =
          userType == 'user' ? MessageType.user : MessageType.staff;

      final chatMessage = ChatMessage(
        content: message,
        type: messageType,
        timestamp: DateTime.now(),
      );

      // Save message to local storage
      _saveMessageToStorage(chatMessage);

      // Notify listeners
      if (onMessageReceived != null) {
        onMessageReceived!(chatMessage);
      }
    }
  }

  // Send message to server
  Future<bool> sendMessage(String message) async {
    if (_connection == null || userId == null) {
      return false;
    }

    try {
      // Thử kết nối lại nếu không ở trạng thái kết nối
      if (!isConnected) {
        await connect();
      }

      if (!isConnected) {
        throw Exception('Could not establish connection');
      }

      await _connection!.invoke(
        'SendMessage',
        args: <Object>[userId!, message, 'user'],
      );

      // Create message object
      final chatMessage = ChatMessage(
        content: message,
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // Save to local storage
      _saveMessageToStorage(chatMessage);

      return true;
    } catch (e) {
      print('Error sending message: $e');
      isConnected = false;
      return false;
    }
  }

  // Save message to local storage
  Future<void> _saveMessageToStorage(ChatMessage message) async {
    if (userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = 'chat_$userId';

      List<String> messages = prefs.getStringList(storageKey) ?? [];
      messages.add(jsonEncode(message.toJson()));

      await prefs.setStringList(storageKey, messages);
    } catch (e) {
      print('Error saving message to storage: $e');
    }
  }

  // Load chat history from storage
  Future<List<ChatMessage>> loadChatHistory() async {
    if (userId == null) return [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = 'chat_$userId';

      final messages = prefs.getStringList(storageKey) ?? [];

      return messages.map((msg) {
        final Map<String, dynamic> json = jsonDecode(msg);
        return ChatMessage.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  // Disconnect from SignalR hub
  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      isConnected = false;
    }
  }
}
