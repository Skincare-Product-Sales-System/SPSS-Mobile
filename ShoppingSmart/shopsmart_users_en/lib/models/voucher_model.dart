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

  // Additional fields needed for UI
  final String? discountType;
  final double? maxDiscount;
  final String name;

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
    this.discountType = 'Percentage', // Default to percentage discount
    this.maxDiscount,
    String? name,
  }) : name =
           name ??
           description; // Use description as name if name is not provided

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    print('VoucherModel.fromJson: received json: $json');

    double minimumOrderValue = 0;
    try {
      // Try to parse minimumOrderValue with explicit error handling
      if (json['minimumOrderValue'] != null) {
        if (json['minimumOrderValue'] is int) {
          minimumOrderValue = (json['minimumOrderValue'] as int).toDouble();
        } else if (json['minimumOrderValue'] is double) {
          minimumOrderValue = json['minimumOrderValue'];
        } else if (json['minimumOrderValue'] is String) {
          minimumOrderValue = double.tryParse(json['minimumOrderValue']) ?? 0;
        }
      }
      print(
        'VoucherModel.fromJson: parsed minimumOrderValue = $minimumOrderValue',
      );
    } catch (e) {
      print('VoucherModel.fromJson: error parsing minimumOrderValue: $e');
      minimumOrderValue = 0;
    }

    double discountRate = 0;
    try {
      // Try to parse discountRate with explicit error handling
      if (json['discountRate'] != null) {
        if (json['discountRate'] is int) {
          discountRate = (json['discountRate'] as int).toDouble();
        } else if (json['discountRate'] is double) {
          discountRate = json['discountRate'];
        } else if (json['discountRate'] is String) {
          discountRate = double.tryParse(json['discountRate']) ?? 0;
        }
      }
      print('VoucherModel.fromJson: parsed discountRate = $discountRate');
    } catch (e) {
      print('VoucherModel.fromJson: error parsing discountRate: $e');
      discountRate = 0;
    }

    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      discountRate: discountRate,
      usageLimit: json['usageLimit'] ?? 0,
      minimumOrderValue: minimumOrderValue,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      createdBy: json['createdBy'] ?? '',
      lastUpdatedBy: json['lastUpdatedBy'],
      deletedBy: json['deletedBy'],
      createdTime:
          DateTime.tryParse(json['createdTime'] ?? '') ?? DateTime.now(),
      lastUpdatedTime: DateTime.tryParse(json['lastUpdatedTime'] ?? ''),
      deletedTime: DateTime.tryParse(json['deletedTime'] ?? ''),
      isDeleted: json['isDeleted'] ?? false,
      discountType: json['discountType'] ?? 'Percentage',
      maxDiscount:
          json['maxDiscount'] != null
              ? (json['maxDiscount'] is int
                  ? (json['maxDiscount'] as int).toDouble()
                  : (json['maxDiscount'] is double
                      ? json['maxDiscount']
                      : double.tryParse(json['maxDiscount'].toString())))
              : null,
      name: json['name'] ?? json['description'] ?? '',
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
      'discountType': discountType,
      'maxDiscount': maxDiscount,
      'name': name,
      // Add computed properties for debugging
      '_isActive': isActive,
      '_isExpired': isExpired,
      '_isNotStarted': isNotStarted,
      '_isValid': isValid,
      '_now': DateTime.now().toIso8601String(),
    };
  }

  // Helper methods
  bool get isActive => status.toLowerCase() == 'active';

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isNotStarted => DateTime.now().isBefore(startDate);

  bool get isValid => isActive && !isExpired && !isNotStarted && !isDeleted;

  bool canApplyToOrder(double orderValue) {
    print(
      'VoucherModel.canApplyToOrder: orderValue=$orderValue, minimumOrderValue=$minimumOrderValue, isValid=$isValid',
    );
    print(
      'VoucherModel.canApplyToOrder details: isActive=$isActive, isExpired=$isExpired, isNotStarted=$isNotStarted, isDeleted=$isDeleted',
    );

    // Check minimum order value as a separate condition to provide more specific error messages
    return isValid && orderValue >= minimumOrderValue;
  }

  // Return specific validation error message if voucher can't be applied
  String? getValidationError(double orderValue) {
    if (!isActive) {
      return 'Voucher không hoạt động';
    }
    if (isExpired) {
      return 'Voucher đã hết hạn';
    }
    if (isNotStarted) {
      return 'Voucher chưa đến thời gian sử dụng';
    }
    if (isDeleted) {
      return 'Voucher đã bị xóa';
    }
    if (orderValue < minimumOrderValue) {
      return 'Đơn hàng phải có giá trị tối thiểu ${minimumOrderValue.toStringAsFixed(0)}đ để áp dụng voucher này';
    }
    return null;
  }

  double calculateDiscount(double orderValue) {
    print(
      'VoucherModel.calculateDiscount: orderValue=$orderValue, discountRate=$discountRate, discountType=$discountType',
    );

    String? validationError = getValidationError(orderValue);
    if (validationError != null) {
      print(
        'VoucherModel.calculateDiscount: Cannot apply voucher: $validationError',
      );
      return 0;
    }

    double discount = 0;
    if (discountType == 'Percentage') {
      // Calculate percentage discount
      discount = orderValue * (discountRate / 100);
      print(
        'VoucherModel.calculateDiscount: Percentage discount: $discount ($discountRate% of $orderValue)',
      );

      // Apply maximum discount cap if set
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
        print(
          'VoucherModel.calculateDiscount: Capped at maxDiscount: $discount',
        );
      }
    } else {
      // Fixed amount discount
      discount = discountRate; // Use discountRate for fixed amount as well
      print('VoucherModel.calculateDiscount: Fixed amount discount: $discount');
    }

    print('VoucherModel.calculateDiscount: Final discount amount: $discount');
    return discount;
  }

  // Backward compatibility getter for discountAmount
  double get discountAmount {
    // This assumes discountRate is the value to use
    // regardless of discountType, as handled in calculateDiscount
    return discountRate;
  }

  // Backward compatibility getter for discountValue
  double get discountValue => discountRate;

  @override
  String toString() {
    return 'VoucherModel(id: $id, code: $code, description: $description, discountRate: $discountRate%, status: $status)';
  }
}
