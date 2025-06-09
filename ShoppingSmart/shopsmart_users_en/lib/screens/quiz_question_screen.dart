import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopsmart_users_en/widgets/products/quiz_product_card.dart';

class QuizQuestionScreen extends StatefulWidget {
  final String quizSetId;
  final String quizSetName;
  const QuizQuestionScreen({
    super.key,
    required this.quizSetId,
    required this.quizSetName,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  List<Map<String, dynamic>> questions = [];
  List<List<Map<String, dynamic>>> options = [];
  int currentQuestion = 0;
  List<String?> selectedOptionIds = [];
  bool isLoading = true;
  bool isDone = false;
  int totalScore = 0;
  bool isLoadingResult = false;
  Map<String, dynamic>? quizResultData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchQuestionsAndOptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchQuestionsAndOptions() async {
    final qRes = await http.get(
      Uri.parse(
        'http://10.0.2.2:5041/api/quiz-questions/by-quiz-set/${widget.quizSetId}',
      ),
    );
    if (qRes.statusCode == 200) {
      final qData = json.decode(qRes.body);
      final qList = qData['data'] as List<dynamic>;
      questions = qList.cast<Map<String, dynamic>>();
      options = [];
      for (final q in questions) {
        final oRes = await http.get(
          Uri.parse(
            'http://10.0.2.2:5041/api/quiz-options/by-quiz-question/${q['id']}',
          ),
        );
        if (oRes.statusCode == 200) {
          final oData = json.decode(oRes.body);
          final oList = oData['data'] as List<dynamic>;
          options.add(oList.cast<Map<String, dynamic>>());
        } else {
          options.add([]);
        }
      }
      selectedOptionIds = List.filled(questions.length, null);
    }
    setState(() {
      isLoading = false;
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  void prevQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  Future<void> fetchQuizResult() async {
    setState(() {
      isLoadingResult = true;
    });
    final url =
        'http://10.0.2.2:5041/api/quiz-results/by-point-and-set?score=$totalScore&quizSetId=${widget.quizSetId}';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      quizResultData = data['data'];
    }
    setState(() {
      isLoadingResult = false;
    });
  }

  void finishQuiz() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      final selectedId = selectedOptionIds[i];
      if (selectedId != null) {
        final opt = options[i].firstWhere(
          (o) => o['id'] == selectedId,
          orElse: () => {},
        );
        score += (opt['score'] ?? 0) as int;
      }
    }
    setState(() {
      totalScore = score;
      isDone = true;
    });
    fetchQuizResult();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (isDone) {
      if (isLoadingResult) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (quizResultData == null) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.quizSetName)),
          body: const Center(child: Text('Không lấy được kết quả.')),
        );
      }
      final skinName = quizResultData!['name'] ?? '';
      final skinDesc = quizResultData!['description'] ?? '';
      final routine = quizResultData!['routine'] as List<dynamic>? ?? [];
      routine.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
      return Scaffold(
        appBar: AppBar(title: const Text('Kết Quả Bài Kiểm Tra')),
        body: SingleChildScrollView(
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
              const SizedBox(height: 12),
              ...routine.map((step) => _buildRoutineStep(context, step)),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final q = questions[currentQuestion];
    final o = options[currentQuestion];
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizSetName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu hỏi ${currentQuestion + 1}/${questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(q['value'] ?? '', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ...o.map(
              (opt) => RadioListTile<String>(
                value: opt['id'],
                groupValue: selectedOptionIds[currentQuestion],
                title: Text(opt['value'] ?? ''),
                onChanged: (val) {
                  setState(() {
                    selectedOptionIds[currentQuestion] = val;
                  });
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestion > 0 ? prevQuestion : null,
                  child: const Text('Quay lại'),
                ),
                if (currentQuestion < questions.length - 1)
                  ElevatedButton(
                    onPressed:
                        selectedOptionIds[currentQuestion] != null
                            ? nextQuestion
                            : null,
                    child: const Text('Tiếp theo'),
                  ),
                if (currentQuestion == questions.length - 1)
                  ElevatedButton(
                    onPressed:
                        selectedOptionIds[currentQuestion] != null
                            ? finishQuiz
                            : null,
                    child: const Text('Hoàn thành'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStep(BuildContext context, dynamic step) {
    final stepName = step['stepName'] ?? '';
    final instruction = step['instruction'] ?? '';
    final products = step['products'] as List<dynamic>? ?? [];
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
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
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
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
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
  }
}
