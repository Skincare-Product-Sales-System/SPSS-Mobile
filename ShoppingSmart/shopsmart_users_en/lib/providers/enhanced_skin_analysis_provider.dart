import 'dart:io';
import 'package:flutter/material.dart';
import '../models/skin_analysis_models.dart';
import '../models/transaction_model.dart';
import '../models/view_state.dart';
import '../repositories/skin_analysis_repository.dart';
import '../repositories/transaction_repository.dart';
import 'skin_analysis_state.dart';

class EnhancedSkinAnalysisProvider with ChangeNotifier {
  // Repositories
  final SkinAnalysisRepository _skinAnalysisRepository;
  final TransactionRepository _transactionRepository;

  // State
  SkinAnalysisState _state = const SkinAnalysisState();

  // Getters
  SkinAnalysisState get state => _state;

  // Constructor với dependency injection
  EnhancedSkinAnalysisProvider({
    SkinAnalysisRepository? skinAnalysisRepository,
    TransactionRepository? transactionRepository,
  }) : _skinAnalysisRepository =
           skinAnalysisRepository ?? SkinAnalysisRepository(),
       _transactionRepository =
           transactionRepository ?? TransactionRepository() {
    _setupTransactionCallbacks();
  }

  // Thiết lập callbacks cho TransactionRepository
  void _setupTransactionCallbacks() {
    _transactionRepository.setTransactionUpdatedCallback(
      _handleTransactionUpdated,
    );
    _transactionRepository.setErrorCallback(_handleTransactionError);
  }

  // Xử lý khi giao dịch được cập nhật
  void _handleTransactionUpdated(TransactionDto transaction) {
    // Cập nhật state
    _updateState(_state.copyWith(currentTransaction: transaction));

    // Xử lý theo trạng thái giao dịch
    if (transaction.status.toLowerCase() == 'approved') {
      _updateState(_state.copyWith(status: AnalysisStatus.paymentApproved));
    } else if (transaction.status.toLowerCase() == 'pending') {
      _updateState(
        _state.copyWith(status: AnalysisStatus.waitingForPaymentApproval),
      );
    } else if (transaction.status.toLowerCase() == 'rejected') {
      _updateState(
        _state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Yêu cầu thanh toán bị từ chối',
        ),
      );
    }
  }

  // Xử lý khi có lỗi từ transaction service
  void _handleTransactionError(String error) {
    _updateState(
      _state.copyWith(status: AnalysisStatus.error, errorMessage: error),
    );
  }

  // Kết nối tới SignalR
  Future<bool> connectToSignalR() async {
    _updateState(_state.copyWith(isConnectingToSignalR: true));
    final result = await _transactionRepository.connect();
    _updateState(_state.copyWith(isConnectingToSignalR: false));
    return result;
  }

  // Ngắt kết nối SignalR
  Future<void> disconnectSignalR() async {
    await _transactionRepository.disconnect();
  }

  // Đăng ký theo dõi giao dịch
  Future<bool> registerTransactionWatch(
    String transactionId,
    String userId,
  ) async {
    return await _transactionRepository.registerTransactionWatch(
      transactionId,
      userId,
    );
  }

  // Đặt lại việc kiểm tra giao dịch
  void resetTransactionCheck() {
    _updateState(_state.resetTransactionCheck());
  }

  // Đặt ảnh đã chọn
  void setSelectedImage(File? image) {
    _updateState(_state.copyWith(selectedImage: image));
  }

  // Phân tích da từ ảnh đã chọn
  Future<bool> analyzeSkin() async {
    if (_state.selectedImage == null) {
      _updateState(
        _state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Vui lòng chọn ảnh để phân tích',
        ),
      );
      return false;
    }

    _updateState(
      _state.copyWith(
        status: AnalysisStatus.analyzing,
        errorMessage: null,
        analysisResult: ViewState.loading(),
      ),
    );

    try {
      final result = await _skinAnalysisRepository.analyzeSkin(
        _state.selectedImage!,
      );

      if (result.success && result.data != null) {
        _updateState(
          _state.copyWith(
            status: AnalysisStatus.analyzed,
            analysisResult: ViewState.loaded(result.data),
          ),
        );
        return true;
      } else {
        _updateState(
          _state.copyWith(
            status: AnalysisStatus.error,
            errorMessage: result.message ?? 'Không thể phân tích da',
            analysisResult: ViewState.error(
              result.message ?? 'Không thể phân tích da',
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Lỗi phân tích da: ${e.toString()}',
          analysisResult: ViewState.error('Lỗi phân tích da: ${e.toString()}'),
        ),
      );
      return false;
    }
  }

  // Phân tích da từ ảnh đã chọn sau khi thanh toán được duyệt
  Future<bool> analyzeSkinWithPayment() async {
    if (_state.selectedImage == null) {
      _updateState(
        _state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Vui lòng chọn ảnh để phân tích',
        ),
      );
      return false;
    }

    _updateState(
      _state.copyWith(
        status: AnalysisStatus.analyzing,
        errorMessage: null,
        analysisResult: ViewState.loading(),
      ),
    );

    try {
      final result = await _skinAnalysisRepository.analyzeSkinWithPayment(
        _state.selectedImage!,
      );

      if (result.success && result.data != null) {
        _updateState(
          _state.copyWith(
            status: AnalysisStatus.analyzed,
            analysisResult: ViewState.loaded(result.data),
          ),
        );
        return true;
      } else {
        _updateState(
          _state.copyWith(
            status: AnalysisStatus.error,
            errorMessage: result.message ?? 'Không thể phân tích da',
            analysisResult: ViewState.error(
              result.message ?? 'Không thể phân tích da',
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Lỗi phân tích da: ${e.toString()}',
          analysisResult: ViewState.error('Lỗi phân tích da: ${e.toString()}'),
        ),
      );
      return false;
    }
  }

  // Lấy lịch sử phân tích da
  Future<void> loadAnalysisHistory({bool refresh = false}) async {
    if (_state.analysisHistory.isLoading ||
        _state.analysisHistory.isLoadingMore) {
      return;
    }

    final currentData =
        refresh ? <SkinAnalysisResult>[] : _state.analysisHistory.data ?? [];
    final currentPage = refresh ? 1 : (currentData.length ~/ 10) + 1;

    _updateState(
      _state.copyWith(
        analysisHistory:
            refresh ? ViewState.loading() : ViewState.loadingMore(currentData),
      ),
    );

    try {
      final result = await _skinAnalysisRepository.getSkinAnalysisHistory(
        pageNumber: currentPage,
        pageSize: 10,
      );

      if (result.success && result.data != null) {
        final newData = [...currentData, ...result.data!];

        _updateState(
          _state.copyWith(
            analysisHistory:
                result.data!.isEmpty && currentData.isEmpty
                    ? ViewState.empty("Không có lịch sử phân tích da")
                    : ViewState.loaded(newData),
          ),
        );
      } else {
        _updateState(
          _state.copyWith(
            analysisHistory: ViewState.error(
              result.message ?? 'Không thể lấy lịch sử phân tích da',
            ),
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          analysisHistory: ViewState.error(
            'Lỗi khi lấy lịch sử phân tích da: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Đặt lại trạng thái sau khi hoàn thành phân tích da
  void resetAfterAnalysis() {
    _updateState(_state.resetAfterAnalysis());
  }

  // Cập nhật state và thông báo sự thay đổi
  void _updateState(SkinAnalysisState newState) {
    _state = newState;
    notifyListeners();
  }
}
