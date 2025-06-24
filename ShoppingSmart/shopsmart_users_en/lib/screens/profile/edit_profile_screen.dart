import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopsmart_users_en/services/jwt_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = true;
  bool isUpdating = false;
  Map<String, dynamic>? userData;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? editingField;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    final token = await JwtService.getStoredToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final res = await http.get(
      Uri.parse('https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api/accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      userData = data['data'];
      _controllers['userName'] = TextEditingController(
        text: userData?['userName'] ?? '',
      );
      _controllers['surName'] = TextEditingController(
        text: userData?['surName'] ?? '',
      );
      _controllers['lastName'] = TextEditingController(
        text: userData?['lastName'] ?? '',
      );
      _controllers['emailAddress'] = TextEditingController(
        text: userData?['emailAddress'] ?? '',
      );
      _controllers['phoneNumber'] = TextEditingController(
        text: userData?['phoneNumber'] ?? '',
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateUserData(String field) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isUpdating = true;
    });
    final token = await JwtService.getStoredToken();
    if (token == null) {
      setState(() {
        isUpdating = false;
        editingField = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có token xác thực!')));
      return;
    }
    final body = {
      'userName': _controllers['userName']!.text,
      'surName': _controllers['surName']!.text,
      'lastName': _controllers['lastName']!.text,
      'emailAddress': _controllers['emailAddress']!.text,
      'phoneNumber': _controllers['phoneNumber']!.text,
    };
    final res = await http.patch(
      Uri.parse('https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api/accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
    setState(() {
      isUpdating = false;
      editingField = null;
    });
    if (res.statusCode == 200) {
      fetchUserData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
    } else {
      print('Update error: \\${res.statusCode} - \\${res.body}');
      String errorMsg = 'Cập nhật thất bại!';
      try {
        final err = json.decode(res.body);
        if (err['message'] != null && err['message'].toString().isNotEmpty) {
          errorMsg = err['message'];
        } else if (err['errors'] != null &&
            err['errors'] is List &&
            err['errors'].isNotEmpty) {
          errorMsg = err['errors'].join(', ');
        }
      } catch (_) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
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
    final isEditingAll = editingField == 'all';
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
              : userData == null
              ? const Center(child: Text('Không thể tải thông tin người dùng.'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                userData?['avatarUrl'] != null &&
                                        userData?['avatarUrl'] != ''
                                    ? NetworkImage(userData!['avatarUrl'])
                                        as ImageProvider
                                    : const NetworkImage(
                                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                                    ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?['userName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData?['emailAddress'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: primaryColor,
                              size: 28,
                            ),
                            tooltip: 'Edit profile',
                            onPressed: () {
                              setState(() {
                                editingField = 'all';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildEditableField(
                              'userName',
                              'Tên người dùng',
                              icon: Icons.person,
                              forceEdit: isEditingAll,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                            ),
                            _buildEditableField(
                              'surName',
                              'Họ',
                              icon: Icons.badge,
                              forceEdit: isEditingAll,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                            ),
                            _buildEditableField(
                              'lastName',
                              'Tên đầy đủ',
                              icon: Icons.account_box,
                              forceEdit: isEditingAll,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                            ),
                            _buildEditableField(
                              'emailAddress',
                              'Email',
                              isEmail: true,
                              icon: Icons.email,
                              forceEdit: isEditingAll,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                            ),
                            _buildEditableField(
                              'phoneNumber',
                              'Số điện thoại',
                              icon: Icons.phone,
                              forceEdit: isEditingAll,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildEditableField(
    String field,
    String label, {
    bool isEmail = false,
    IconData? icon,
    bool forceEdit = false,
    Color? textColor,
    Color? subTextColor,
    Color? cardColor,
    Color? primaryColor,
  }) {
    final isEditing = editingField == field || forceEdit;
    textColor ??= Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    subTextColor ??=
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
        Colors.grey[700];
    cardColor ??= Theme.of(context).cardColor;
    primaryColor ??= Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEditing ? primaryColor : Colors.grey.shade200,
              width: 1.2,
            ),
            color: cardColor,
          ),
          child:
              isEditing
                  ? TextFormField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      labelText: label,
                      prefixIcon:
                          icon != null ? Icon(icon, color: primaryColor) : null,
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.2,
                        ),
                      ),
                      suffixIcon:
                          isUpdating
                              ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Icon(Icons.check, color: primaryColor),
                                onPressed: () => updateUserData(field),
                              ),
                    ),
                    style: TextStyle(color: textColor),
                    keyboardType:
                        isEmail
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Trường này là bắt buộc';
                      }
                      if (isEmail && !val.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  )
                  : ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    leading:
                        icon != null ? Icon(icon, color: primaryColor) : null,
                    title: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Text(
                      _controllers[field]?.text ?? '',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
                        setState(() {
                          editingField = field;
                        });
                      },
                    ),
                  ),
        ),
      ),
    );
  }
}
