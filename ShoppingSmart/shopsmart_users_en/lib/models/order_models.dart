class OrderDetail {
  final String productItemId;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final List<String> variationOptionValues;
  final bool isReviewable;

  OrderDetail({
    required this.productItemId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.variationOptionValues,
    required this.isReviewable,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productItemId: json['productItemId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      variationOptionValues:
          (json['variationOptionValues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isReviewable: json['isReviewable'] ?? false,
    );
  }

  @override
  String toString() {
    return 'OrderDetail(productItemId: $productItemId, productId: $productId, productName: $productName, quantity: $quantity, price: $price)';
  }

  Map<String, dynamic> toJson() {
    return {
      'productItemId': productItemId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
      'variationOptionValues': variationOptionValues,
      'isReviewable': isReviewable,
    };
  }
}

class CreateOrderRequest {
  final String addressId;
  final String paymentMethodId;
  final String? voucherId;
  final List<OrderDetail> orderDetails;

  CreateOrderRequest({
    required this.addressId,
    required this.paymentMethodId,
    this.voucherId,
    required this.orderDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'paymentMethodId': paymentMethodId,
      'voucherId': voucherId,
      'OrderDetail': orderDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

class OrderResponse {
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;

  OrderResponse({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr');
        return DateTime.now();
      }
    }

    return OrderResponse(
      orderId: json['id'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['orderTotal'] ?? 0).toDouble(),
      createdAt: parseDateTime(json['createdTime'] as String?),
    );
  }
}

class OrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? cancelReasonId;
  final String paymentMethodId;
  final List<OrderDetail> orderDetails;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.cancelReasonId,
    required this.paymentMethodId,
    required this.orderDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr');
        return DateTime.now();
      }
    }

    List<OrderDetail> parseOrderDetails(dynamic details) {
      if (details == null) return [];
      if (details is List) {
        return details.map((detail) => OrderDetail.fromJson(detail)).toList();
      }
      return [];
    }

    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['orderTotal'] ?? 0).toDouble(),
      createdAt: parseDateTime(json['createdTime']),
      cancelReasonId: json['cancelReasonId'],
      paymentMethodId: json['paymentMethodId'] ?? '',
      orderDetails:
          (json['orderDetails'] as List<dynamic>?)
              ?.map((detail) => OrderDetail.fromJson(detail))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, totalAmount: $totalAmount, createdAt: $createdAt, cancelReasonId: $cancelReasonId, paymentMethodId: $paymentMethodId, orderDetails: ${orderDetails.map((d) => d.toString()).join(", ")})';
  }
}

// New models for detailed order information
class AddressModel {
  final String id;
  final bool isDefault;
  final String customerName;
  final int countryId;
  final String phoneNumber;
  final String countryName;
  final String streetNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String ward;
  final String postCode;
  final String province;

  AddressModel({
    required this.id,
    required this.isDefault,
    required this.customerName,
    required this.countryId,
    required this.phoneNumber,
    required this.countryName,
    required this.streetNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.ward,
    required this.postCode,
    required this.province,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      isDefault: json['isDefault'] ?? false,
      customerName: json['customerName'] ?? '',
      countryId: json['countryId'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      countryName: json['countryName'] ?? '',
      streetNumber: json['streetNumber'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      ward: json['ward'] ?? '',
      postCode: json['postCode'] ?? '',
      province: json['province'] ?? '',
    );
  }
}

class StatusChangeModel {
  final DateTime date;
  final String status;

  StatusChangeModel({required this.date, required this.status});

  factory StatusChangeModel.fromJson(Map<String, dynamic> json) {
    return StatusChangeModel(
      date: DateTime.parse(json['date']),
      status: json['status'] ?? '',
    );
  }
}

class OrderDetailModel {
  final String id;
  final String status;
  final double originalOrderTotal;
  final double discountedOrderTotal;
  final String? voucherCode;
  final double discountAmount;
  final String? cancelReasonId;
  final DateTime createdTime;
  final String paymentMethodId;
  final List<OrderDetail> orderDetails;
  final AddressModel address;
  final List<StatusChangeModel> statusChanges;

  OrderDetailModel({
    required this.id,
    required this.status,
    required this.originalOrderTotal,
    required this.discountedOrderTotal,
    this.voucherCode,
    required this.discountAmount,
    this.cancelReasonId,
    required this.createdTime,
    required this.paymentMethodId,
    required this.orderDetails,
    required this.address,
    required this.statusChanges,
  });

  OrderDetailModel copyWith({
    String? id,
    String? status,
    double? originalOrderTotal,
    double? discountedOrderTotal,
    String? voucherCode,
    double? discountAmount,
    String? cancelReasonId,
    DateTime? createdTime,
    String? paymentMethodId,
    List<OrderDetail>? orderDetails,
    AddressModel? address,
    List<StatusChangeModel>? statusChanges,
  }) {
    return OrderDetailModel(
      id: id ?? this.id,
      status: status ?? this.status,
      originalOrderTotal: originalOrderTotal ?? this.originalOrderTotal,
      discountedOrderTotal: discountedOrderTotal ?? this.discountedOrderTotal,
      voucherCode: voucherCode ?? this.voucherCode,
      discountAmount: discountAmount ?? this.discountAmount,
      cancelReasonId: cancelReasonId ?? this.cancelReasonId,
      createdTime: createdTime ?? this.createdTime,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      orderDetails: orderDetails ?? this.orderDetails,
      address: address ?? this.address,
      statusChanges: statusChanges ?? this.statusChanges,
    );
  }

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      originalOrderTotal: (json['originalOrderTotal'] ?? 0).toDouble(),
      discountedOrderTotal: (json['discountedOrderTotal'] ?? 0).toDouble(),
      voucherCode: json['voucherCode'],
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      cancelReasonId: json['cancelReasonId'],
      createdTime: DateTime.parse(json['createdTime']),
      paymentMethodId: json['paymentMethodId'] ?? '',
      orderDetails:
          (json['orderDetails'] as List<dynamic>?)
              ?.map((detail) => OrderDetail.fromJson(detail))
              .toList() ??
          [],
      address: AddressModel.fromJson(json['address'] ?? {}),
      statusChanges:
          (json['statusChanges'] as List<dynamic>?)
              ?.map((change) => StatusChangeModel.fromJson(change))
              .toList() ??
          [],
    );
  }
}
