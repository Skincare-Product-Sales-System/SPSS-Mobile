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
      variationOptionValues: (json['variationOptionValues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
        print('Error parsing date in OrderResponse: $dateStr');
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
      orderDetails: parseOrderDetails(json['orderDetails']),
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, totalAmount: $totalAmount, createdAt: $createdAt, cancelReasonId: $cancelReasonId, paymentMethodId: $paymentMethodId, orderDetails: ${orderDetails.map((d) => d.toString()).join(", ")})';
  }
} 