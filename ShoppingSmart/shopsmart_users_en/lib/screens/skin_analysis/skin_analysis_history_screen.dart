import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_result_screen.dart';
import 'package:shopsmart_users_en/services/api_service.dart';
import 'package:shopsmart_users_en/widgets/loading_widget.dart';

class SkinAnalysisHistoryScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-history';

  const SkinAnalysisHistoryScreen({super.key});

  @override
  State<SkinAnalysisHistoryScreen> createState() =>
      _SkinAnalysisHistoryScreenState();
}

class _SkinAnalysisHistoryScreenState extends State<SkinAnalysisHistoryScreen> {
  bool _isLoading = true;
  List<SkinAnalysisResult> _histories = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistories();
  }

  Future<void> _fetchHistories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getSkinAnalysisHistory();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success && response.data != null) {
            _histories = response.data!;
          } else {
            _errorMessage =
                response.message ?? 'Không thể tải lịch sử phân tích da';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Phân Tích Da'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const LoadingWidget(message: 'Đang tải lịch sử...')
              : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _histories.isEmpty
              ? _buildEmptyView()
              : _buildHistoryListView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchHistories,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có lịch sử phân tích da',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy phân tích da để nhận được tư vấn về tình trạng da và gợi ý sản phẩm phù hợp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Quay lại màn hình trước
              },
              icon: const Icon(Icons.face),
              label: const Text('Phân tích da ngay'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryListView() {
    return RefreshIndicator(
      onRefresh: _fetchHistories,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(_histories[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(SkinAnalysisResult history) {
    // TODO: Thêm thời gian phân tích vào model SkinAnalysisResult khi API hỗ trợ
    String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Use pushReplacement to prevent going back
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SkinAnalysisResultScreen(result: history),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      history.imageUrl,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phân tích da - $date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loại da: ${history.skinCondition.skinType}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Điểm sức khỏe da: ${(history.skinCondition.healthScore / 10).toStringAsFixed(1)}/10',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (history.skinIssues.isNotEmpty) ...[
                const Text(
                  'Vấn đề da:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children:
                      history.skinIssues.map((issue) {
                        return Chip(
                          label: Text(issue.issueName),
                          backgroundColor: Colors.purple[50],
                          padding: const EdgeInsets.all(0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }).toList(),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    // Use pushReplacement to prevent going back
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                SkinAnalysisResultScreen(result: history),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Xem chi tiết'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
