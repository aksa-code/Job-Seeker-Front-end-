import 'user_model.dart';

class CompanyModel {
  final bool status;
  final User user;
  final Company company;
  final String message; // New field for message

  CompanyModel({
    required this.status,
    required this.user,
    required this.company,
    required this.message, // Include message in the constructor
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      status: json['status'] ?? false,
      user: User.fromJson(json['user']),
      company: Company.fromJson(json['company']),
      message: json['message'] ?? '', // Add the message field to the JSON parsing
    );
  }
}

class Company {
  final int id;
  final String companyName;
  final String address;
  final String phone;
  final String description;

  Company({
    required this.id,
    required this.companyName,
    required this.address,
    required this.phone,
    required this.description,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      companyName: json['company_name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
    );
  }
}