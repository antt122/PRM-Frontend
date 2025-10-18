// Model để đóng gói dữ liệu gửi đi khi tạo mới
class PaymentMethodCreateModel {
  final String name;
  final String? description;
  final int type;
  final String providerName;
  final String? configuration;
  final int status;

  PaymentMethodCreateModel({
    required this.name,
    this.description,
    required this.type,
    required this.providerName,
    this.configuration,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'providerName': providerName,
      'configuration': configuration,
      'status': status,
    };
  }
}
