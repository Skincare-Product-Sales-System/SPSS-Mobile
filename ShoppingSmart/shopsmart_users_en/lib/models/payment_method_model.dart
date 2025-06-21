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
      id: json['id']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'paymentType': paymentType, 'imageUrl': imageUrl};
  }

  Map<String, dynamic> toMap() => toJson();

  // Getters for backward compatibility
  String get name => paymentType;
  String get description => 'Payment method: $paymentType';
}
