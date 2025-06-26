import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/payment/payment_screen.dart';

class SkinAnalysisIntroScreen extends StatelessWidget {
  static const routeName = '/skin-analysis-intro';
  const SkinAnalysisIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Phân Tích Da',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Skin analysis icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.scan,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Title
              Text(
                'Phân Tích Da Thông Minh',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF8F5CFF),
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
                description: 'Xác định loại da và các vấn đề về da mặt của bạn',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.shopping_bag,
                title: 'Gợi ý sản phẩm',
                description: 'Đề xuất các sản phẩm phù hợp với làn da của bạn',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.tips_and_updates,
                title: 'Lời khuyên chăm sóc da',
                description: 'Nhận lời khuyên cá nhân hóa để cải thiện làn da',
              ),
              const SizedBox(height: 40),
              // Scan button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(SkinAnalysisPaymentScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tiến hành phân tích da',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
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
                    color: Color(0xFF8F5CFF),
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
