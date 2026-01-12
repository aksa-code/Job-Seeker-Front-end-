class SocietyModel {
  final bool? status;
  final String? message;
  final SocietyData? society;

  SocietyModel({
    this.status,
    this.message,
    this.society,
  });

  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    return SocietyModel(
      status: json['status'],
      message: json['message'],
      society: json['society'] != null ? SocietyData.fromJson(json['society']) : null,
    );
  }
}

class SocietyData {
  final int? id;
  final String? name;
  final String? email;
  final String? address;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final int? userId;

  SocietyData({
    this.id,
    this.name,
    this.email,
    this.address,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.userId,
  });

  factory SocietyData.fromJson(Map<String, dynamic> json) {
    return SocietyData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      userId: json['user_id'],
    );
  }
}
