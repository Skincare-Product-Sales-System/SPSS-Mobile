import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_provider.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_detail.dart';

class SkinAnalysisResultScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-result';
  final SkinAnalysisResult result;

  const SkinAnalysisResultScreen({super.key, required this.result});

  @override
  State<SkinAnalysisResultScreen> createState() =>
      _SkinAnalysisResultScreenState();
}

class _SkinAnalysisResultScreenState extends State<SkinAnalysisResultScreen> {
  @override
  void initState() {
    super.initState();
    // Ngắt kết nối SignalR và đặt lại trạng thái khi màn hình kết quả được hiển thị
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SkinAnalysisProvider>(
        context,
        listen: false,
      );
      // Ngắt kết nối SignalR
      provider.disconnectSignalR();
      // Đặt lại biến kiểm tra giao dịch
      provider.resetTransactionCheck();
      // Đặt lại trạng thái để lần sau người dùng có thể tạo giao dịch mới
      provider.resetAfterAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sắp xếp các bước skincare routine theo thứ tự
    final sortedRoutineSteps = [...widget.result.routineSteps]
      ..sort((a, b) => a.order.compareTo(b.order));

    return WillPopScope(
      onWillPop: () async {
        // Prevent users from going back to prevent abuse of multiple analyses
        // Show dialog explaining why they can't go back
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Không thể quay lại'),
                content: const Text(
                  'Bạn không thể quay lại trang trước khi đã có kết quả phân tích. '
                  'Vui lòng sử dụng nút Home hoặc Back trên thanh điều hướng để trở về trang chủ.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đã hiểu'),
                  ),
                ],
              ),
        );

        // Return false to prevent back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kết Quả Phân Tích Da'),
          centerTitle: true,
          // Disable the back button in the AppBar
          automaticallyImplyLeading: false,
        ),
        // Add a home button to allow navigation to home
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Reset state and navigate to home
            final provider = Provider.of<SkinAnalysisProvider>(
              context,
              listen: false,
            );
            provider.resetAfterAnalysis();

            // Navigate to home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          tooltip: 'Về trang chủ',
          child: const Icon(Icons.home),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User image
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.result.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red[300],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Skin type
                _buildSectionTitle(context, 'Loại Da'),
                _buildInfoCard(
                  context,
                  child: Row(
                    children: [
                      Icon(
                        Icons.face,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.result.skinCondition.skinType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Điểm sức khỏe da: ${_normalizeScore(widget.result.skinCondition.healthScore).toStringAsFixed(1)}/10',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Skin condition scores
                _buildSectionTitle(context, 'Chỉ Số Da'),
                _buildInfoCard(
                  context,
                  child: Column(
                    children: [
                      _buildScoreItem(
                        context,
                        'Mụn',
                        widget.result.skinCondition.acneScore,
                        Colors.orange,
                      ),
                      const Divider(),
                      _buildScoreItem(
                        context,
                        'Nếp nhăn',
                        widget.result.skinCondition.wrinkleScore,
                        Colors.purple,
                      ),
                      const Divider(),
                      _buildScoreItem(
                        context,
                        'Quầng thâm',
                        widget.result.skinCondition.darkCircleScore,
                        Colors.blue,
                      ),
                      const Divider(),
                      _buildScoreItem(
                        context,
                        'Đốm nâu/tàn nhang',
                        widget.result.skinCondition.darkSpotScore,
                        Colors.brown,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Skin issues
                if (widget.result.skinIssues.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Vấn Đề Da'),
                  ...widget.result.skinIssues.map(
                    (issue) => _buildIssueCard(context, issue),
                  ),
                  const SizedBox(height: 24),
                ],

                // Skincare Routine - PHẦN MỚI THÊM VÀO
                if (widget.result.routineSteps.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Quy Trình Chăm Sóc Da'),
                  ...sortedRoutineSteps.map(
                    (step) => _buildRoutineStepCard(context, step),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recommended products
                _buildSectionTitle(context, 'Sản Phẩm Đề Xuất'),
                ...widget.result.recommendedProducts.map(
                  (product) => _buildProductCard(context, product),
                ),
                const SizedBox(height: 24),

                // Skin care advice
                _buildSectionTitle(context, 'Lời Khuyên Chăm Sóc Da'),
                _buildInfoCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        widget.result.skinCareAdvice.map((advice) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(advice)),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // THÊM WIDGET MỚI CHO ROUTINE STEP
  Widget _buildRoutineStepCard(BuildContext context, RoutineStep step) {
    // Hàm để đảm bảo tên bước bắt đầu bằng "Bước x."
    String ensureStepPrefix(String title, int order) {
      // Kiểm tra xem tên bước đã có "Bước x." chưa
      RegExp regex = RegExp(r'^Bước\s+\d+\.\s*');
      if (regex.hasMatch(title)) {
        return title; // Nếu đã có rồi thì giữ nguyên
      } else {
        // Nếu chưa có thì thêm vào
        return 'Bước ${order + 1}. $title';
      }
    }

    return _buildInfoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bỏ phần Row có chứa vòng tròn số thứ tự
          Text(
            ensureStepPrefix(step.stepName, step.order),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(step.instruction, style: const TextStyle(fontSize: 14)),
          if (step.products.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Sản phẩm gợi ý:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...step.products.map(
              (product) => _buildRoutineProductItem(context, product),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineProductItem(
    BuildContext context,
    RecommendedProduct product,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            ProductDetailsScreen.routeName,
            arguments: product.productId,
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 20),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_formatPrice(product.price)}₫',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    double score,
    Color color,
  ) {
    // Normalize score to be between 0 and 10
    double normalizedScore = _normalizeScore(score);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: normalizedScore / 10,
                          backgroundColor: Colors.grey[200],
                          color: color,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${normalizedScore.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(normalizedScore),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreDescription(double score) {
    if (score < 3) return 'Tốt';
    if (score < 6) return 'Trung bình';
    if (score < 8) return 'Cần cải thiện';
    return 'Nghiêm trọng';
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildIssueCard(BuildContext context, SkinIssue issue) {
    return _buildInfoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.issueName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Mức độ: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.circle,
                            size: 10,
                            color:
                                index < issue.severity
                                    ? Colors.red
                                    : Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(issue.description),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, RecommendedProduct product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProductDetailsScreen.routeName,
          arguments: product.productId,
        );
      },
      child: _buildInfoCard(
        context,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatPrice(product.price)}₫',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lý do đề xuất: ${product.recommendationReason}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to normalize scores
  double _normalizeScore(double score) {
    double normalizedScore = score;
    if (score > 10) {
      normalizedScore = score / 10;
      // If still greater than 10, divide again
      if (normalizedScore > 10) {
        normalizedScore = normalizedScore / 10;
      }
    }
    return normalizedScore.clamp(0.0, 10.0);
  }
}
