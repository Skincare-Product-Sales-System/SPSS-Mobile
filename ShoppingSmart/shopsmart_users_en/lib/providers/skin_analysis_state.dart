import 'dart:io';
import '../models/skin_analysis_models.dart';
import '../models/transaction_model.dart';
import '../models/view_state.dart';

enum AnalysisStatus {
  initial,
  creatingPayment,
  waitingForPaymentApproval,
  paymentApproved,
  analyzing,
  analyzed,
  error,
}

class SkinAnalysisState {
  final AnalysisStatus status;
  final String? errorMessage;
  final TransactionDto? currentTransaction;
  final File? selectedImage;
  final ViewState<SkinAnalysisResult?> analysisResult;
  final ViewState<List<SkinAnalysisResult>> analysisHistory;
  final bool hasCheckedTransaction;
  final bool isConnectingToSignalR;

  const SkinAnalysisState({
    this.status = AnalysisStatus.initial,
    this.errorMessage,
    this.currentTransaction,
    this.selectedImage,
    this.analysisResult = const ViewState<SkinAnalysisResult?>(),
    this.analysisHistory = const ViewState<List<SkinAnalysisResult>>(),
    this.hasCheckedTransaction = false,
    this.isConnectingToSignalR = false,
  });

  // Hàm tiện ích để kiểm tra xem có đang phân tích da không
  bool get isAnalyzing => status == AnalysisStatus.analyzing;

  // Kiểm tra xem người dùng đã thanh toán và được duyệt chưa
  bool get isPaymentApproved => status == AnalysisStatus.paymentApproved;

  // Clone state với các giá trị được cập nhật
  SkinAnalysisState copyWith({
    AnalysisStatus? status,
    String? errorMessage,
    TransactionDto? currentTransaction,
    File? selectedImage,
    ViewState<SkinAnalysisResult?>? analysisResult,
    ViewState<List<SkinAnalysisResult>>? analysisHistory,
    bool? hasCheckedTransaction,
    bool? isConnectingToSignalR,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      selectedImage: selectedImage ?? this.selectedImage,
      analysisResult: analysisResult ?? this.analysisResult,
      analysisHistory: analysisHistory ?? this.analysisHistory,
      hasCheckedTransaction:
          hasCheckedTransaction ?? this.hasCheckedTransaction,
      isConnectingToSignalR:
          isConnectingToSignalR ?? this.isConnectingToSignalR,
    );
  }

  // Xóa thông báo lỗi
  SkinAnalysisState clearError() {
    return copyWith(errorMessage: null);
  }

  // Đặt lại trạng thái sau khi phân tích da
  SkinAnalysisState resetAfterAnalysis() {
    return copyWith(
      status: AnalysisStatus.initial,
      errorMessage: null,
      currentTransaction: null,
      // Giữ lại kết quả phân tích để có thể xem lại nếu cần
      selectedImage: null,
    );
  }

  // Đặt lại việc kiểm tra giao dịch mà không thay đổi trạng thái
  SkinAnalysisState resetTransactionCheck() {
    return copyWith(hasCheckedTransaction: false);
  }
}
