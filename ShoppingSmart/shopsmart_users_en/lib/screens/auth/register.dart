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

import '../../widgets/auth/image_picker_widget.dart';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscureText = true;
  bool _isLoading = false;
  late final TextEditingController _nameController,
      _emailController,
      _passwordController,
      _repeatPasswordController;

  late final FocusNode _nameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _repeatPasswordFocusNode;

  final _formkey = GlobalKey<FormState>();
  XFile? _pickedImage;
  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    // Focus Nodes
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _nameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      _repeatPasswordController.dispose();
      // Focus Nodes
      _nameFocusNode.dispose();
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
      _repeatPasswordFocusNode.dispose();
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
      final registerRequest = RegisterRequest(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _repeatPasswordController.text,
      );

      final response = await AuthService.register(registerRequest);

      if (response.success) {
        // Registration successful
        if (mounted) {
          MyAppFunctions.showErrorOrWarningDialog(
            context: context,
            subtitle: 'Registration successful! Welcome to ShopSmart.',
            fct: () {
              Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
            },
          );
        }
      } else {
        // Registration failed
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                  const TitlesTextWidget(label: "Welcome back!", fontSize: 28),
                  const SizedBox(height: 8),
                  SubtitleTextWidget(
                    label: "Your welcome message",
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
                        // Full Name Field
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
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
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
                              hintText: "Email address",
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
                              return MyValidators.emailValidator(value);
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
                              hintText: "***********",
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
                              ).requestFocus(_repeatPasswordFocusNode);
                            },
                            validator: (value) {
                              return MyValidators.passwordValidator(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Repeat Password Field
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
                            controller: _repeatPasswordController,
                            focusNode: _repeatPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              hintText: "Repeat password",
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
