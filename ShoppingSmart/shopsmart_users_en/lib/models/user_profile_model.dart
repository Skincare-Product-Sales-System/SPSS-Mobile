class UserProfileModel {
  final String id;
  final String userName;
  final String surName;
  final String lastName;
  final String emailAddress;
  final String phoneNumber;
  final String? avatarUrl;
  final List<String>? roles;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.userName,
    required this.surName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    this.avatarUrl,
    this.roles,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Tạo mới từ JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      surName: json['surName'] ?? '',
      lastName: json['lastName'] ?? '',
      emailAddress: json['emailAddress'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdTime'] != null ? DateTime.parse(json['createdTime']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'surName': surName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Tạo bản sao với các giá trị mới
  UserProfileModel copyWith({
    String? id,
    String? userName,
    String? surName,
    String? lastName,
    String? emailAddress,
    String? phoneNumber,
    String? avatarUrl,
    List<String>? roles,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      surName: surName ?? this.surName,
      lastName: lastName ?? this.lastName,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Lấy tên đầy đủ
  String get fullName => '$surName $lastName';

  // Kiểm tra có phải admin không
  bool get isAdmin => roles?.contains('Admin') ?? false;
}

// Mô hình cập nhật thông tin người dùng
class UpdateProfileRequest {
  final String userName;
  final String surName;
  final String lastName;
  final String emailAddress;
  final String phoneNumber;
  final String? avatarUrl;

  UpdateProfileRequest({
    required this.userName,
    required this.surName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'surName': surName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
    };
  }
}
