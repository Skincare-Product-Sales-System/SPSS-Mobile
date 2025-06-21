import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../providers/enhanced_auth_view_model.dart';
import '../../providers/auth_state.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/title_text.dart';
import '../mvvm_screen_template.dart';

class EnhancedChangePasswordScreen extends StatefulWidget {
  static const routeName = '/EnhancedChangePasswordScreen';
  const EnhancedChangePasswordScreen({super.key});

  @override
  State<EnhancedChangePasswordScreen> createState() =>
      _EnhancedChangePasswordScreenState();
}

class _EnhancedChangePasswordScreenState
    extends State<EnhancedChangePasswordScreen> {
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  late final FocusNode _currentPasswordFocusNode;
  late final FocusNode _newPasswordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    // Focus Nodes
    _currentPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _currentPasswordController.dispose();
      _newPasswordController.dispose();
      _confirmPasswordController.dispose();
      // Focus Nodes
      _currentPasswordFocusNode.dispose();
      _newPasswordFocusNode.dispose();
      _confirmPasswordFocusNode.dispose();
    }
    super.dispose();
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color:
                  isValid
                      ? Colors.green.withOpacity(0.1)
                      : Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isValid
                        ? Colors.green
                        : Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.withOpacity(0.4)
                        : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Icon(
              isValid ? Icons.check : Icons.close,
              size: 12,
              color:
                  isValid
                      ? Colors.green
                      : Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade600
                      : Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color:
                    isValid
                        ? Colors.green.shade700
                        : Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF4A5568)
                        : Colors.grey,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedAuthViewModel, AuthState>(
      title: 'Đổi mật khẩu',
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      buildAppBar:
          (context, viewModel) =>
              AppBar(title: const Text('Đổi mật khẩu'), centerTitle: true),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, EnhancedAuthViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const AppNameTextWidget(fontSize: 24),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: TitlesTextWidget(label: "Thay đổi mật khẩu của bạn"),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.withOpacity(0.2)
                                  : Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: TextFormField(
                        controller: _currentPasswordController,
                        focusNode: _currentPasswordFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureCurrentPassword,
                        decoration: InputDecoration(
                          hintText: "Mật khẩu hiện tại",
                          prefixIcon: Icon(
                            IconlyLight.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureCurrentPassword =
                                    !obscureCurrentPassword;
                              });
                            },
                            icon: Icon(
                              obscureCurrentPassword
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
                        onFieldSubmitted: (value) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_newPasswordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu hiện tại';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey.withOpacity(0.2)
                                      : Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: TextFormField(
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureNewPassword,
                            decoration: InputDecoration(
                              hintText: "Mật khẩu mới",
                              prefixIcon: Icon(
                                IconlyLight.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureNewPassword = !obscureNewPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureNewPassword
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
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_confirmPasswordFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu mới';
                              }

                              // Check each requirement separately for better error messages
                              if (value.length < 8) {
                                return 'Mật khẩu phải có ít nhất 8 ký tự';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return 'Mật khẩu phải có ít nhất 1 chữ thường';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Mật khẩu phải có ít nhất 1 chữ hoa';
                              }
                              if (!RegExp(r'\d').hasMatch(value)) {
                                return 'Mật khẩu phải có ít nhất 1 số';
                              }
                              if (!RegExp(
                                r'[!@#\$%^&*()_+={}[\]|\\:;<>,.?/~`]',
                              ).hasMatch(value)) {
                                return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              setState(() {}); // Refresh validation display
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFFF7FAFC)
                                    : Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.15)
                                      : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Yêu cầu mật khẩu mới:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? const Color(0xFF2D3748)
                                              : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildPasswordRequirement(
                                '• Ít nhất 8 ký tự',
                                _newPasswordController.text.length >= 8,
                              ),
                              _buildPasswordRequirement(
                                '• Có ít nhất 1 chữ thường (a-z)',
                                RegExp(
                                  r'[a-z]',
                                ).hasMatch(_newPasswordController.text),
                              ),
                              _buildPasswordRequirement(
                                '• Có ít nhất 1 chữ hoa (A-Z)',
                                RegExp(
                                  r'[A-Z]',
                                ).hasMatch(_newPasswordController.text),
                              ),
                              _buildPasswordRequirement(
                                '• Có ít nhất 1 số (0-9)',
                                RegExp(
                                  r'\d',
                                ).hasMatch(_newPasswordController.text),
                              ),
                              _buildPasswordRequirement(
                                '• Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*...)',
                                RegExp(
                                  r'[!@#\$%^&*()_+={}[\]|\\:;<>,.?/~`]',
                                ).hasMatch(_newPasswordController.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.withOpacity(0.2)
                                  : Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: "Xác nhận mật khẩu mới",
                          prefixIcon: Icon(
                            IconlyLight.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
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
                        onFieldSubmitted: (value) async {
                          await _changePassword(viewModel);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu mới';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        icon: const Icon(Icons.security),
                        label: const Text("Đổi mật khẩu"),
                        onPressed: () async {
                          await _changePassword(viewModel);
                        },
                      ),
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

  Future<void> _changePassword(EnhancedAuthViewModel viewModel) async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    final success = await viewModel.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu đã được thay đổi thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
