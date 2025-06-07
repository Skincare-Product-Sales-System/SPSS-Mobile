class PaymentMethodModel {
  final String id;
  final String paymentType;
  final String imageUrl;

  PaymentMethodModel({
    required this.id,
    required this.paymentType,
    required this.imageUrl,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      paymentType: json['paymentType'],
      imageUrl: json['imageUrl'],
    );
  }
} 