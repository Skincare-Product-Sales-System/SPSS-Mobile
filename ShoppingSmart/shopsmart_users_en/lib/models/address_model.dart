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
} 