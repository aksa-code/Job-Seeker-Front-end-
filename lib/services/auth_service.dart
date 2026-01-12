import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_seeker/models/company_model.dart';
import 'package:job_seeker/models/society_model.dart';
import 'package:job_seeker/services/url.dart';
import '../models/register_model.dart';
import 'user_local_service.dart';
import '../models/login_model.dart';

class RegisterService {
  // === HELPER: GET TOKEN ===
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // === HELPER: SAVE TOKEN ===
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('✅ Token saved');
  }

  // === HELPER: CLEAR TOKEN ===
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('✅ Token cleared');
  }

  // === REGISTER USER ===
  Future<RegisterModel> registerUser(Map<String, dynamic> data) async {
    var uri = Uri.parse("$baseUrl/register");

    try {
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      print('📥 Register Response Status: ${response.statusCode}');
      print('📥 Register Response Body: ${response.body}');

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == true) {
        // Simpan user_id ke SharedPreferences
        final userId = jsonData['data']['id'];
        await UserLocalService.saveUserId(userId);
        print('✅ User ID saved: $userId');

        return RegisterModel.fromJson(jsonData);
      } else {
        return RegisterModel(
          status: false,
          message: jsonData['message'] ?? "Register gagal: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('❌ Error in registerUser: $e');
      return RegisterModel(status: false, message: "Error koneksi: $e");
    }
  }

  // === LOGIN USER ===
  Future<LoginModel> loginUser(Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );

      print("📥 Login Response Status: ${response.statusCode}");
      print("📥 Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Simpan token ke SharedPreferences
        if (jsonData['token'] != null) {
          await saveToken(jsonData['token']);
        }

        // Simpan user_id jika ada
        if (jsonData['user'] != null && jsonData['user']['id'] != null) {
          await UserLocalService.saveUserId(jsonData['user']['id']);
          print('✅ User ID saved: ${jsonData['user']['id']}');
        }

        return LoginModel.fromJson(jsonData);
      } else {
        try {
          final body = json.decode(response.body);
          final message = body['message'] ?? 'Login gagal';
          return LoginModel.failure(message);
        } catch (e) {
          return LoginModel.failure(
              "Login gagal: ${response.statusCode} ${response.reasonPhrase}");
        }
      }
    } catch (e) {
      print("❌ Error login (exception): $e");
      return LoginModel.failure("Error login: $e");
    }
  }

  // === LOGOUT USER ===
  Future<Map<String, dynamic>> logoutUser() async {
    final uri = Uri.parse("$baseUrl/logout");

    try {
      final token = await getToken();
      if (token == null) {
        // Sudah tidak ada token, langsung clear local storage
        await _clearLocalData();
        return {'status': true, 'message': 'Logout berhasil'};
      }

      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📥 Logout Response Status: ${response.statusCode}");
      print("📥 Logout Response Body: ${response.body}");

      // Clear local data regardless of response
      await _clearLocalData();

      if (response.statusCode == 200) {
        return {'status': true, 'message': 'Logout berhasil'};
      } else {
        return {'status': true, 'message': 'Logout berhasil (local)'}; // Tetap berhasil karena data lokal sudah dihapus
      }
    } catch (e) {
      print("❌ Error logout: $e");
      // Clear local data even on error
      await _clearLocalData();
      return {'status': true, 'message': 'Logout berhasil (local)'};
    }
  }

  // Helper untuk clear local data
  Future<void> _clearLocalData() async {
    await clearToken();
    await UserLocalService.clearUserId();
    print('✅ All local data cleared');
  }

  // === REGISTER COMPANY (juga untuk UPDATE) ===
  Future<CompanyModel> registerCompany(Map<String, dynamic> data) async {
    var uri = Uri.parse("$baseUrl/company/profile");

    try {
      final userId = await UserLocalService.getUserId();
      if (userId == null) {
        throw Exception("User ID not found. Harap login ulang.");
      }

      data['user_id'] = userId.toString();

      print('📤 Sending company data: $data');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      print('📥 Company Response Status: ${response.statusCode}');
      print('📥 Company Response Body: ${response.body}');

      var jsonData = json.decode(response.body);
      return CompanyModel.fromJson(jsonData);
    } catch (e) {
      print('❌ Error in registerCompany: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // === GET COMPANY PROFILE (untuk edit mode) ===
  Future<CompanyModel> getCompanyProfile() async {
    var uri = Uri.parse("$baseUrl/company/profile");

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token not found. Please login again.");
      }

      print('📤 Fetching company profile with token');

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Get Company Profile Status: ${response.statusCode}');
      print('📥 Get Company Profile Body: ${response.body}');

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return CompanyModel.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to load company profile');
      }
    } catch (e) {
      print('❌ Error in getCompanyProfile: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // === REGISTER SOCIETY (juga untuk UPDATE) ===
  Future<SocietyModel> registerSociety(Map<String, dynamic> data) async {
    var uri = Uri.parse("$baseUrl/society/profile");

    try {
      final userId = await UserLocalService.getUserId();
      if (userId == null) {
        throw Exception("User ID not found. Harap Daftar ulang.");
      }

      data['user_id'] = userId.toString();

      print('📤 Sending society data: $data');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      print('📥 Society Response Status: ${response.statusCode}');
      print('📥 Society Response Body: ${response.body}');

      var jsonData = json.decode(response.body);
      return SocietyModel.fromJson(jsonData);
    } catch (e) {
      print('❌ Error in registerSociety: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // === GET SOCIETY PROFILE (untuk edit mode) ===
  Future<SocietyModel> getSocietyProfile() async {
    var uri = Uri.parse("$baseUrl/society/profile");

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token not found. Please login again.");
      }

      print('📤 Fetching society profile with token');

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Get Society Profile Status: ${response.statusCode}');
      print('📥 Get Society Profile Body: ${response.body}');

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return SocietyModel.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to load society profile');
      }
    } catch (e) {
      print('❌ Error in getSocietyProfile: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}