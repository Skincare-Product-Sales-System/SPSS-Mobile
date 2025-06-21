class VoucherModel {
  final String id;
  final String code;
  final String description;
  final String status;
  final double discountRate;
  final int usageLimit;
  final double minimumOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final String? lastUpdatedBy;
  final String? deletedBy;
  final DateTime createdTime;
  final DateTime? lastUpdatedTime;
  final DateTime? deletedTime;
  final bool isDeleted;

  VoucherModel({
    required this.id,
    required this.code,
    required this.description,
    required this.status,
    required this.discountRate,
    required this.usageLimit,
    required this.minimumOrderValue,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.lastUpdatedBy,
    this.deletedBy,
    required this.createdTime,
    this.lastUpdatedTime,
    this.deletedTime,
    required this.isDeleted,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      discountRate: (json['discountRate'] ?? 0).toDouble(),
      usageLimit: json['usageLimit'] ?? 0,
      minimumOrderValue: (json['minimumOrderValue'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdBy: json['createdBy'] ?? '',
      lastUpdatedBy: json['lastUpdatedBy'],
      deletedBy: json['deletedBy'],
      createdTime: DateTime.parse(json['createdTime']),
      lastUpdatedTime:
          json['lastUpdatedTime'] != null
              ? DateTime.parse(json['lastUpdatedTime'])
              : null,
      deletedTime:
          json['deletedTime'] != null
              ? DateTime.parse(json['deletedTime'])
              : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'status': status,
      'discountRate': discountRate,
      'usageLimit': usageLimit,
      'minimumOrderValue': minimumOrderValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdBy': createdBy,
      'lastUpdatedBy': lastUpdatedBy,
      'deletedBy': deletedBy,
      'createdTime': createdTime.toIso8601String(),
      'lastUpdatedTime': lastUpdatedTime?.toIso8601String(),
      'deletedTime': deletedTime?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // Helper methods
  bool get isActive => status.toLowerCase() == 'active';

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isNotStarted => DateTime.now().isBefore(startDate);

  bool get isValid => isActive && !isExpired && !isNotStarted && !isDeleted;

  bool canApplyToOrder(double orderValue) {
    return isValid && orderValue >= minimumOrderValue;
  }

  double calculateDiscount(double orderValue) {
    if (!canApplyToOrder(orderValue)) return 0;
    return orderValue * (discountRate / 100);
  }

  // For backward compatibility
  double get discountAmount => discountRate;

  @override
  String toString() {
    return 'VoucherModel(id: $id, code: $code, description: $description, discountRate: $discountRate%, status: $status)';
  }
}
