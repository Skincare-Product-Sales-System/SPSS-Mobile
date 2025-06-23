import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_auth_view_model.dart';
import '../providers/enhanced_quiz_view_model.dart';
import '../providers/quiz_state.dart';
import '../screens/auth/enhanced_login.dart';
import '../services/service_locator.dart';
import 'enhanced_quiz_question_screen.dart';
import 'mvvm_screen_template.dart';

class EnhancedQuizScreen extends StatefulWidget {
  static const routeName = '/enhanced-quiz';
  const EnhancedQuizScreen({super.key});

  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    // Kiểm tra đăng nhập và chuyển hướng sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isCheckingAuth = true;
    });

    final authViewModel = Provider.of<EnhancedAuthViewModel>(
      context,
      listen: false,
    );

    // Làm mới trạng thái đăng nhập từ token đã lưu
    await authViewModel.refreshLoginState();

    setState(() {
      _isCheckingAuth = false;
    });

    if (!authViewModel.isLoggedIn) {
      // Chuyển hướng trực tiếp đến màn hình đăng nhập
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed(EnhancedLoginScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái đăng nhập
    final authViewModel = Provider.of<EnhancedAuthViewModel>(context);

    // Nếu đang kiểm tra đăng nhập, hiển thị màn hình loading
    if (_isCheckingAuth) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bài kiểm tra'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu chưa đăng nhập, hiển thị màn hình loading trong khi chuyển hướng
    if (!authViewModel.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bài kiểm tra'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<EnhancedQuizViewModel>(
      create: (_) => sl<EnhancedQuizViewModel>(),
      child: MvvmScreenTemplate<EnhancedQuizViewModel, QuizState>(
        title: 'Bài kiểm tra',
        onInit: (viewModel) => viewModel.loadQuizSets(),
        isLoading:
            (viewModel) => viewModel.isLoading && viewModel.quizSets.isEmpty,
        isEmpty:
            (viewModel) => !viewModel.isLoading && viewModel.quizSets.isEmpty,
        getErrorMessage:
            (viewModel) => viewModel.hasError ? viewModel.errorMessage : null,
        buildAppBar:
            (context, viewModel) =>
                AppBar(title: const Text('Bài kiểm tra'), centerTitle: true),
        buildContent: (context, viewModel) {
          final primaryColor = Theme.of(context).primaryColor;

          return RefreshIndicator(
            onRefresh: () => viewModel.loadQuizSets(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.quizSets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final quiz = viewModel.quizSets[index];
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
                                    Navigator.pushNamed(
                                      context,
                                      EnhancedQuizQuestionScreen.routeName,
                                      arguments: {
                                        'quizSetId': quiz['id'],
                                        'quizSetName': quiz['name'] ?? '',
                                      },
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
            ),
          );
        },
        buildEmpty:
            (context, viewModel) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy bài kiểm tra nào',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadQuizSets(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
        buildError:
            (context, viewModel, errorMessage) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: $errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadQuizSets(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
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
        } else {
          return FutureBuilder(
            future: _assetExists(context, imagePng),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return Image.asset(
                  imagePng,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Future<bool> _assetExists(BuildContext context, String assetPath) async {
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
