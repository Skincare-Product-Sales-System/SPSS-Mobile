import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/enhanced_auth_view_model.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_analysis_view_model.dart';
import 'package:shopsmart_users_en/screens/auth/enhanced_login.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/payment/enhanced_payment_screen.dart';

class EnhancedSkinAnalysisIntroScreen extends StatefulWidget {
  static const routeName = '/enhanced-skin-analysis-intro';
  const EnhancedSkinAnalysisIntroScreen({super.key});

  @override
  State<EnhancedSkinAnalysisIntroScreen> createState() =>
      _EnhancedSkinAnalysisIntroScreenState();
}

class _EnhancedSkinAnalysisIntroScreenState
    extends State<EnhancedSkinAnalysisIntroScreen> {
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

    // Sử dụng Consumer để lắng nghe các thay đổi từ ViewModel
    return Consumer<EnhancedSkinAnalysisViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Phân Tích Da'), centerTitle: true),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Skin analysis icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyBold.scan,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Title
                  Text(
                    'Phân Tích Da Thông Minh',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text(
                    'Tính năng phân tích da sẽ cho phép bạn chụp hình hoặc tải ảnh lên để tiến hành quét và phân tích da của bạn.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Features list
                  _buildFeatureItem(
                    context,
                    icon: Icons.face,
                    title: 'Đánh giá da',
                    description:
                        'Xác định loại da và các vấn đề về da mặt của bạn',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.shopping_bag,
                    title: 'Gợi ý sản phẩm',
                    description:
                        'Đề xuất các sản phẩm phù hợp với làn da của bạn',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.tips_and_updates,
                    title: 'Lời khuyên chăm sóc da',
                    description:
                        'Nhận lời khuyên cá nhân hóa để cải thiện làn da',
                  ),
                  const SizedBox(height: 40),
                  // Scan button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Sử dụng route mới cho màn hình payment theo MVVM
                        Navigator.of(
                          context,
                        ).pushNamed(EnhancedPaymentScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tiến hành phân tích da',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
