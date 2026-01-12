import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_seeker/models/job_model.dart';
import 'package:job_seeker/services/user_local_service.dart';
import 'package:job_seeker/services/url.dart';

class JobCompanyService {
  Future<Map<String, dynamic>> getCompanyProfile() async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/company/profile/data");
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
    
    // Return data company
    if (decoded['status'] == true) {
      return decoded['data'] ?? decoded; // Sesuaikan dengan struktur response
    }

    throw Exception("Format JSON tidak sesuai: ${res.body}");
  }

  Future<List<JobModel>> getCompanyJobs() async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/company");
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
    if (decoded['status'] == true && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => JobModel.fromJson(e))
          .toList();
    }

    throw Exception("Format JSON tidak sesuai: ${res.body}");
  }

  Future<void> deleteJob(int jobId) async {
    final token = await UserLocalService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final uri = Uri.parse("$baseUrl/jobs/$jobId");
    final res = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal menghapus job (${res.statusCode})");
    }
  }

  /// Update existing job
  /// 
  /// Parameters:
  /// - jobId: ID of the job to update
  /// - data: Map containing job data (position_name, capacity, description, submission_start_date, submission_end_date)
  /// 
  /// Returns: Updated job data
  Future<Map<String, dynamic>> updateJob(int jobId, Map<String, dynamic> data) async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/$jobId");
    final res = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    // Handle validation errors (422)
    if (res.statusCode == 422) {
      final decoded = json.decode(res.body);
      if (decoded['errors'] != null) {
        final errors = decoded['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final errorMessage = firstError is List ? firstError.first : firstError;
        throw Exception(errorMessage);
      }
      throw Exception(decoded['message'] ?? 'Validasi gagal');
    }

    // Handle other errors
    if (res.statusCode != 200) {
      final decoded = json.decode(res.body);
      throw Exception(decoded['message'] ?? "HTTP ${res.statusCode}: ${res.reasonPhrase}");
    }

    final decoded = json.decode(res.body);
    
    if (decoded['status'] == true) {
      return decoded['data'];
    }

    throw Exception(decoded['message'] ?? "Gagal memperbarui job");
  }
}