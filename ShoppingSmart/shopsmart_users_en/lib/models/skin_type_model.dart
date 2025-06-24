class SkinTypeModel {
  final String id;
  final String name;

  SkinTypeModel({required this.id, required this.name});

  factory SkinTypeModel.fromJson(Map<String, dynamic> json) {
    return SkinTypeModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}
