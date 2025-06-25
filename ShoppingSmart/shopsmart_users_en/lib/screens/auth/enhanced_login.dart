import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../root_screen.dart';
import '../../screens/auth/enhanced_forgot_password.dart';
import '../../screens/auth/enhanced_register.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../repositories/auth_repository.dart';
import '../../services/service_locator.dart';
import '../../widgets/auth/google_btn.dart';

class EnhancedLoginScreen extends StatefulWidget {
  static const routeName = '/EnhancedLoginScreen';
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  bool obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _formkey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed to this screen
    final String? fromScreen =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập'), elevation: 0),
      body: Stack(
        children: [
          _buildContent(context, fromScreen),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String? fromScreen) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // App Name with centered alignment
              const Center(child: AppNameTextWidget(fontSize: 32)),
              const SizedBox(height: 40),

              // Welcome message
              const TitlesTextWidget(label: "Chào mừng trở lại!", fontSize: 28),
              const SizedBox(height: 8),
              SubtitleTextWidget(
                label: "Thông điệp chào mừng của bạn",
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              const SizedBox(height: 16),

              // Error message (if any)
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Login Form
              Form(
                key: _formkey,
                child: Column(
                  children: [
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
                          ).requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@')) {
                            return 'Vui lòng nhập email hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

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
                        obscureText: obscureText,
                        textInputAction: TextInputAction.done,
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
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedForgotPasswordScreen.routeName,
                          );
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : () => _login(fromScreen),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Or continue with
                    Row(
                      children: [
                        const Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Hoặc tiếp tục với",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Button
                    const GoogleButton(),
                    const SizedBox(height: 24),

                    // Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản?",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              EnhancedRegisterScreen.routeName,
                            );
                          },
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(String? fromScreen) async {
    // Validate form
    if (!_formkey.currentState!.validate()) {
      return;
    }

    // Clear any previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Remove keyboard
    FocusScope.of(context).unfocus();

    try {
      // Get repository instance
      final authRepository = sl<AuthRepository>();

      // Call login API
      final result = await authRepository.login(
        usernameOrEmail: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if widget is still mounted before updating UI
      if (!mounted) return;

      // Handle login result
      if (result.success && result.data != null) {
        // Login successful
        if (fromScreen == 'checkout') {
          Navigator.of(context).pushReplacementNamed('/enhanced-checkout');
        } else {
          Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
        }
      } else {
        // Login failed - show error
        setState(() {
          _isLoading = false;
          _errorMessage = result.message ?? 'Đăng nhập thất bại';
          _passwordController.clear();
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi: ${e.toString()}';
          _passwordController.clear();
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        });
      }
    }
  }
}
