import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enhanced_auth_view_model.dart';
import '../../providers/enhanced_quiz_view_model.dart';
import '../../providers/enhanced_skin_analysis_view_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/skin_analysis_widgets.dart';
import '../auth/enhanced_login.dart';

class EnhancedSkinAnalysisHubScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-hub';
  const EnhancedSkinAnalysisHubScreen({super.key});

  @override
  State<EnhancedSkinAnalysisHubScreen> createState() =>
      _EnhancedSkinAnalysisHubScreenState();
}

class _EnhancedSkinAnalysisHubScreenState
    extends State<EnhancedSkinAnalysisHubScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isCheckingAuth = true;

  @override
  bool get wantKeepAlive => true; // Keep the state alive when switching tabs
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to tab controller to detect tab changes
    _tabController.addListener(_handleTabChange);

    // Kiểm tra đăng nhập và chuyển hướng sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkLoginStatus();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Tab is changing, load data for the new tab if needed
      if (_tabController.index == 0) {
        // Load skin analysis data if needed
      } else if (_tabController.index == 1) {
        // Load quiz data if needed
        final quizViewModel = Provider.of<EnhancedQuizViewModel>(
          context,
          listen: false,
        );
        if (quizViewModel.quizSets.isEmpty && !quizViewModel.isLoading) {
          quizViewModel.loadQuizSets();
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Kiểm tra trạng thái đăng nhập
    final authViewModel = Provider.of<EnhancedAuthViewModel>(context);
    final theme = Theme.of(context);

    // Nếu đang kiểm tra đăng nhập, hiển thị màn hình loading
    if (_isCheckingAuth) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phân Tích Da'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu chưa đăng nhập, hiển thị màn hình loading trong khi chuyển hướng
    if (!authViewModel.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phân Tích Da'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân Tích Da'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.face), text: 'Phân tích da'),
            Tab(icon: Icon(Icons.quiz), text: 'Trắc nghiệm da'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const ClampingScrollPhysics(), // Prevent swipe between tabs if needed
        children: [
          // Tab 1: Phân tích da
          _buildSkinAnalysisTab(),

          // Tab 2: Trắc nghiệm da
          _buildQuizTab(),
        ],
      ),
    );
  }

  Widget _buildSkinAnalysisTab() {
    return ChangeNotifierProvider(
      create: (_) => sl<EnhancedSkinAnalysisViewModel>(),
      child: const _SkinAnalysisTab(),
    );
  }

  Widget _buildQuizTab() {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = sl<EnhancedQuizViewModel>();
        // Make sure to load quiz sets when the view model is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadQuizSets();
        });
        return viewModel;
      },
      child: const _QuizTab(),
    );
  }
}

class _SkinAnalysisTab extends StatefulWidget {
  const _SkinAnalysisTab();

  @override
  State<_SkinAnalysisTab> createState() => _SkinAnalysisTabState();
}

class _SkinAnalysisTabState extends State<_SkinAnalysisTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Giới thiệu trực quan với nút hành động chính
          _buildHeroSection(context),

          const SizedBox(height: 30),

          // Tiêu đề cho phần dịch vụ
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Các dịch vụ phân tích da',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(
            height: 10,
          ), // Giải thích tính năng bằng feature items để tương đồng với giao diện Intro cũ
          SkinAnalysisFeatureItem(
            icon: Icons.face,
            title: 'Đánh giá da',
            description: 'Xác định loại da và các vấn đề về da mặt của bạn',
          ),

          SkinAnalysisFeatureItem(
            icon: Icons.shopping_bag,
            title: 'Gợi ý sản phẩm',
            description: 'Đề xuất các sản phẩm phù hợp với làn da của bạn',
          ),

          SkinAnalysisFeatureItem(
            icon: Icons.tips_and_updates,
            title: 'Lời khuyên chăm sóc da',
            description: 'Nhận lời khuyên cá nhân hóa để cải thiện làn da',
          ),

          const SizedBox(height: 30),

          // Thêm các feature cards bên dưới
          Text(
            'Dịch vụ phân tích da',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          SkinAnalysisFeatureCard(
            title: 'Phân tích toàn diện',
            description: 'Phân tích đầy đủ tình trạng da của bạn',
            icon: Icons.face_retouching_natural,
            onTap: () {
              // Đi thẳng đến màn hình thanh toán
              Navigator.of(
                context,
              ).pushNamed('/enhanced-skin-analysis-payment');
            },
          ),

          const SizedBox(height: 16),

          SkinAnalysisFeatureCard(
            title: 'Lịch sử phân tích',
            description: 'Xem các kết quả phân tích da trước đây',
            icon: Icons.history,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed('/enhanced-skin-analysis-history');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return SkinAnalysisHeroSection(
      iconData: Icons.face_retouching_natural,
      title: 'Phân Tích Da Thông Minh',
      description:
          'Tính năng phân tích da sẽ cho phép bạn chụp hình hoặc tải ảnh lên để tiến hành quét và phân tích da của bạn.',
      buttonText: 'Tiến hành phân tích da',
      onButtonPressed: () {
        // Đi thẳng đến màn hình thanh toán thay vì qua màn hình intro
        Navigator.of(context).pushNamed('/enhanced-skin-analysis-payment');
      },
    );
  }
}

class _QuizTab extends StatefulWidget {
  const _QuizTab();

  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load quiz sets if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EnhancedQuizViewModel>(
        context,
        listen: false,
      );
      if (viewModel.quizSets.isEmpty && !viewModel.isLoading) {
        viewModel.loadQuizSets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Reuse EnhancedQuizScreen's content without the authentication check
    final viewModel = Provider.of<EnhancedQuizViewModel>(context);
    final primaryColor = Theme.of(context).primaryColor;

    // Load quiz sets if not already loaded
    if (!viewModel.isLoading && viewModel.quizSets.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadQuizSets();
      });
    }

    if (viewModel.isLoading && viewModel.quizSets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.isLoading && viewModel.quizSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy bài trắc nghiệm nào',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadQuizSets(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${viewModel.errorMessage}',
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
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Thêm phần giới thiệu để thống nhất với UI Phân tích da
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Trắc Nghiệm Da',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Làm bài trắc nghiệm để hiểu rõ hơn về làn da của bạn và nhận được các gợi ý chăm sóc phù hợp',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tiêu đề cho phần danh sách bài kiểm tra
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Text(
              'Danh sách bài trắc nghiệm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Danh sách bài trắc nghiệm
          RefreshIndicator(
            onRefresh: () => viewModel.loadQuizSets(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                                      '/enhanced-quiz-question',
                                      arguments: {
                                        'quizSetId': quiz['id'],
                                        'quizSetName': quiz['name'] ?? '',
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Làm bài trắc nghiệm',
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
          ),
        ],
      ),
    );
  }
}

// Thêm widget chọn ảnh jpg/png - lấy từ EnhancedQuizScreen
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
