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
            (context, viewModel) => PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 56),
                      child: Text(
                        widget.quizSetName.length > 32
                            ? widget.quizSetName.substring(0, 29) + '...'
                            : widget.quizSetName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8F5CFF)),
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
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
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFF8F5CFF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.12),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Text(
                        optionText,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
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
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.prevQuestion();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Quay lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                const SizedBox(width: 100),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: ElevatedButton(
                  onPressed: selectedOptionId != null
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
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    viewModel.currentQuestion < questions.length - 1 ? 'Tiếp theo' : 'Hoàn thành',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                // Icon trong vòng tròn gradient
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Tiêu đề loại da gradient
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    skinName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Sẽ bị che bởi gradient
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                // Mô tả loại da trong box nền trắng, border tím nhạt
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF8F5CFF).withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.06),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    skinDesc,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF222244),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Section title gradient
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: const Text(
              'Quy Trình Chăm Sóc Da Được Đề Xuất',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Sẽ bị che bởi gradient
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (routine.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routine.length,
              itemBuilder: (context, index) {
                final step = routine[index];
                final products = step['products'] as List<dynamic>? ?? [];
                final stepName = step['stepName'] ?? step['name'] ?? '';
                final instruction = step['instruction'] ?? step['description'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Số thứ tự trong avatar gradient
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(0),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                '${step['order']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              stepName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8F5CFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        instruction,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF222244),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (products.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Sản phẩm đề xuất:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Colors.white, // Sẽ bị che bởi gradient
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 220,
                              child: ListView.separated(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
                                itemBuilder: (ctx, idx) {
                                  final p = products[idx];
                                  return QuizProductCard(product: p);
                                },
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
          const SizedBox(height: 36),
          Center(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Quay về', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
