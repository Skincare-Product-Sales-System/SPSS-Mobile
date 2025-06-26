import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/user_profile_model.dart';
import '../../providers/enhanced_profile_view_model.dart';
import '../../widgets/title_text.dart';

class EnhancedEditProfileScreen extends StatefulWidget {
  static const routeName = '/enhanced-edit-profile';
  const EnhancedEditProfileScreen({super.key});

  @override
  State<EnhancedEditProfileScreen> createState() =>
      _EnhancedEditProfileScreenState();
}

class _EnhancedEditProfileScreenState extends State<EnhancedEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? _editingField;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initControllers();

    // Lấy thông tin profile khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EnhancedProfileViewModel>(
        context,
        listen: false,
      );
      if (viewModel.userProfile == null) {
        viewModel.fetchUserProfile();
      }
    });
  }

  void _initControllers() {
    _controllers['userName'] = TextEditingController();
    _controllers['surName'] = TextEditingController();
    _controllers['lastName'] = TextEditingController();
    _controllers['emailAddress'] = TextEditingController();
    _controllers['phoneNumber'] = TextEditingController();
  }

  void _updateControllers(UserProfileModel userProfile) {
    _controllers['userName']!.text = userProfile.userName;
    _controllers['surName']!.text = userProfile.surName;
    _controllers['lastName']!.text = userProfile.lastName;
    _controllers['emailAddress']!.text = userProfile.emailAddress;
    _controllers['phoneNumber']!.text = userProfile.phoneNumber;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Upload ảnh đại diện
      final viewModel = Provider.of<EnhancedProfileViewModel>(
        context,
        listen: false,
      );
      await viewModel.updateAvatar(image.path);
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = Provider.of<EnhancedProfileViewModel>(
      context,
      listen: false,
    );

    final request = UpdateProfileRequest(
      userName: _controllers['userName']!.text,
      surName: _controllers['surName']!.text,
      lastName: _controllers['lastName']!.text,
      emailAddress: _controllers['emailAddress']!.text,
      phoneNumber: _controllers['phoneNumber']!.text,
    );

    await viewModel.updateProfile(request);
    setState(() {
      _editingField = null;
    });

    // After update is complete, pop back with the updated data
    if (mounted) {
      // Return the updated user data directly to the profile screen
      // This ensures the UI can update even if API calls fail
      Navigator.of(context).pop({
        'userName': request.userName,
        'surName': request.surName,
        'lastName': request.lastName,
        'emailAddress': request.emailAddress,
        'phoneNumber': request.phoneNumber,
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
        Colors.grey[700];

    return Consumer<EnhancedProfileViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;
        final isUpdating = viewModel.isUpdating;
        final userProfile = viewModel.userProfile;
        final errorMessage = viewModel.errorMessage;

        // Cập nhật controllers nếu có dữ liệu mới
        if (userProfile != null) {
          _updateControllers(userProfile);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userProfile == null
                  ? const Center(
                    child: Text('Không thể tải thông tin người dùng.'),
                  )
                  : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildProfileHeader(context, userProfile),
                            _buildProfileForm(context, userProfile),
                          ],
                        ),
                      ),
                      if (isUpdating)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (userProfile.avatarUrl != null &&
                                  userProfile.avatarUrl!.isNotEmpty
                              ? NetworkImage(userProfile.avatarUrl!)
                                  as ImageProvider
                              : const NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                              )),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TitlesTextWidget(
            label: '${userProfile.surName} ${userProfile.lastName}',
            fontSize: 22,
          ),
          const SizedBox(height: 8),
          Text(
            userProfile.emailAddress,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, UserProfileModel userProfile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField(
              context: context,
              label: 'Tên đăng nhập',
              value: userProfile.userName,
              fieldName: 'userName',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên đăng nhập';
                }
                return null;
              },
            ),
            _buildEditableField(
              context: context,
              label: 'Họ',
              value: userProfile.surName,
              fieldName: 'surName',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ';
                }
                return null;
              },
            ),
            _buildEditableField(
              context: context,
              label: 'Tên',
              value: userProfile.lastName,
              fieldName: 'lastName',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên';
                }
                return null;
              },
            ),
            _buildEditableField(
              context: context,
              label: 'Email',
              value: userProfile.emailAddress,
              fieldName: 'emailAddress',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Vui lòng nhập email hợp lệ';
                }
                return null;
              },
            ),
            _buildEditableField(
              context: context,
              label: 'Số điện thoại',
              value: userProfile.phoneNumber,
              fieldName: 'phoneNumber',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _editingField = 'all';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Chỉnh sửa tất cả',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required String value,
    required String fieldName,
    required String? Function(String?) validator,
  }) {
    final isEditing = _editingField == fieldName || _editingField == 'all';
    final primaryColor = Theme.of(context).primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              if (_editingField != 'all' && !isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _editingField = fieldName;
                    });
                  },
                  icon: Icon(Icons.edit, color: primaryColor),
                  splashRadius: 24,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditing)
            TextFormField(
              controller: _controllers[fieldName],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: validator,
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(value, style: const TextStyle(fontSize: 16)),
            ),
          if (isEditing && _editingField != 'all')
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingField = null;
                          _controllers[fieldName]!.text = value;
                        });
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ),
            ),
          if (_editingField == 'all' && fieldName == 'phoneNumber')
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingField = null;
                          _updateControllers(
                            Provider.of<EnhancedProfileViewModel>(
                              context,
                              listen: false,
                            ).userProfile!,
                          );
                        });
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text('Lưu tất cả'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
