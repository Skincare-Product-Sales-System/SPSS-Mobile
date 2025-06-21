import '../models/view_state.dart';
import '../models/chat_message.dart' as model;

/// Lớp quản lý state cho chat
class ChatState {
  /// Trạng thái danh sách tin nhắn với ViewState để kiểm soát quá trình loading
  final ViewState<List<model.ChatMessage>> messages;

  /// Chỉ báo đang gửi tin nhắn
  final bool isSending;

  /// Chỉ báo chat đang mở
  final bool isOpen;

  /// Chỉ báo đã kết nối với server
  final bool isConnected;

  /// Chỉ báo có tin nhắn chưa đọc
  final bool hasUnreadMessages;

  /// Số lần thử kết nối
  final int connectionAttempts;

  /// Tin nhắn mới đang soạn thảo
  final String newMessage;

  /// URL hình ảnh đang xem trước
  final String? previewImageUrl;

  /// Thông báo lỗi khi thực hiện các thao tác trên chat
  final String? errorMessage;

  /// Danh sách sản phẩm được nhắc đến trong tin nhắn AI
  final List<Map<String, dynamic>>? mentionedProducts;

  /// Chỉ báo đang khởi tạo chat AI
  final bool isInitializingAI;

  /// Constructor với giá trị mặc định
  const ChatState({
    this.messages = const ViewState<List<model.ChatMessage>>(),
    this.isSending = false,
    this.isOpen = false,
    this.isConnected = false,
    this.hasUnreadMessages = false,
    this.connectionAttempts = 0,
    this.newMessage = '',
    this.previewImageUrl,
    this.errorMessage,
    this.mentionedProducts,
    this.isInitializingAI = false,
  });

  /// Phương thức tạo state mới với một số thuộc tính được thay đổi
  ChatState copyWith({
    ViewState<List<model.ChatMessage>>? messages,
    bool? isSending,
    bool? isOpen,
    bool? isConnected,
    bool? hasUnreadMessages,
    int? connectionAttempts,
    String? newMessage,
    String? previewImageUrl,
    String? errorMessage,
    List<Map<String, dynamic>>? mentionedProducts,
    bool? isInitializingAI,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isOpen: isOpen ?? this.isOpen,
      isConnected: isConnected ?? this.isConnected,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      connectionAttempts: connectionAttempts ?? this.connectionAttempts,
      newMessage: newMessage ?? this.newMessage,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      mentionedProducts: mentionedProducts ?? this.mentionedProducts,
      isInitializingAI: isInitializingAI ?? this.isInitializingAI,
    );
  }

  /// Phương thức xóa thông báo lỗi
  ChatState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Phương thức xóa hình ảnh xem trước
  ChatState clearPreviewImage() {
    return copyWith(previewImageUrl: null);
  }
}
