import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_local_service.dart';
import 'user_model.dart';

class LoginModel {
  final bool status;
  final String message;
  final String? token;
  final String? role;
  final User? user;

  LoginModel({
    required this.status,
    required this.message,
    this.token,
    this.role,
    this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token']?.toString(),
      role: json['role']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  factory LoginModel.failure(String message) {
    return LoginModel(
      status: false,
      message: message,
    );
  }

  /// 🔹 Simpan token, role, user id, name & email ke SharedPreferences
  Future<void> savePrefs() async {
    if (token != null) await UserLocalService.saveToken(token!);
    if (role != null) await UserLocalService.saveRole(role!);
    if (user?.id != null) await UserLocalService.saveUserId(user!.id!);
    if (user?.name != null) await UserLocalService.saveName(user!.name!);
    if (user?.email != null) await UserLocalService.saveEmail(user!.email!);
  }
}