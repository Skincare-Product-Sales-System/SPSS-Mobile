import 'dart:io';
import 'package:flutter/material.dart';
import '../models/skin_analysis_models.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../services/transaction_signalr_service.dart';
import '../repositories/skin_analysis_repository.dart';
import 'package:image_picker/image_picker.dart';

enum SkinAnalysisStatus {
  initial,
  creatingPayment,
  waitingForPaymentApproval,
  paymentApproved,
  analyzing,
  analyzed,
  error,
}

class SkinAnalysisProvider with ChangeNotifier {
  // Repository
  final SkinAnalysisRepository _repository = SkinAnalysisRepository();

  // Dịch vụ SignalR cho giao dịch
  final TransactionSignalRService _signalRService = TransactionSignalRService();

  // Trạng thái
  SkinAnalysisStatus _status = SkinAnalysisStatus.initial;
  String? _errorMessage;
  TransactionDto? _currentTransaction;
  File? _selectedImage;
  SkinAnalysisResult? _analysisResult;
  List<SkinAnalysisResult> _analysisHistory = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreHistory = true;
  bool _isHandlingTransaction = false; // Biến để theo dõi việc xử lý giao dịch
  String? _lastProcessedTransactionId; // ID của giao dịch cuối cùng được xử lý
  bool _isConnectingSignalR =
      false; // Biến để theo dõi việc đang kết nối SignalR
  bool _hasCheckedTransaction =
      false; // Biến để theo dõi việc đã kiểm tra giao dịch

  // Getters
  SkinAnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TransactionDto? get currentTransaction => _currentTransaction;
  File? get selectedImage => _selectedImage;
  SkinAnalysisResult? get analysisResult => _analysisResult;
  List<SkinAnalysisResult> get analysisHistory => _analysisHistory;
  bool get isLoading => _isLoading;
  bool get hasMoreHistory => _hasMoreHistory;

  // Kiểm tra xem người dùng có đang trong quá trình phân tích da không
  bool get isAnalyzing => _status == SkinAnalysisStatus.analyzing;

  // Kiểm tra xem người dùng đã thanh toán và được duyệt chưa
  bool get isPaymentApproved => _status == SkinAnalysisStatus.paymentApproved;

  // Khởi tạo provider và đăng ký các sự kiện SignalR
  SkinAnalysisProvider() {
    _setupSignalRCallbacks();
  }

  // Thiết lập các callback cho SignalR
  void _setupSignalRCallbacks() {
    _signalRService.onTransactionUpdated = _handleTransactionUpdated;
    _signalRService.onError = (error) {
      _errorMessage = error;
      _status = SkinAnalysisStatus.error;
      notifyListeners();
    };
  }

  // Xử lý khi giao dịch được cập nhật
  void _handleTransactionUpdated(TransactionDto transaction) {
    if (_isHandlingTransaction &&
        transaction.id == _lastProcessedTransactionId) {
      print('Bỏ qua thông báo trùng lặp cho giao dịch: ${transaction.id}');
      return; // Bỏ qua các thông báo trùng lặp
    }

    _isHandlingTransaction = true;
    _lastProcessedTransactionId = transaction.id;

    _currentTransaction = transaction;
    print(
      'Giao dịch cập nhật: ${transaction.id}, trạng thái: ${transaction.status}',
    );

    // Cập nhật trạng thái dựa trên trạng thái giao dịch
    if (transaction.status.toLowerCase() == 'approved') {
      print('Cập nhật trạng thái thành paymentApproved');
      _status = SkinAnalysisStatus.paymentApproved;
      _errorMessage = null;
    } else if (transaction.status.toLowerCase() == 'rejected') {
      print('Cập nhật trạng thái thành error (rejected)');
      _status = SkinAnalysisStatus.error;
      _errorMessage = 'Yêu cầu thanh toán bị từ chối';
    } else if (transaction.status.toLowerCase() == 'pending') {
      print('Cập nhật trạng thái thành waitingForPaymentApproval');
      _status = SkinAnalysisStatus.waitingForPaymentApproval;
      _errorMessage = null;
    }

    notifyListeners();

    // Đặt lại cờ xử lý sau khi hoàn thành
    Future.delayed(const Duration(milliseconds: 500), () {
      _isHandlingTransaction = false;
    });
  }

  // Kết nối đến dịch vụ SignalR
  Future<bool> connectToSignalR() async {
    if (_isConnectingSignalR) return false;
    _isConnectingSignalR = true;
    try {
      return await _signalRService.connect();
    } finally {
      _isConnectingSignalR = false;
    }
  }

  // Ngắt kết nối SignalR
  void disconnectSignalR() {
    print('Ngắt kết nối SignalR');
    _signalRService.disconnect();
  }

  // Đặt lại trạng thái về ban đầu
  void resetState() {
    _status = SkinAnalysisStatus.initial;
    _errorMessage = null;
    _currentTransaction = null;
    _selectedImage = null;
    _analysisResult = null;
    notifyListeners();
  }

  // Đặt lại biến kiểm tra giao dịch
  void resetTransactionCheck() {
    _hasCheckedTransaction = false;
    print('Đã đặt lại biến kiểm tra giao dịch');
  }

  // Đặt lại trạng thái sau khi hoàn thành phân tích da
  void resetAfterAnalysis() {
    _status = SkinAnalysisStatus.initial;
    _errorMessage = null;
    _currentTransaction = null;
    // Giữ lại kết quả phân tích để có thể xem lại nếu cần
    _selectedImage = null;
    print('Đã đặt lại trạng thái sau khi phân tích da');
    notifyListeners();
  }

  // Cập nhật trạng thái thành đã duyệt thanh toán
  void updateStatusToApproved() {
    _status = SkinAnalysisStatus.paymentApproved;
    notifyListeners();
  }

