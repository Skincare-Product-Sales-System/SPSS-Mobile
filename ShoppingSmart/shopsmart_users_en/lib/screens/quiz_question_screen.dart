import 'package:flutter/material.dart';
import 'enhanced_quiz_question_screen.dart';

class QuizQuestionScreen extends StatelessWidget {
  final String quizSetId;
  final String quizSetName;

  const QuizQuestionScreen({
    super.key,
    required this.quizSetId,
    required this.quizSetName,
  });

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return EnhancedQuizQuestionScreen(
      quizSetId: quizSetId,
      quizSetName: quizSetName,
    );
  }
}
