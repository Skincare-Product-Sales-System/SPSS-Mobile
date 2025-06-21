import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models_extended.dart';
import 'package:shopsmart_users_en/models/view_state.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_analysis_view_model.dart';

import 'package:shopsmart_users_en/widgets/loading_widget.dart';

class EnhancedSkinAnalysisHistoryScreen extends StatefulWidget {
  static const routeName = '/enhanced-skin-analysis-history';
  const EnhancedSkinAnalysisHistoryScreen({super.key});

  @override
  State<EnhancedSkinAnalysisHistoryScreen> createState() =>
      _EnhancedSkinAnalysisHistoryScreenState();
}

class _EnhancedSkinAnalysisHistoryScreenState
    extends State<EnhancedSkinAnalysisHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistories();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _fetchHistories() async {
    final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
      context,
      listen: false,
    );
    await viewModel.loadAnalysisHistory(refresh: true);
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
      context,
      listen: false,
    );

    await viewModel.loadAnalysisHistory();

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Phân Tích Da'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistories,
          ),
        ],
      ),
      body: Consumer<EnhancedSkinAnalysisViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;
          final analysisHistory = state.analysisHistory;

          if (analysisHistory.isLoading && !analysisHistory.isLoadingMore) {
            return const LoadingWidget(message: 'Đang tải lịch sử...');
          } else if (analysisHistory.isError) {
            return _buildErrorView(
              context,
              analysisHistory.error ?? 'Đã xảy ra lỗi',
            );
          } else if (analysisHistory.isEmpty) {
            return _buildEmptyView(context);
          } else if (analysisHistory.isLoaded ||
              analysisHistory.isLoadingMore) {
            final historyItems = analysisHistory.data ?? [];

            return RefreshIndicator(
              onRefresh: _fetchHistories,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount:
                    historyItems.length +
                    (analysisHistory.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == historyItems.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final historyItem = historyItems[index];
                  return _buildHistoryItem(historyItem);
                },
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchHistories,
        tooltip: 'Làm mới',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHistoryItem(SkinAnalysisResult history) {
    // Sử dụng createdTime từ history nếu có, nếu không thì dùng DateTime.now()
    String date =
        history.createdTime != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(history.createdTime!)
            : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Get skin type text
    String skinTypeText = history.skinCondition.skinType;

    // Calculate health score
    double healthScore = history.skinCondition.healthScore;
    // Normalize health score if needed
    if (healthScore > 10) {
      healthScore = healthScore / 10;
      if (healthScore > 10) {
        healthScore = healthScore / 10;
      }
    }
    healthScore = healthScore.clamp(0.0, 10.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _viewAnalysisDetail(history);
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
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
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
                        Row(
                          children: [
                            Icon(
                              Icons.face,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Loại da: $skinTypeText',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              size: 16,
                              color: _getHealthScoreColor(healthScore),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Điểm sức khỏe da: ${healthScore.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getHealthScoreColor(healthScore),
                                fontWeight: FontWeight.w500,
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
                  onPressed: () => _viewAnalysisDetail(history),
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

  void _viewAnalysisDetail(SkinAnalysisResult result) {
    // Navigate to the history detail screen which shows exactly the same content as result screen
    Navigator.of(context).pushNamed(
      '/enhanced-skin-analysis-history-detail',
      arguments: {'analysisId': result.id},
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage,
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

  Widget _buildEmptyView(BuildContext context) {
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

  Color _getHealthScoreColor(double score) {
    if (score >= 7.5) return Colors.green;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
