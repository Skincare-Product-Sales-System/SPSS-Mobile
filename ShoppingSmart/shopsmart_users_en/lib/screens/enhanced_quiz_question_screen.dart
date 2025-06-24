import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_quiz_view_model.dart';
import '../providers/quiz_state.dart';
import '../services/service_locator.dart';
import '../widgets/products/quiz_product_card.dart';
import '../screens/mvvm_screen_template.dart';
import '../models/view_state.dart';

class EnhancedQuizQuestionScreen extends StatefulWidget {
  static const routeName = '/enhanced-quiz-question';
  final String quizSetId;
  final String quizSetName;

  const EnhancedQuizQuestionScreen({
    super.key,
    required this.quizSetId,
    required this.quizSetName,
  });

  @override
  State<EnhancedQuizQuestionScreen> createState() =>
      _EnhancedQuizQuestionScreenState();
}

class _EnhancedQuizQuestionScreenState
    extends State<EnhancedQuizQuestionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EnhancedQuizViewModel>(
      create: (_) => sl<EnhancedQuizViewModel>(),
      child: MvvmScreenTemplate<EnhancedQuizViewModel, QuizState>(
        title: widget.quizSetName,
        onInit: (viewModel) {
          viewModel.loadQuestionsAndOptions(widget.quizSetId);
        },
        isLoading:
            (viewModel) => viewModel.isLoading && viewModel.questions.isEmpty,
        getErrorMessage:
            (viewModel) => viewModel.hasError ? viewModel.errorMessage : null,
        buildAppBar:
            (context, viewModel) =>
                AppBar(title: Text(widget.quizSetName), elevation: 0),
        buildContent: (context, viewModel) {
          if (viewModel.isDone) {
            return _buildQuizResultView(context, viewModel);
          } else {
            return _buildQuizQuestionView(context, viewModel);
          }
        },
      ),
    );
  }

  Widget _buildQuizQuestionView(
    BuildContext context,
    EnhancedQuizViewModel viewModel,
  ) {
    final questions = viewModel.questions;
    final options =
        viewModel.currentQuestion < viewModel.options.length
            ? viewModel.options[viewModel.currentQuestion]
            : [];

    if (questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    final currentQuestion = viewModel.questions[viewModel.currentQuestion];
    final selectedOptionId =
        viewModel.selectedOptionIds.isNotEmpty &&
                viewModel.currentQuestion < viewModel.selectedOptionIds.length
            ? viewModel.selectedOptionIds[viewModel.currentQuestion]
            : null;

    // Get question value using either 'content' or 'value' field
    final questionText =
        currentQuestion['value'] ?? currentQuestion['content'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Text(
            'Câu hỏi ${viewModel.currentQuestion + 1}/${questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (viewModel.currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option['id'] == selectedOptionId;
                // Get option value using either 'content' or 'value' field
                final optionText = option['value'] ?? option['content'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      viewModel.selectOption(option['id']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.normal,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (viewModel.currentQuestion > 0)
                ElevatedButton(
                  onPressed: () {
                    viewModel.prevQuestion();
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Quay lại'),
                )
              else
                const SizedBox(width: 100),

              ElevatedButton(
                onPressed:
                    selectedOptionId != null
                        ? (viewModel.currentQuestion < questions.length - 1
                            ? () {
                              viewModel.nextQuestion();
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                            : () {
                              viewModel.finishQuiz();
                            })
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  viewModel.currentQuestion < questions.length - 1
                      ? 'Tiếp theo'
                      : 'Hoàn thành',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResultView(
    BuildContext context,
    EnhancedQuizViewModel viewModel,
  ) {
    // Nếu đang loading thì show loading
    if (viewModel.state.quizResult.status == ViewStateStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nếu có lỗi hoặc không có data thì mới báo lỗi
    if (viewModel.state.quizResult.hasError ||
        viewModel.quizResult == null ||
        viewModel.quizResult!.isEmpty) {
      return const Center(child: Text('Không lấy được kết quả.'));
    }

    final quizResult = viewModel.quizResult!;
    final skinName = quizResult['name'] ?? '';
    final skinDesc = quizResult['description'] ?? '';
    final routine = quizResult['routine'] as List<dynamic>? ?? [];
    routine.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  skinName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skinDesc,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quy Trình Chăm Sóc Da Được Đề Xuất',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (routine.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routine.length,
              itemBuilder: (context, index) {
                final step = routine[index];
                final products = step['products'] as List<dynamic>? ?? [];
                final stepName = step['stepName'] ?? step['name'] ?? '';
                final instruction =
                    step['instruction'] ?? step['description'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              '${step['order']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stepName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        instruction,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (products.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sản phẩm đề xuất:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 220,
                              child: Stack(
                                children: [
                                  ListView.separated(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: products.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (ctx, idx) {
                                      final p = products[idx];
                                      return QuizProductCard(product: p);
                                    },
                                  ),
                                  if (products.length > 2)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _scrollController.animateTo(
                                              _scrollController.offset - 200,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.ease,
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_back_ios,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (products.length > 2)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _scrollController.animateTo(
                                              _scrollController.offset + 200,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.ease,
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            )
          else
            const Center(
              child: Text(
                'Không có quy trình chăm sóc da được đề xuất',
                style: TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Quay về', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
