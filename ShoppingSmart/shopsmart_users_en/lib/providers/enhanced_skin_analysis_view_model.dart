import 'dart:io';
import 'package:flutter/material.dart';
import '../models/skin_analysis_models.dart';
import '../models/transaction_model.dart';
import '../models/view_state.dart';
import '../repositories/skin_analysis_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/error_handling_service.dart';
import 'base_view_model.dart';
import 'skin_analysis_state.dart';

/// ViewModel cải tiến cho SkinAnalysis, kế thừa từ BaseViewModel
class EnhancedSkinAnalysisViewModel extends BaseViewModel<SkinAnalysisState> {
  // Repositories
  final SkinAnalysisRepository _skinAnalysisRepository;
  final TransactionRepository _transactionRepository;

  // Constructor với dependency injection
  EnhancedSkinAnalysisViewModel({
    SkinAnalysisRepository? skinAnalysisRepository,
    TransactionRepository? transactionRepository,
  }) : _skinAnalysisRepository =
           skinAnalysisRepository ?? SkinAnalysisRepository(),
       _transactionRepository =
           transactionRepository ?? TransactionRepository(),
       super(const SkinAnalysisState()) {
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
    // Kiểm tra nếu đã ở trạng thái approved thì không cập nhật nữa
    if (state.status == AnalysisStatus.paymentApproved &&
        transaction.status.toLowerCase() == 'approved') {
      print('Đã ở trạng thái approved, bỏ qua cập nhật');

      // Ngắt kết nối SignalR ngay lập tức để tránh cập nhật liên tục
      disconnectSignalR();
      return;
    }

    // Cập nhật state
    updateStateWithoutNotify(state.copyWith(currentTransaction: transaction));

    // Xử lý theo trạng thái giao dịch
    if (transaction.status.toLowerCase() == 'approved') {
      // Chỉ thông báo một lần khi chuyển sang trạng thái approved
      updateState(state.copyWith(status: AnalysisStatus.paymentApproved));

      // Ngắt kết nối SignalR sau khi đã approved để tránh cập nhật liên tục
      disconnectSignalR();
    } else if (transaction.status.toLowerCase() == 'pending') {
      updateState(
        state.copyWith(status: AnalysisStatus.waitingForPaymentApproval),
      );
    } else if (transaction.status.toLowerCase() == 'rejected') {
      updateState(
        state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Yêu cầu thanh toán bị từ chối',
        ),
      );
    }
  }

  // Xử lý khi có lỗi từ transaction service
  void _handleTransactionError(String error) {
    updateState(
      state.copyWith(status: AnalysisStatus.error, errorMessage: error),
    );
  }

  // Kết nối tới SignalR
  Future<bool> connectToSignalR() async {
    updateState(state.copyWith(isConnectingToSignalR: true));
    final result = await _transactionRepository.connect();
    updateState(state.copyWith(isConnectingToSignalR: false));
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
    updateState(state.resetTransactionCheck());
  }

  // Đặt ảnh đã chọn
  void setSelectedImage(File? image, {bool notify = true}) {
    // Giữ nguyên trạng thái hiện tại, chỉ cập nhật selectedImage
    // Điều này đảm bảo không làm thay đổi các trạng thái khác như paymentApproved
    final currentStatus = state.status;
    final currentResult = state.analysisResult;

    final newState = state.copyWith(
      selectedImage: image,
      // Giữ nguyên status hiện tại để không kích hoạt điều hướng không mong muốn
      status: currentStatus,
      // Giữ nguyên kết quả phân tích nếu có
      analysisResult: currentResult,
    );

    if (notify) {
      updateState(newState);
    } else {
      // Cập nhật state mà không thông báo để tránh rebuild
      updateStateWithoutNotify(newState);
    }
  }

  // Reset ảnh đã chọn
  void resetSelectedImage() {
    updateState(state.copyWith(selectedImage: null));
  }

  // Xóa ảnh nhưng giữ lại kết quả phân tích
  void clearImageButKeepResult() {
    // Lưu trữ kết quả phân tích và trạng thái hiện tại
    final currentResult = state.analysisResult;
    final currentStatus = state.status;

    // Cập nhật state với ảnh đã xóa nhưng giữ nguyên kết quả và trạng thái
    updateState(
      state.copyWith(
        selectedImage: null,
        status: currentStatus,
        analysisResult: currentResult,
      ),
    );
  }

  // Phân tích da từ ảnh đã chọn
  Future<bool> analyzeSkin() async {
    if (state.selectedImage == null) {
      updateState(
        state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Vui lòng chọn ảnh để phân tích',
        ),
      );
      return false;
    }

    updateState(
      state.copyWith(
        status: AnalysisStatus.analyzing,
        errorMessage: null,
        analysisResult: ViewState.loading(),
      ),
    );

    try {
      final result = await _skinAnalysisRepository.analyzeSkin(
        state.selectedImage!,
      );

      if (result.success && result.data != null) {
        updateState(
          state.copyWith(
            status: AnalysisStatus.analyzed,
            analysisResult: ViewState.loaded(result.data),
          ),
        );
        return true;
      } else {
        updateState(
          state.copyWith(
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
      handleError(e, source: 'analyzeSkin');
      updateState(
        state.copyWith(
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
    if (state.selectedImage == null) {
      updateState(
        state.copyWith(
          status: AnalysisStatus.error,
          errorMessage: 'Vui lòng chọn ảnh để phân tích',
        ),
      );
      return false;
    }

    updateState(
      state.copyWith(
        status: AnalysisStatus.analyzing,
        errorMessage: null,
        analysisResult: ViewState.loading(),
      ),
    );

    try {
      final result = await _skinAnalysisRepository.analyzeSkinWithPayment(
        state.selectedImage!,
      );

      if (result.success && result.data != null) {
        updateState(
          state.copyWith(
            status: AnalysisStatus.analyzed,
            analysisResult: ViewState.loaded(result.data),
            // Không xóa ảnh ở đây, để xử lý ở màn hình camera
          ),
        );
        return true;
      } else {
        updateState(
          state.copyWith(
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
      handleError(e, source: 'analyzeSkinWithPayment');
      updateState(
        state.copyWith(
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
    if (state.analysisHistory.isLoading ||
        state.analysisHistory.isLoadingMore) {
      return;
    }

    final currentData =
        refresh ? <SkinAnalysisResult>[] : state.analysisHistory.data ?? [];
    final currentPage = refresh ? 1 : (currentData.length ~/ 10) + 1;

    updateState(
      state.copyWith(
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

        updateState(
          state.copyWith(
            analysisHistory:
                result.data!.isEmpty && currentData.isEmpty
                    ? ViewState.empty("Không có lịch sử phân tích da")
                    : ViewState.loaded(newData),
          ),
        );
      } else {
        updateState(
          state.copyWith(
            analysisHistory: ViewState.error(
              result.message ?? 'Không thể lấy lịch sử phân tích da',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadAnalysisHistory');
      updateState(
        state.copyWith(
          analysisHistory: ViewState.error(
            'Lỗi khi lấy lịch sử phân tích da: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Lấy chi tiết phân tích da theo ID
  Future<void> loadAnalysisById(String id) async {
    updateState(state.copyWith(analysisResult: ViewState.loading()));

    try {
      final result = await _skinAnalysisRepository.getSkinAnalysisById(id);

      if (result.success && result.data != null) {
        updateState(
          state.copyWith(analysisResult: ViewState.loaded(result.data)),
        );
      } else {
        updateState(
          state.copyWith(
            analysisResult: ViewState.error(
              result.message ?? 'Không thể lấy chi tiết phân tích da',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadAnalysisById');
      updateState(
        state.copyWith(
          analysisResult: ViewState.error(
            'Lỗi khi lấy chi tiết phân tích da: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Đặt lại trạng thái sau khi hoàn thành phân tích da
  void resetAfterAnalysis() {
    updateState(state.resetAfterAnalysis());
  }

  // Phương thức mới để reset hoàn toàn trạng thái cho màn hình camera
  void resetForCameraScreen() {
    // Ngắt kết nối SignalR trước
    disconnectSignalR();

    // Tạo một state mới với trạng thái ban đầu nhưng giữ nguyên trạng thái thanh toán
    final newState = SkinAnalysisState(
      status:
          state.status == AnalysisStatus.paymentApproved
              ? AnalysisStatus.paymentApproved
              : AnalysisStatus.initial,
      selectedImage: null,
      currentTransaction: state.currentTransaction,
    );

    // Cập nhật state mà không thông báo để tránh rebuild
    updateStateWithoutNotify(newState);

    // In log để debug
    print(
      'Đã reset trạng thái cho màn hình camera. Status: ${newState.status}',
    );
  }

  @override
  void dispose() {
    disconnectSignalR();
    super.dispose();
  }

  @override
  void handleError(
    dynamic error, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    debugPrint(
      'Error in SkinAnalysisViewModel (${source ?? 'unknown'}): $error',
    );
    // Gọi phương thức của lớp cha để sử dụng xử lý lỗi tập trung
    super.handleError(error, source: source, severity: severity);
  }
}
