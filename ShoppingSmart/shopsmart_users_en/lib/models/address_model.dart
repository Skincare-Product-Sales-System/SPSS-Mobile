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
      id: json['id'],
      isDefault: json['isDefault'],
      customerName: json['customerName'],
      countryId: json['countryId'],
      phoneNumber: json['phoneNumber'],
      countryName: json['countryName'],
      streetNumber: json['streetNumber'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      ward: json['ward'],
      postCode: json['postCode'],
      province: json['province'],
    );
  }
} 