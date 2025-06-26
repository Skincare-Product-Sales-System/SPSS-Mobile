import '../models/view_state.dart';
import '../repositories/quiz_repository.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'quiz_state.dart';

/// ViewModel cải tiến cho Quiz, kế thừa từ BaseViewModel
class EnhancedQuizViewModel extends BaseViewModel<QuizState> {
  final QuizRepository _quizRepository;

  /// Constructor với dependency injection cho repository
  EnhancedQuizViewModel({QuizRepository? quizRepository})
    : _quizRepository = quizRepository ?? sl<QuizRepository>(),
      super(const QuizState());

  /// Getters tiện ích
  List<Map<String, dynamic>> get quizSets => state.quizSets.data ?? [];
  bool get isLoading =>
      state.quizSets.status == ViewStateStatus.loading ||
      state.quizQuestions.status == ViewStateStatus.loading ||
      state.quizResult.status == ViewStateStatus.loading;
  bool get hasError =>
      state.quizSets.hasError ||
      state.quizQuestions.hasError ||
      state.quizResult.hasError;
  String? get errorMessage =>
      state.quizSets.hasError
          ? state.quizSets.message
          : state.quizQuestions.hasError
          ? state.quizQuestions.message
          : state.quizResult.hasError
          ? state.quizResult.message
          : null;
  List<Map<String, dynamic>> get questions => state.quizQuestions.data ?? [];
  List<List<Map<String, dynamic>>> get options => state.quizOptions.data ?? [];
  int get currentQuestion => state.currentQuestion;
  List<String?> get selectedOptionIds => state.selectedOptionIds;
  bool get isDone => state.isDone;
  int get totalScore => state.totalScore;
  Map<String, dynamic>? get quizResult => state.quizResult.data;

  /// Lấy danh sách bộ câu hỏi quiz
  Future<void> loadQuizSets() async {
    updateState(state.copyWith(quizSets: ViewState.loading()));

    try {
      final response = await _quizRepository.getQuizSets();
      if (response.success && response.data != null) {
        updateState(state.copyWith(quizSets: ViewState.loaded(response.data!)));
      } else {
        updateState(
          state.copyWith(
            quizSets: ViewState.error(
              response.message ?? 'Failed to load quiz sets',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadQuizSets');
      updateState(
        state.copyWith(
          quizSets: ViewState.error(
            'An error occurred while loading quiz sets: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Load quiz questions and options for a specific quiz set
  Future<void> loadQuestionsAndOptions(String quizSetId) async {
    updateState(
      state.copyWith(
        quizQuestions: ViewState.loading(),
        quizOptions: const ViewState<List<List<Map<String, dynamic>>>>(),
        currentQuestion: 0,
        selectedOptionIds: [],
        totalScore: 0,
        isDone: false,
        quizSetId: quizSetId,
      ),
    );

    try {
      final qResponse = await _quizRepository.getQuizQuestions(quizSetId);
      if (qResponse.success && qResponse.data != null) {
        final questions = qResponse.data!;
        final List<List<Map<String, dynamic>>> allOptions = [];

        for (final question in questions) {
          final questionId = question['id'];
          final oResponse = await _quizRepository.getQuizOptionsByQuestion(
            questionId,
          );
          if (oResponse.success && oResponse.data != null) {
            // Ensure consistent field names for compatibility
            final options =
                oResponse.data!.map((option) {
                  // Make sure both 'content' and 'value' fields exist
                  if (option['value'] == null && option['content'] != null) {
                    option['value'] = option['content'];
                  }
                  if (option['content'] == null && option['value'] != null) {
                    option['content'] = option['value'];
                  }
                  return option;
                }).toList();

            allOptions.add(options);
          } else {
            allOptions.add([]);
          }
        }

        // Ensure consistent field names for compatibility
        final normalizedQuestions =
            questions.map((question) {
              // Make sure both 'content' and 'value' fields exist
              if (question['value'] == null && question['content'] != null) {
                question['value'] = question['content'];
              }
              if (question['content'] == null && question['value'] != null) {
                question['content'] = question['value'];
              }
              return question;
            }).toList();

        updateState(
          state.copyWith(
            quizQuestions: ViewState.loaded(normalizedQuestions),
            quizOptions: ViewState.loaded(allOptions),
            selectedOptionIds: List.filled(questions.length, null),
          ),
        );
      } else {
        updateState(
          state.copyWith(
            quizQuestions: ViewState.error(
              qResponse.message ?? 'Failed to load quiz questions',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadQuestionsAndOptions');
      updateState(
        state.copyWith(
          quizQuestions: ViewState.error(
            'An error occurred while loading quiz questions: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Select an option for the current question
  void selectOption(String optionId) {
    final updatedSelections = List<String?>.from(state.selectedOptionIds);
    updatedSelections[state.currentQuestion] = optionId;

    updateState(state.copyWith(selectedOptionIds: updatedSelections));
  }

  /// Move to the next question
  void nextQuestion() {
    if (state.currentQuestion < (state.quizQuestions.data?.length ?? 0) - 1) {
      updateState(state.copyWith(currentQuestion: state.currentQuestion + 1));
    }
  }

  /// Move to the previous question
  void prevQuestion() {
    if (state.currentQuestion > 0) {
      updateState(state.copyWith(currentQuestion: state.currentQuestion - 1));
    }
  }

  /// Calculate score and finish quiz
  void finishQuiz() {
    int score = 0;
    for (int i = 0; i < (state.quizQuestions.data?.length ?? 0); i++) {
      final selectedId = state.selectedOptionIds[i];
      if (selectedId != null && i < (state.quizOptions.data?.length ?? 0)) {
        final options = state.quizOptions.data![i];
        final option = options.firstWhere(
          (o) => o['id'] == selectedId,
          orElse: () => {},
        );
        score += (option['score'] ?? 0) as int;
      }
    }

    updateState(state.copyWith(totalScore: score, isDone: true));

    fetchQuizResult(score);
  }

  /// Fetch quiz result
  Future<void> fetchQuizResult(int score) async {
    updateState(state.copyWith(quizResult: ViewState.loading()));

    try {
      final response = await _quizRepository.getQuizResultByScore(
        score,
        state.quizSetId,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(quizResult: ViewState.loaded(response.data!)),
        );
      } else {
        updateState(
          state.copyWith(
            quizResult: ViewState.error(
              response.message ?? 'Failed to load quiz result',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'fetchQuizResult');
      updateState(
        state.copyWith(
          quizResult: ViewState.error(
            'An error occurred while loading quiz result: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Reset quiz state
  void resetQuiz() {
    updateState(
      state.copyWith(
        quizQuestions: const ViewState<List<Map<String, dynamic>>>(),
        quizOptions: const ViewState<List<List<Map<String, dynamic>>>>(),
        quizResult: const ViewState<Map<String, dynamic>>(),
        currentQuestion: 0,
        selectedOptionIds: [],
        totalScore: 0,
        isDone: false,
        quizSetId: '',
      ),
    );
  }
}
