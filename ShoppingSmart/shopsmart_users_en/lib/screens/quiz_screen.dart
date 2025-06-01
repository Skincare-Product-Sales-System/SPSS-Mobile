import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_question_screen.dart';

class QuizScreen extends StatelessWidget {
  static const routeName = '/quiz';
  const QuizScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchQuizSets() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5041/api/quiz-sets?pageNumber=1&pageSize=10'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data']['items'] as List<dynamic>;
      return items.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quiz sets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizSets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có quizset nào.'));
          }
          final quizSets = snapshot.data!;
          return ListView.separated(
            itemCount: quizSets.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final quiz = quizSets[index];
              return ListTile(
                title: Text(quiz['name'] ?? ''),
                subtitle: Text('ID: \\${quiz['id']}'),
                leading: const Icon(Icons.quiz),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionScreen(
                        quizSetId: quiz['id'],
                        quizSetName: quiz['name'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 