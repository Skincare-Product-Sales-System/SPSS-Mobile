import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/enhanced_skin_analysis_view_model.dart';
import 'package:shopsmart_users_en/providers/skin_analysis_state.dart';
import 'package:shopsmart_users_en/screens/skin_analysis/enhanced_skin_analysis_result_screen.dart';

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

class EnhancedSkinAnalysisCameraScreen extends StatefulWidget {
  static const routeName = '/enhanced-skin-analysis-camera';
  const EnhancedSkinAnalysisCameraScreen({super.key});

  @override
  State<EnhancedSkinAnalysisCameraScreen> createState() =>
      _EnhancedSkinAnalysisCameraScreenState();
}

class _EnhancedSkinAnalysisCameraScreenState
    extends State<EnhancedSkinAnalysisCameraScreen>
    with AutomaticKeepAliveClientMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isProcessingImage = false;
  bool _isInitialized = false;
  static bool _hasBeenInitialized =
      false; // Static flag to track if this screen has been initialized before

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

      final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
        context,
        listen: false,
      );
      print('Kiểm tra trạng thái thanh toán: ${viewModel.state.status}');

      // Kiểm tra xem có phải đang ở màn hình camera sau khi thanh toán không
      if (viewModel.state.status != AnalysisStatus.paymentApproved &&
          viewModel.state.status != AnalysisStatus.analyzed &&
          viewModel.state.status != AnalysisStatus.initial) {
        print('Người dùng chưa được duyệt thanh toán, quay lại màn hình trước');
        Navigator.of(context).pop();
        return;
      }

      print('Người dùng đã được duyệt thanh toán, có thể tiếp tục');

      // Cập nhật _selectedImage từ viewModel nếu có
      if (viewModel.state.selectedImage != null) {
        setState(() {
          _selectedImage = viewModel.state.selectedImage;
        });
      }

      // Ngắt kết nối SignalR hiện tại để ngăn chặn việc rebuild liên tục
      viewModel.disconnectSignalR();
    });

    // Reset selectedImage trong viewModel khi màn hình được khởi tạo
    // Sử dụng addPostFrameCallback để đảm bảo chỉ chạy một lần sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
        context,
        listen: false,
      );
      // Chỉ reset image khi cần thiết, không thay đổi trạng thái khác
      viewModel.resetSelectedImage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Không làm gì trong didChangeDependencies để tránh rebuild
  }

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    EnhancedSkinAnalysisViewModel viewModel,
  ) async {
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
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessingImage = false;
        });
        return;
      }

      final File imageFile = File(pickedFile.path);
      print('Đã chọn ảnh thành công: ${imageFile.path}');

      // Cập nhật ảnh trong state trước
      setState(() {
        _selectedImage = imageFile;
        _isProcessingImage = false;
      });

      // Sau đó mới cập nhật ảnh trong viewModel
      if (mounted) {
        // Sử dụng setSelectedImage nhưng không kích hoạt notify để tránh rebuild
        viewModel.setSelectedImage(imageFile, notify: false);
        print('Đã cập nhật ảnh trong viewModel');
      }
    } catch (e) {
      setState(() {
        _isProcessingImage = false;
      });
      print('Lỗi khi chọn ảnh: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Future<void> _analyzeSkin(
    BuildContext context,
    EnhancedSkinAnalysisViewModel viewModel,
  ) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh trước khi phân tích')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _isProcessingImage = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AnalyzingProgressDialog(),
      );

      // Đảm bảo viewModel có ảnh đã chọn
      if (viewModel.state.selectedImage == null && _selectedImage != null) {
        viewModel.setSelectedImage(_selectedImage!, notify: false);
      }

      final result = await viewModel.analyzeSkinWithPayment();

      if (mounted) {
        Navigator.of(context).pop(); // Đóng dialog tiến trình

        setState(() {
          _isAnalyzing = false;
          _isProcessingImage = false;
        });

        if (result && viewModel.state.analysisResult.data != null) {
          // Lưu kết quả phân tích trước khi xóa ảnh
          final analysisData = viewModel.state.analysisResult.data;

          // Xóa ảnh khỏi state cục bộ nhưng KHÔNG xóa khỏi viewModel để tránh rebuild
          setState(() {
            _selectedImage = null;
          });

          // Ngắt kết nối SignalR để tránh cập nhật liên tục
          viewModel.disconnectSignalR();

          // Sử dụng pushReplacement để thay thế màn hình hiện tại
          Navigator.of(
            context,
          ).pushReplacementNamed(EnhancedSkinAnalysisResultScreen.routeName);
        } else {
          // Bất kể lỗi gì, đều hiển thị lỗi không phát hiện khuôn mặt
          _showErrorDialog(
            'Không phát hiện khuôn mặt',
            'Không phát hiện khuôn mặt trong ảnh. Vui lòng chọn ảnh rõ nét và đảm bảo khuôn mặt hiển thị đầy đủ.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Đóng dialog tiến trình
        setState(() {
          _isAnalyzing = false;
          _isProcessingImage = false;
        });

        // Bất kể lỗi gì, đều hiển thị lỗi không phát hiện khuôn mặt
        _showErrorDialog(
          'Không phát hiện khuôn mặt',
          'Không phát hiện khuôn mặt trong ảnh. Vui lòng chọn ảnh rõ nét và đảm bảo khuôn mặt hiển thị đầy đủ.',
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
                  _pickImage(
                    context,
                    ImageSource.camera,
                    Provider.of<EnhancedSkinAnalysisViewModel>(
                      context,
                      listen: false,
                    ),
                  );
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

    // Lấy viewModel nhưng không listen để tránh rebuild không cần thiết
    final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
      context,
      listen: false,
    );

    // In ra log để theo dõi số lần rebuild
    print(
      'Build camera screen - isAnalyzing: $_isAnalyzing, hasImage: ${_selectedImage != null}',
    );

    return WillPopScope(
      onWillPop: () async {
        // Nếu đang xử lý ảnh, không cho phép quay lại
        if (_isProcessingImage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang xử lý ảnh, vui lòng đợi...'),
              duration: Duration(seconds: 1),
            ),
          );
          return false;
        }

        // Hiển thị dialog xác nhận khi người dùng nhấn nút back
        final shouldPop =
            await showDialog(
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
                          // Quay về trang chủ và đảm bảo xóa ảnh
                          viewModel.resetForCameraScreen();
                          // Reset static flag để cho phép khởi tạo lại trong tương lai
                          _hasBeenInitialized = false;
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Có'),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (shouldPop) {
          // Đảm bảo ngắt kết nối SignalR trước khi rời khỏi màn hình
          viewModel.disconnectSignalR();
        }

        return shouldPop;
      },
      child: Scaffold(
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
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Chụp Ảnh Khuôn Mặt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Image preview or placeholder
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Color(0xFFBCA7FF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover, height: 220)
                            : Container(
                                height: 220,
                                color: Colors.grey[100],
                                child: const Center(child: Text('Chưa có ảnh')),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nút chức năng dưới đáy
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt, color: Color(0xFF8F5CFF)),
                          label: const Text('Chụp ảnh', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold)),
                          onPressed: () => _pickImage(context, ImageSource.camera, viewModel),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo_library, color: Color(0xFF8F5CFF)),
                          label: const Text('Thư viện', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold)),
                          onPressed: () => _pickImage(context, ImageSource.gallery, viewModel),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: ElevatedButton(
                        onPressed: _isAnalyzing ? null : () => _analyzeSkin(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: const Text('Phân tích da', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _isProcessingImage ? null : () {
                        setState(() {
                          _selectedImage = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xóa ảnh'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Xóa ảnh', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    // Reset lại provider khi màn hình không còn active
    print('deactivate: Màn hình camera không còn active');
    final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
      context,
      listen: false,
    );

    // Chỉ ngắt kết nối SignalR khi đã phân tích xong
    if (viewModel.state.status == AnalysisStatus.analyzed) {
      // Sử dụng addPostFrameCallback để tránh gọi setState trong deactivate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        viewModel.disconnectSignalR();
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
    final viewModel = Provider.of<EnhancedSkinAnalysisViewModel>(
      context,
      listen: false,
    );

    // Ngắt kết nối SignalR bất kể trạng thái nào để tránh rebuild liên tục
    viewModel.disconnectSignalR();
    print('Đã ngắt kết nối SignalR khi màn hình bị hủy');

    super.dispose();
  }
}
