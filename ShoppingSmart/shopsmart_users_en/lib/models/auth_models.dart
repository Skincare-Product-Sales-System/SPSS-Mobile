// Authentication request models
class LoginRequest {
  final String usernameOrEmail;
  final String password;

  LoginRequest({required this.usernameOrEmail, required this.password});

  Map<String, dynamic> toJson() {
    return {'usernameOrEmail': usernameOrEmail, 'password': password};
  }
}

class RegisterRequest {
  final String userName;
  final String surName;
  final String lastName;
  final String emailAddress;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  RegisterRequest({
    required this.userName,
    required this.surName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'surName': surName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };
  }
}

// Authentication response models
class AuthResponse {
  final String? token;
  final String? refreshToken;
  final UserInfo? user;
  final DateTime? expiresAt;

  AuthResponse({this.token, this.refreshToken, this.user, this.expiresAt});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}

class UserInfo {
  final String id;
  final String userName;
  final String email;
  final List<String>? roles;

  UserInfo({
    required this.id,
    required this.userName,
    required this.email,
    this.roles,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }

  factory UserInfo.fromTokenData(Map<String, dynamic> tokenData) {
    return UserInfo(
      id: tokenData['id'] ?? '',
      userName: tokenData['userName'] ?? '',
      email: tokenData['email'] ?? '',
      roles: tokenData['role'] != null ? [tokenData['role']] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userName': userName, 'email': email, 'roles': roles};
  }
}
