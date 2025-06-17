import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_question_screen.dart';

class QuizScreen extends StatelessWidget {
  static const routeName = '/quiz';
  const QuizScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchQuizSets() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5041/api/quiz-sets?pageNumber=1&pageSize=10'),
    );
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
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Bài kiểm tra'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizSets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quiz sets found.'));
          }
          final quizSets = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: quizSets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final quiz = quizSets[index];
              // Thử cả jpg và png
              final imageJpg = 'assets/images/quiz_${index + 1}.jpg';
              final imagePng = 'assets/images/quiz_${index + 1}.png';
              return Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.97),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: _QuizImageChooser(
                          imageJpg: imageJpg,
                          imagePng: imagePng,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => QuizQuestionScreen(
                                            quizSetId: quiz['id'],
                                            quizSetName: quiz['name'] ?? '',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Làm bài kiểm tra',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Thêm widget chọn ảnh jpg/png
class _QuizImageChooser extends StatelessWidget {
  final String imageJpg;
  final String imagePng;
  const _QuizImageChooser({required this.imageJpg, required this.imagePng});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _assetExists(context, imageJpg),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return Image.asset(
            imageJpg,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
        return FutureBuilder(
          future: _assetExists(context, imagePng),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done &&
                snap.data == true) {
              return Image.asset(
                imagePng,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            }
            return Container(
              height: 160,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 60)),
            );
          },
        );
      },
    );
  }

  // Kiểm tra asset có tồn tại không
  Future<bool> _assetExists(BuildContext context, String assetPath) async {
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}

// Hướng dẫn thêm ảnh:
// 1. Đặt ảnh vào thư mục assets/images/ (ví dụ: quiz_1.jpg, quiz_2.jpg)
// 2. Khai báo đường dẫn assets trong pubspec.yaml:
//    assets:
//      - assets/images/quiz_1.jpg
//      - assets/images/quiz_2.jpg
// 3. Đặt tên ảnh đúng thứ tự hoặc sửa lại imageName trong code cho phù hợp quizset
