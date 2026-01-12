class RegisterModel {
  bool? status;
  dynamic message; // bisa String atau Map kalau gagal validasi
  int? id;
  String? name;
  String? email;
  String? role;

  RegisterModel({
    this.status,
    this.message,
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
  return RegisterModel(
    status: json['status'],
    message: json['message'],
    id: json['data']?['id'] ?? json['company']?['id'],
    name: json['data']?['name'] ?? json['company']?['company_name'],
    email: json['data']?['email'], // company ga ada email
    role: json['data']?['role'],   // company ga ada role
  );
}

}
