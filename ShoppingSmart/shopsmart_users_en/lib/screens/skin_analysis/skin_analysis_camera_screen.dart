import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_provider.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/skin_analysis_result_screen.dart';
import 'package:shopsmart_users_en/services/api_service.dart';
import 'package:shopsmart_users_en/widgets/loading_widget.dart';
import 'package:flutter/rendering.dart';

// Thêm class mới để hiển thị tiến trình phân tích da
class AnalyzingProgressDialog extends StatefulWidget {
  const AnalyzingProgressDialog({super.key});

  @override
  State<AnalyzingProgressDialog> createState() =>
      _AnalyzingProgressDialogState();
}

class _AnalyzingProgressDialogState extends State<AnalyzingProgressDialog> {
  int _progressValue = 0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _progressValue < 100) {
        setState(() {
          _progressValue += 5; // Tăng 5% mỗi 100ms
        });
        _startProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Đang phân tích da',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progressValue / 100,
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).primaryColor,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              '$_progressValue%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getAnalyzingMessage(_progressValue),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getAnalyzingMessage(int progress) {
    if (progress < 30) {
      return 'Đang quét khuôn mặt...';
    } else if (progress < 60) {
      return 'Đang phân tích tình trạng da...';
    } else if (progress < 90) {
      return 'Đang tìm kiếm sản phẩm phù hợp...';
    } else {
      return 'Hoàn tất phân tích...';
    }
  }
}

class SkinAnalysisCameraScreen extends StatefulWidget {
  static const routeName = '/skin-analysis-camera';
  const SkinAnalysisCameraScreen({super.key});

  @override
  State<SkinAnalysisCameraScreen> createState() =>
      _SkinAnalysisCameraScreenState();
}

