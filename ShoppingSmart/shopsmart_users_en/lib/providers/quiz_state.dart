import '../models/view_state.dart';

/// State class for Quiz screen
class QuizState {
  /// Trạng thái danh sách bộ câu hỏi quiz
  final ViewState<List<Map<String, dynamic>>> quizSets;

  /// Trạng thái danh sách câu hỏi quiz
  final ViewState<List<Map<String, dynamic>>> quizQuestions;

  /// Trạng thái danh sách các tùy chọn quiz
  final ViewState<List<List<Map<String, dynamic>>>> quizOptions;

  /// Trạng thái kết quả quiz
  final ViewState<Map<String, dynamic>> quizResult;

  /// Câu hỏi hiện tại
  final int currentQuestion;

  /// Các tùy chọn đã chọn
  final List<String?> selectedOptionIds;

  /// Tổng điểm
  final int totalScore;

  /// Trạng thái hoàn thành quiz
  final bool isDone;

  /// ID của bộ câu hỏi hiện tại
  final String quizSetId;

  /// Constructor với giá trị mặc định
  const QuizState({
    this.quizSets = const ViewState<List<Map<String, dynamic>>>(),
    this.quizQuestions = const ViewState<List<Map<String, dynamic>>>(),
    this.quizOptions = const ViewState<List<List<Map<String, dynamic>>>>(),
    this.quizResult = const ViewState<Map<String, dynamic>>(),
    this.currentQuestion = 0,
    this.selectedOptionIds = const [],
    this.totalScore = 0,
    this.isDone = false,
    this.quizSetId = '',
  });

  /// Tạo một bản sao của state với một số thuộc tính được thay đổi
  QuizState copyWith({
    ViewState<List<Map<String, dynamic>>>? quizSets,
    ViewState<List<Map<String, dynamic>>>? quizQuestions,
    ViewState<List<List<Map<String, dynamic>>>>? quizOptions,
    ViewState<Map<String, dynamic>>? quizResult,
    int? currentQuestion,
    List<String?>? selectedOptionIds,
    int? totalScore,
    bool? isDone,
    String? quizSetId,
  }) {
    return QuizState(
      quizSets: quizSets ?? this.quizSets,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      quizOptions: quizOptions ?? this.quizOptions,
      quizResult: quizResult ?? this.quizResult,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      totalScore: totalScore ?? this.totalScore,
      isDone: isDone ?? this.isDone,
      quizSetId: quizSetId ?? this.quizSetId,
    );
  }
}
