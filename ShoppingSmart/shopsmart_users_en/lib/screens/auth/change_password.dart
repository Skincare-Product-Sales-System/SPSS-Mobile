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
                      TextFormField(
                        controller: _currentPasswordController,
                        focusNode: _currentPasswordFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureCurrentPassword,
                        decoration: InputDecoration(
                          hintText: "Current Password",
                          prefixIcon: const Icon(IconlyLight.lock),
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
                        ),
                        onFieldSubmitted: (value) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_newPasswordFocusNode);
                        },
                        validator: (value) {
                          return MyValidators.passwordValidator(value);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _newPasswordController,
                        focusNode: _newPasswordFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: "New Password",
                          prefixIcon: const Icon(IconlyLight.lock),
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
                        ),
                        onFieldSubmitted: (value) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_confirmPasswordFocusNode);
                        },
                        validator: (value) {
                          return MyValidators.passwordValidator(value);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
                          prefixIcon: const Icon(IconlyLight.lock),
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
                        ),
                        onFieldSubmitted: (value) async {
                          await _changePasswordFct();
                        },
                        validator: (value) {
                          return MyValidators.repeatPasswordValidator(
                            value: value,
                            password: _newPasswordController.text,
                          );
                        },
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
