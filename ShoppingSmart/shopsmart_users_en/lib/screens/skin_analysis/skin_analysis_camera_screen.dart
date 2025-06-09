import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_result_screen.dart';
import 'package:shopsmart_users_en/services/api_service.dart';
import 'package:shopsmart_users_en/widgets/loading_widget.dart';

class SkinAnalysisCameraScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-camera';
  const SkinAnalysisCameraScreen({super.key});

  @override
  State<SkinAnalysisCameraScreen> createState() =>
      _SkinAnalysisCameraScreenState();
}

class _SkinAnalysisCameraScreenState extends State<SkinAnalysisCameraScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedImage == null) return;

      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  Future<void> _analyzeSkin() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh trước khi phân tích')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.analyzeSkin(_selectedImage!);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        if (result.success && result.data != null) {
          Navigator.of(context).pushNamed(
            SkinAnalysisResultScreen.routeName,
            arguments: result.data,
          );
        } else {
          _showErrorDialog(
            'Không thể phân tích da',
            result.message.isNotEmpty
                ? result.message
                : 'Vui lòng chụp ảnh rõ nét hơn hoặc chọn ảnh khác có khuôn mặt rõ ràng.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _showErrorDialog(
          'Lỗi khi phân tích da',
          'Không thể phân tích ảnh. Vui lòng chụp ảnh rõ nét hơn hoặc chọn ảnh khác có khuôn mặt rõ ràng.',
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 16),
                const Text(
                  'Gợi ý:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTipItem(
                  'Đảm bảo khuôn mặt rõ ràng và đầy đủ trong khung hình',
                ),
                _buildTipItem('Tránh ánh sáng quá mạnh hoặc quá tối'),
                _buildTipItem('Không đeo kính hoặc đồ che mặt'),
                _buildTipItem('Sử dụng ảnh chụp trực diện khuôn mặt'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
                child: const Text('Chụp ảnh mới'),
              ),
            ],
          ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chụp Ảnh Khuôn Mặt'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const LoadingWidget(message: 'Đang tải...')
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Image preview or placeholder
                      Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child:
                            _selectedImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.face,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Chụp ảnh khuôn mặt hoặc chọn ảnh từ thư viện',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 30),
                      // Camera and gallery buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.camera_alt,
                            label: 'Chụp ảnh',
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.photo_library,
                            label: 'Thư viện',
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Analyze button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _selectedImage == null || _isAnalyzing
                                  ? null
                                  : _analyzeSkin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ),
                          child:
                              _isAnalyzing
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Đang phân tích...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Text(
                                    'Phân tích da',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedImage != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Text('Xóa ảnh'),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
