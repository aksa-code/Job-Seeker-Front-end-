import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_seeker/services/user_local_service.dart';
import 'package:job_seeker/services/url.dart';

class JobApplicationService {
  Future<Map<String, dynamic>> updateApplicationStatus(
      int id, String newStatus) async {
    final token = await UserLocalService.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    // ✅ Convert status ke UPPERCASE sesuai backend (PENDING, ACCEPTED, REJECTED)
    final statusUpperCase = newStatus.toUpperCase();
    
    final uri = Uri.parse("$baseUrl/applications/$id");
    final res = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded', // ✅ Tambahkan content type
      },
      body: {'status': statusUpperCase}, // ✅ Kirim dalam uppercase
    );

    if (res.statusCode == 404) {
      throw Exception("Lamaran tidak ditemukan");
    }

    if (res.statusCode == 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal mengubah status');
    }

    if (res.statusCode != 200) {
      throw Exception("Gagal mengubah status lamaran (HTTP ${res.statusCode})");
    }

    // ✅ Parse dan return response data
    final responseData = jsonDecode(res.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<List<dynamic>> getApplicationHistory() async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/applications/history");
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.reasonPhrase}");
    }

    final decoded = json.decode(res.body);
    if (decoded is Map && decoded['data'] is List) {
      return decoded['data'];
    }
    throw Exception("Format JSON tidak sesuai: ${res.body}");
  }

  Future<List<dynamic>> getApplicants(int jobId) async {
    final token = await UserLocalService.getToken();
    
    final res = await http.get(
      Uri.parse("$baseUrl/positionApplied?job_id=$jobId"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (res.statusCode != 200) throw Exception("Failed to fetch applicants");
    
    final jsonData = json.decode(res.body);
    return jsonData['data'] ?? [];
  }

  Future<bool> applyJob(int jobId) async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/$jobId/apply");
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (res.statusCode == 200 || res.statusCode == 201) return true;

    if (res.statusCode == 401) {
      throw Exception("Unauthorized. Harap login ulang.");
    }

    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Gagal apply');
  }
}