  // Kiểm tra giao dịch hiện tại và cập nhật trạng thái nếu cần
  void checkCurrentTransaction() {
    // Nếu đã kiểm tra rồi, không kiểm tra lại
    if (_hasCheckedTransaction) {
      print('Đã kiểm tra giao dịch trước đó, không kiểm tra lại');
      return;
    }

    _hasCheckedTransaction = true;
    print('Kiểm tra giao dịch hiện tại');

    if (_currentTransaction != null) {
      print(
        'Có giao dịch hiện tại: ID=${_currentTransaction!.id}, Status=${_currentTransaction!.status}',
      );
      if (_currentTransaction!.status.toLowerCase() == 'approved') {
        _status = SkinAnalysisStatus.paymentApproved;
        print('Cập nhật trạng thái thành paymentApproved');
      } else if (_currentTransaction!.status.toLowerCase() == 'pending') {
        _status = SkinAnalysisStatus.waitingForPaymentApproval;
        print('Cập nhật trạng thái thành waitingForPaymentApproval');
      } else if (_currentTransaction!.status.toLowerCase() == 'rejected') {
        _status = SkinAnalysisStatus.error;
        _errorMessage = 'Yêu cầu thanh toán bị từ chối';
        print('Cập nhật trạng thái thành error (rejected)');
      }
      notifyListeners();
    } else {
      print('Không có giao dịch hiện tại');
    }
  }

  // Tạo yêu cầu thanh toán phân tích da
  Future<void> createPaymentRequest() async {
    try {
      _status = SkinAnalysisStatus.creatingPayment;
      _errorMessage = null;
      notifyListeners();

      // Không kết nối SignalR ở đây vì đã kết nối trong màn hình payment

      final result = await ApiService.createSkinAnalysisPayment();

      if (result.success && result.data != null) {
        _currentTransaction = result.data;
        _status = SkinAnalysisStatus.waitingForPaymentApproval;

        // Đăng ký theo dõi giao dịch
        await _signalRService.registerTransactionWatch(
          _currentTransaction!.id,
          _currentTransaction!.userId,
        );

        notifyListeners();
      } else {
        _status = SkinAnalysisStatus.error;
        _errorMessage = result.message ?? 'Không thể tạo yêu cầu thanh toán';
        notifyListeners();
      }
    } catch (e) {
      _status = SkinAnalysisStatus.error;
      _errorMessage = 'Lỗi: ${e.toString()}';
      notifyListeners();
    }
  }

  // Chọn ảnh từ camera hoặc thư viện
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi chọn ảnh: ${e.toString()}';
      notifyListeners();
    }
  }

  // Đặt ảnh đã chọn
  void setSelectedImage(File? image, {bool notify = false}) {
    _selectedImage = image;
    // Không thay đổi trạng thái của provider khi chỉ đặt ảnh
    if (image != null) {
      print('Đã đặt ảnh đã chọn: ${image.path}');
    } else {
      print('Đã xóa ảnh đã chọn');
    }
    // Chỉ gọi notifyListeners() khi cần thiết
    if (notify) {
      notifyListeners();
    }
  }

  // Phân tích da từ ảnh đã chọn
  Future<bool> analyzeSkin() async {
    if (_selectedImage == null) {
      _errorMessage = 'Vui lòng chọn ảnh để phân tích';
      notifyListeners();
      return false;
    }

    try {
      _status = SkinAnalysisStatus.analyzing;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.analyzeSkin(_selectedImage!);

      if (result.success && result.data != null) {
        _status = SkinAnalysisStatus.analyzed;
        _analysisResult = result.data;
        notifyListeners();
        return true;
      } else {
        _status = SkinAnalysisStatus.error;
        _errorMessage = result.message ?? 'Không thể phân tích da';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = SkinAnalysisStatus.error;
      _errorMessage = 'Lỗi phân tích da: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Phân tích da từ ảnh đã chọn sau khi thanh toán được duyệt
  Future<bool> analyzeSkinWithPayment() async {
    if (_selectedImage == null) {
      _errorMessage = 'Vui lòng chọn ảnh để phân tích';
      notifyListeners();
      return false;
    }

    try {
      _status = SkinAnalysisStatus.analyzing;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.analyzeSkinWithPayment(_selectedImage!);

      if (result.success && result.data != null) {
        _status = SkinAnalysisStatus.analyzed;
        _analysisResult = result.data;
        notifyListeners();
        return true;
      } else {
        _status = SkinAnalysisStatus.error;
        _errorMessage = result.message ?? 'Không thể phân tích da';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = SkinAnalysisStatus.error;
      _errorMessage = 'Lỗi phân tích da: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Lấy lịch sử phân tích da
  Future<void> loadAnalysisHistory({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _analysisHistory = [];
      _hasMoreHistory = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getSkinAnalysisHistory(
        pageNumber: _currentPage,
        pageSize: 10,
      );

      if (result.success && result.data != null) {
        // Đã đảm bảo data không null từ repository và API service
        if (result.data!.isEmpty) {
          _hasMoreHistory = false;
        } else {
          _analysisHistory.addAll(result.data!);
          _currentPage++;
        }
      } else {
        _errorMessage = result.message ?? 'Không thể lấy lịch sử phân tích da';
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi lấy lịch sử phân tích da: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết phân tích da theo ID
  Future<void> loadAnalysisDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getSkinAnalysisById(id);

      if (result.success && result.data != null) {
        _analysisResult = result.data;
      } else {
        _errorMessage = result.message ?? 'Không thể lấy chi tiết phân tích da';
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi lấy chi tiết phân tích da: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _signalRService.disconnect();
    super.dispose();
  }
}
