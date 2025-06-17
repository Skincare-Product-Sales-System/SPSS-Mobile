import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_users_en/consts/validator.dart';
import 'package:shopsmart_users_en/services/my_app_function.dart';
import 'package:shopsmart_users_en/widgets/app_name_text.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';
import 'package:shopsmart_users_en/services/auth_service.dart';
import 'package:shopsmart_users_en/models/auth_models.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/auth/login.dart';
import 'package:shopsmart_users_en/screens/checkout/checkout_screen.dart';
import '../../widgets/auth/image_picker_widget.dart';
import '../../widgets/auth/google_btn.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscureText = true;
  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  late final TextEditingController _userNameController,
      _surNameController,
      _lastNameController,
      _emailController,
      _phoneNumberController,
      _passwordController,
      _confirmPasswordController;

  late final FocusNode _userNameFocusNode,
      _surNameFocusNode,
      _lastNameFocusNode,
      _emailFocusNode,
      _phoneNumberFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode;

  final _formkey = GlobalKey<FormState>();
  XFile? _pickedImage;
  @override
  void initState() {
    _userNameController = TextEditingController();
    _surNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    // Focus Nodes
    _userNameFocusNode = FocusNode();
    _surNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _userNameController.dispose();
      _surNameController.dispose();
      _lastNameController.dispose();
      _emailController.dispose();
      _phoneNumberController.dispose();
      _passwordController.dispose();
      _confirmPasswordController.dispose();
      // Focus Nodes
      _userNameFocusNode.dispose();
      _surNameFocusNode.dispose();
      _lastNameFocusNode.dispose();
      _emailFocusNode.dispose();
      _phoneNumberFocusNode.dispose();
      _passwordFocusNode.dispose();
      _confirmPasswordFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _registerFCT() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: In ra giá trị các trường nhập liệu
      print('DEBUG INPUT VALUES:');
      print('userName: ${_userNameController.text.trim()}');
      print('surName: ${_surNameController.text.trim()}');
      print('lastName: ${_lastNameController.text.trim()}');
      print('emailAddress: ${_emailController.text.trim()}');
      print('phoneNumber: ${_phoneNumberController.text.trim()}');

      // Tạo request theo đúng định dạng Swagger
      final requestData = {
        'userName': _userNameController.text.trim(),
        'surName': _surNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'emailAddress': _emailController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'password': _passwordController.text,
      };

      // Debug: In ra JSON trước khi gửi đi
      print('DIRECT REQUEST JSON: ${json.encode(requestData)}');

      // Gọi API trực tiếp để đảm bảo định dạng đúng
      final uri = Uri.parse('${AuthService.baseUrl}/authentications/register');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('REGISTER API RESPONSE STATUS: ${response.statusCode}');
      print('REGISTER API RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Đăng ký thành công
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Show success message with snackbar instead of dialog for better UX
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Chuyển đến màn hình đăng nhập
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        }
      } else {
        // Đăng ký thất bại
        String errorMessage = "Đăng ký không thành công";

        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          errorMessage = jsonData['message'] ?? errorMessage;
        } catch (e) {
          print('Không thể parse response body: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'An error occurred during registration: ${e.toString()}',
          fct: () {},
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
        setState(() {});
      },
      galleryFCT: () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  // Thêm hàm hiển thị yêu cầu mật khẩu
  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productsProvider = Provider.of<ProductsProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // App Name with centered alignment
                  Center(child: const AppNameTextWidget(fontSize: 32)),
                  const SizedBox(height: 40),

                  // Welcome message
                  const TitlesTextWidget(
                    label: "Chào mừng trở lại!",
                    fontSize: 28,
                  ),
                  const SizedBox(height: 8),
                  SubtitleTextWidget(
                    label: "Thông điệp chào mừng của bạn",
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(height: 32),

                  // Profile Image Picker
                  Center(
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: PickImageWidget(
                              pickedImage: _pickedImage,
                              function: () async {
                                await localImagePicker();
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  await localImagePicker();
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // Username Field
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _userNameController,
                            focusNode: _userNameFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Tên đăng nhập',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_surNameFocusNode);
                            },
                            validator: (value) {
                              return MyValidators.displayNamevalidator(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Surname Field (Họ)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _surNameController,
                            focusNode: _surNameFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Họ',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_lastNameFocusNode);
                            },
                            validator: (value) {
                              return MyValidators.displayNamevalidator(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Lastname Field (Tên)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Tên',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_emailFocusNode);
                            },
                            validator: (value) {
                              return MyValidators.displayNamevalidator(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Địa chỉ email",
                              prefixIcon: Icon(
                                IconlyLight.message,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_phoneNumberFocusNode);
                            },
                            validator: (value) {
                              // return MyValidators.emailValidator(value);
                              return null; // Commented out for testing
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Phone Number Field
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _phoneNumberController,
                            focusNode: _phoneNumberFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Số điện thoại",
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode);
                            },
                            validator: (value) {
                              // return MyValidators.phoneValidator(value);
                              return null; // Commented out for testing
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              hintText: "Mật khẩu",
                              prefixIcon: Icon(
                                IconlyLight.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.7),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              FocusScope.of(
                                context,
                              ).requestFocus(_confirmPasswordFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                _showPasswordRequirements = true;
                              });
                            },
                            validator: (value) {
                              return MyValidators.passwordValidator(value);
                            },
                          ),
                        ),

                        // Hiển thị yêu cầu mật khẩu
                        if (_showPasswordRequirements)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yêu cầu mật khẩu:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildPasswordRequirement(
                                  'Ít nhất 6 ký tự',
                                  _passwordController.text.length >= 6,
                                ),
                                _buildPasswordRequirement(
                                  'Có ít nhất 1 chữ in hoa (A-Z)',
                                  RegExp(
                                    r'[A-Z]',
                                  ).hasMatch(_passwordController.text),
                                ),
                                _buildPasswordRequirement(
                                  'Có ít nhất 1 số (0-9)',
                                  RegExp(
                                    r'\d',
                                  ).hasMatch(_passwordController.text),
                                ),
                                _buildPasswordRequirement(
                                  'Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*...)',
                                  RegExp(
                                    r'[!@#\$%^&*()_+={}[\]|\\:;<>,.?/~`]',
                                  ).hasMatch(_passwordController.text),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              hintText: "Nhập lại mật khẩu",
                              prefixIcon: Icon(
                                IconlyLight.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.7),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              await _registerFCT();
                            },
                            validator: (value) {
                              return MyValidators.repeatPasswordValidator(
                                value: value,
                                password: _passwordController.text,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () async {
                                      await _registerFCT();
                                    },
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          IconlyLight.add_user,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sign up",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
