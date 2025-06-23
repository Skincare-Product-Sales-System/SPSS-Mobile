import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../consts/validator.dart';
import '../../services/assets_manager.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';
import '../../providers/enhanced_auth_view_model.dart';
import '../../providers/auth_state.dart';
import '../mvvm_screen_template.dart';

class EnhancedForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/EnhancedForgotPasswordScreen';
  const EnhancedForgotPasswordScreen({super.key});

  @override
  State<EnhancedForgotPasswordScreen> createState() =>
      _EnhancedForgotPasswordScreenState();
}

class _EnhancedForgotPasswordScreenState
    extends State<EnhancedForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _emailController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedAuthViewModel, AuthState>(
      title: 'Quên mật khẩu',
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      buildAppBar:
          (context, viewModel) => AppBar(
            centerTitle: true,
            title: const AppNameTextWidget(fontSize: 22),
          ),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, EnhancedAuthViewModel viewModel) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            // Section 1 - Header
            const SizedBox(height: 10),
            Image.asset(
              AssetsManager.forgotPassword,
              width: size.width * 0.6,
              height: size.width * 0.6,
            ),
            const SizedBox(height: 10),
            const TitlesTextWidget(label: 'Quên mật khẩu', fontSize: 22),
            const SubtitleTextWidget(
              label:
                  'Vui lòng nhập địa chỉ email mà bạn muốn nhận thông tin đặt lại mật khẩu',
              fontSize: 14,
            ),
            const SizedBox(height: 40),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'youremail@email.com',
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(IconlyLight.message),
                      ),
                      filled: true,
                    ),
                    validator: (value) {
                      return MyValidators.emailValidator(value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(IconlyBold.send),
                label: const Text(
                  "Yêu cầu liên kết",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  final isValid = _formKey.currentState!.validate();
                  FocusScope.of(context).unfocus();

                  if (!isValid) return;

                  final success = await viewModel.forgotPassword(
                    _emailController.text.trim(),
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Hướng dẫn đặt lại mật khẩu đã được gửi đến email của bạn',
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
