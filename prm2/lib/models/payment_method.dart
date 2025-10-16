
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String providerName;
  final int type;
  final String typeName;
  final String status; // <-- THÊM MỚI

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.providerName,
    required this.type,
    required this.typeName,
    required this.status, // <-- THÊM MỚI
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      providerName: json['providerName'] as String,
      type: json['type'] as int,
      typeName: json['typeName'] as String,
      status: json['status'] as String, // <-- THÊM MỚI
    );
  }
}
