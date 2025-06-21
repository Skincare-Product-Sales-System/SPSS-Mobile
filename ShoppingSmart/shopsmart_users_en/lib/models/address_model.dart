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
      id: json['id']?.toString() ?? '',
      isDefault: json['isDefault'] ?? false,
      customerName: json['customerName']?.toString() ?? '',
      countryId: json['countryId'] ?? 0,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      streetNumber: json['streetNumber']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      ward: json['ward']?.toString() ?? '',
      postCode: json['postCode']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isDefault': isDefault,
      'customerName': customerName,
      'countryId': countryId,
      'phoneNumber': phoneNumber,
      'countryName': countryName,
      'streetNumber': streetNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'ward': ward,
      'postCode': postCode,
      'province': province,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  // Getter for backward compatibility
  String get address {
    final parts =
        [
          streetNumber,
          addressLine1,
          addressLine2,
          ward,
          city,
          province,
          countryName,
        ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  // Getter for backward compatibility
  String? get note =>
      null; // No note field in the current model, returning null for compatibility
}