class _SkinAnalysisCameraScreenState extends State<SkinAnalysisCameraScreen>
    with AutomaticKeepAliveClientMixin {
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _hasCheckedPayment = false;
  bool _isProcessingImage = false; // Thêm biến để theo dõi quá trình xử lý ảnh
  bool _isInitialized =
      false; // Thêm biến để theo dõi việc đã khởi tạo màn hình

  // Đảm bảo màn hình không bị rebuild
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('initState: Khởi tạo màn hình camera');
    _isInitialized = false;

    // Chỉ chạy một lần duy nhất
    Future.microtask(() {
      if (!mounted || _isInitialized) return;
      _isInitialized = true;

      final provider = Provider.of<SkinAnalysisProvider>(
        context,
        listen: false,
      );
      print('Kiểm tra trạng thái thanh toán: ${provider.status}');

      if (provider.status != SkinAnalysisStatus.paymentApproved) {
        print('Người dùng chưa được duyệt thanh toán, quay lại màn hình trước');
        Navigator.of(context).pop();
        return;
      }

      print('Người dùng đã được duyệt thanh toán, có thể tiếp tục');
      // Ngắt kết nối SignalR hiện tại và tạo kết nối mới sau khi phân tích
      provider.disconnectSignalR();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Không làm gì trong didChangeDependencies để tránh rebuild
  }

  // Kiểm tra trạng thái thanh toán - không sử dụng phương thức này nữa
  void _checkPaymentStatus() {
    // Phương thức này không còn được sử dụng
    print('_checkPaymentStatus không còn được sử dụng');
  }

  Future<void> _pickImage(ImageSource source) async {
    // Nếu đang xử lý ảnh, không cho phép chọn ảnh mới
    if (_isProcessingImage) {
      print('Đang xử lý ảnh, không cho phép chọn ảnh mới');
      return;
    }

    try {
      setState(() {
        _isProcessingImage = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedImage == null) {
        setState(() {
          _isProcessingImage = false;
        });
        return;
      }

      final File imageFile = File(pickedImage.path);
      print('Đã chọn ảnh thành công: ${imageFile.path}');

      // Cập nhật ảnh trong state trước
      setState(() {
        _selectedImage = imageFile;
        _isProcessingImage = false;
        print('Đã cập nhật selectedImage trong state');
      });

      // Sau đó mới cập nhật ảnh trong provider mà không gọi lại build
      if (mounted) {
        final provider = Provider.of<SkinAnalysisProvider>(
          context,
          listen: false,
        );
        provider.setSelectedImage(imageFile, notify: false);
        print('Đã cập nhật ảnh trong provider sau khi build hoàn tất');
      }
    } catch (e) {
      setState(() {
        _isProcessingImage = false;
      });
      print('Lỗi khi chọn ảnh: ${e.toString()}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  Future<void> _analyzeSkin() async {
    final provider = Provider.of<SkinAnalysisProvider>(context, listen: false);

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AnalyzingProgressDialog(),
      );

      // Đảm bảo provider có ảnh đã chọn
      if (provider.selectedImage == null && _selectedImage != null) {
        provider.setSelectedImage(_selectedImage!, notify: false);
      }

      // Sử dụng provider để phân tích da với thanh toán
      // Không cần kết nối SignalR lại ở đây
      final bool success = await provider.analyzeSkin();

      if (mounted) {
        Navigator.of(context).pop(); // Đóng dialog tiến trình

        setState(() {
          _isAnalyzing = false;
        });

        if (success && provider.analysisResult != null) {
          // Sử dụng pushReplacement để thay thế màn hình hiện tại
          // thay vì thêm một màn hình mới vào stack
          Navigator.of(context).pushReplacementNamed(
            SkinAnalysisResultScreen.routeName,
            arguments: provider.analysisResult,
          );
        } else {
          // Hiển thị lỗi từ API
          final errorMessage =
              provider.errorMessage ?? 'Có lỗi xảy ra khi phân tích da';

          // Kiểm tra nếu là lỗi không phát hiện khuôn mặt
          if (errorMessage.contains('không phát hiện khuôn mặt') ||
              errorMessage.contains('không phát hi') ||
              errorMessage.contains('No face detected')) {
            _showErrorDialog(
              'Không phát hiện khuôn mặt',
              'Không phát hiện khuôn mặt trong ảnh. Vui lòng chọn ảnh rõ nét và đảm bảo khuôn mặt hiển thị đầy đủ.',
            );
          } else {
            // Hiển thị lỗi khác
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Roboto',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontFamily: 'Roboto')),
                const SizedBox(height: 16),
                const Text(
                  'Gợi ý:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                _buildTipItem(
                  'Đảm bảo khuôn mặt rõ ràng và đầy đủ trong khung hình',
                ),
                _buildTipItem('Tránh ánh sáng quá mạnh hoặc quá tối'),
                _buildTipItem('Không đeo kính hoặc đồ che mặt'),
                _buildTipItem('Sử dụng ảnh chụp trực diện khuôn mặt'),
                _buildTipItem('Đảm bảo khuôn mặt chiếm phần lớn khung hình'),
                _buildTipItem('Tránh góc chụp nghiêng hoặc quá xa'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Đóng',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
                child: const Text(
                  'Chụp ảnh mới',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
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
          const Text(
            '• ',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(fontFamily: 'Roboto')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cần thiết cho AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: () async {
        // Hiển thị dialog xác nhận khi người dùng nhấn nút back
        return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text(
                      'Bạn có muốn quay lại trang chủ không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pop(false), // Không quay lại
                        child: const Text('Không'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Quay về trang chủ
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Có'),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      child: Scaffold(
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
                          height: 450,
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
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Không thể tải ảnh',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                                          fontFamily: 'Roboto',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

  @override
  void deactivate() {
    // Reset lại provider khi màn hình không còn active
    print('deactivate: Màn hình camera không còn active');
    final provider = Provider.of<SkinAnalysisProvider>(context, listen: false);

    // Chỉ ngắt kết nối SignalR khi đã phân tích xong
    if (provider.status == SkinAnalysisStatus.analyzed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.disconnectSignalR();
        print('Đã ngắt kết nối SignalR sau khi phân tích xong');
      });
    } else {
      print('Không ngắt kết nối SignalR vì chưa phân tích xong');
    }

    // Không reset lại trạng thái thanh toán và kết quả phân tích
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose: Màn hình camera bị hủy');
    // Đảm bảo ngắt kết nối SignalR khi màn hình bị hủy và đã phân tích xong
    final provider = Provider.of<SkinAnalysisProvider>(context, listen: false);
    if (provider.status == SkinAnalysisStatus.analyzed) {
      provider.disconnectSignalR();
      print(
        'Đã ngắt kết nối SignalR khi màn hình bị hủy sau khi phân tích xong',
      );
    } else {
      print(
        'Không ngắt kết nối SignalR khi màn hình bị hủy vì chưa phân tích xong',
      );
    }
    super.dispose();
  }
}
