import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_seeker/services/user_local_service.dart';
import 'package:job_seeker/services/url.dart';
import 'package:job_seeker/models/company_model.dart';

class JobProfileService {
  Future<Map<String, dynamic>> getSocietyProfile() async {
    final token = await UserLocalService.getToken();
    final uri = Uri.parse("$baseUrl/society/profile/data");
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    final decoded = json.decode(res.body);
    if (decoded['status'] == true) {
      return {
        "name": decoded["user"]["name"],
        "email": decoded["user"]["email"],
        "address": decoded["society"]["address"],
        "phone": decoded["society"]["phone"],
        "date_of_birth": decoded["society"]["date_of_birth"],
        "gender": decoded["society"]["gender"],
      };
    }
    throw Exception("Format data tidak sesuai");
  }

  Future<bool> saveProfile({
    required String name,
    required String address,
    required String phone,
    required String dateOfBirth,
    required String gender,
  }) async {
    final token = await UserLocalService.getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/society/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': name,
        'address': address,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) return true;
    throw Exception('Gagal menyimpan profile: ${res.body}');
  }

  Future<CompanyModel> getCompanyProfile() async {
    final token = await UserLocalService.getToken();
    final uri = Uri.parse("$baseUrl/company/profile/data");

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    final decoded = json.decode(res.body);
    return CompanyModel.fromJson(decoded);
  }

  Future<bool> saveCompanyProfile({
    required String companyName,
    required String address,
    required String phone,
    required String description,
  }) async {
    final token = await UserLocalService.getToken();
    final uri = Uri.parse('$baseUrl/company/profile');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'company_name': companyName,
        'address': address,
        'phone': phone,
        'description': description,
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) return true;

    throw Exception('Gagal menyimpan profil: ${res.body}');
  }
}
