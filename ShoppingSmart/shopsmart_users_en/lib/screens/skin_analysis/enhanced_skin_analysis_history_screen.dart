import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models_extended.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Lịch Sử Phân Tích Da', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchHistories,
              ),
            ],
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
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
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _fetchHistories,
          tooltip: 'Làm mới',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3EDFF), Color(0xFFE9E1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _viewAnalysisDetail(history);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.13)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        history.imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phân tích da - $date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF8F5CFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.face, size: 16, color: Color(0xFF8F5CFF)),
                            const SizedBox(width: 4),
                            Text('Loại da: $skinTypeText', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.health_and_safety, size: 16, color: _getHealthScoreColor(healthScore)),
                            const SizedBox(width: 4),
                            Text(
                              'Điểm sức khỏe da: ${healthScore.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getHealthScoreColor(healthScore),
                                fontWeight: FontWeight.w600,
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
                  spacing: 10,
                  runSpacing: 8,
                  children: history.skinIssues.map((issue) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF8F5CFF).withOpacity(0.13)),
                      ),
                      child: Text(
                        issue.issueName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8F5CFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: TextButton.icon(
                    onPressed: () => _viewAnalysisDetail(history),
                    icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                    label: const Text('Xem chi tiết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
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
