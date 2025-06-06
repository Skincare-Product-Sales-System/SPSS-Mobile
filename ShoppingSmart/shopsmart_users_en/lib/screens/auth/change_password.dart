import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:shopsmart_users_en/consts/validator.dart';
import 'package:shopsmart_users_en/services/auth_service.dart';
import 'package:shopsmart_users_en/models/auth_models.dart';
import 'package:shopsmart_users_en/services/my_app_function.dart';
import 'package:shopsmart_users_en/widgets/app_name_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/ChangePasswordScreen';
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

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

  Future<void> _changePasswordFct() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final changePasswordRequest = ChangePasswordRequest(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      final response = await AuthService.changePassword(changePasswordRequest);

      if (response.success) {
        // Password change successful
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: 'Password changed successfully!',
            fct: () {
              Navigator.of(context).pop();
            },
          );
        }
      } else {
        // Password change failed
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: response.message,
            fct: () {},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle:
              'An error occurred while changing password: ${e.toString()}',
          fct: () {},
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const AppNameTextWidget(fontSize: 24),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: TitlesTextWidget(label: "Change Your Password"),
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
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: TextFormField(
                          controller: _currentPasswordController,
                          focusNode: _currentPasswordFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureCurrentPassword,
                          decoration: InputDecoration(
                            hintText: "Current Password",
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey.shade500
                                      : null,
                            ),
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
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey.shade600
                                        : null,
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
                            // Temporarily removed validation for testing
                            return null;
                            // return MyValidators.passwordValidator(value);
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
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
                              boxShadow:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: TextFormField(
                              controller: _newPasswordController,
                              focusNode: _newPasswordFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: obscureNewPassword,
                              decoration: InputDecoration(
                                hintText: "New Password",
                                hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey.shade500
                                          : null,
                                ),
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
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey.shade600
                                            : null,
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
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
                              boxShadow:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : null,
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
                                                : Theme.of(
                                                  context,
                                                ).primaryColor,
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
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: "Confirm New Password",
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey.shade500
                                      : null,
                            ),
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
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey.shade600
                                        : null,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            await _changePasswordFct();
                          },
                          validator: (value) {
                            // Temporarily removed validation for testing
                            return null;
                            // return MyValidators.repeatPasswordValidator(
                            //   value: value,
                            //   password: _newPasswordController.text,
                            // );
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
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.security),
                          label: Text(
                            _isLoading
                                ? "Changing Password..."
                                : "Change Password",
                          ),
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    await _changePasswordFct();
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
      ),
    );
  }
}
