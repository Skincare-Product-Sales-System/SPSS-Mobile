import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../root_screen.dart';
import '../../screens/auth/enhanced_forgot_password.dart';
import '../../screens/auth/enhanced_register.dart';
import '../../screens/mvvm_screen_template.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../providers/enhanced_auth_view_model.dart';
import '../../services/my_app_function.dart';
import '../../widgets/auth/google_btn.dart';
import '../../providers/auth_state.dart';

class EnhancedLoginScreen extends StatefulWidget {
  static const routeName = '/EnhancedLoginScreen';
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  bool obscureText = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Focus Nodes
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _emailController.dispose();
      _passwordController.dispose();
      // Focus Nodes
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed to this screen
    final String? fromScreen =
        ModalRoute.of(context)?.settings.arguments as String?;

    return MvvmScreenTemplate<EnhancedAuthViewModel, AuthState>(
      title: 'Đăng nhập',
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      buildAppBar:
          (context, viewModel) =>
              AppBar(title: const Text('Đăng nhập'), elevation: 0),
      buildContent:
          (context, viewModel) => _buildContent(context, viewModel, fromScreen),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedAuthViewModel viewModel,
    String? fromScreen,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
              const SizedBox(height: 40),

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
                        onPressed: () => _loginFct(viewModel, fromScreen),
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

  Future<void> _loginFct(
    EnhancedAuthViewModel viewModel,
    String? fromScreen,
  ) async {
    try {
      final isValid = _formkey.currentState!.validate();
      FocusScope.of(context).unfocus();

      if (!isValid) return;

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang đăng nhập...'),
          duration: Duration(seconds: 2),
        ),
      );

      final success = await viewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to appropriate screen
        if (fromScreen == 'checkout') {
          Navigator.of(context).pushReplacementNamed('/enhanced-checkout');
        } else {
          Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công! Chào mừng trở lại.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        // Show error dialog
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: viewModel.errorMessage ?? 'Đăng nhập thất bại',
          fct: () {},
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: 'Lỗi: ${e.toString()}',
          fct: () {},
        );
      }
    }
  }
}
