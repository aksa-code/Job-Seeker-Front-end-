import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_seeker/models/job_model.dart';
import 'package:job_seeker/services/user_local_service.dart';
import 'package:job_seeker/services/url.dart';

class JobService {
  /// 🔹 Tambah lowongan baru (Company)
  Future<bool> addJob({
    required String positionName,
    required int capacity,
    required String description,
    required String submissionStartDate,
    required String submissionEndDate,
  }) async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs");
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {
        'position_name': positionName,
        'capacity': capacity.toString(),
        'description': description,
        'submission_start_date': submissionStartDate,
        'submission_end_date': submissionEndDate,
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }

    try {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal menambahkan job');
    } catch (_) {
      throw Exception('Gagal menambahkan job (${res.statusCode})');
    }
  }

  /// 🔹 Ambil job milik company
  Future<List<JobModel>> getCompanyJobs() async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/company");
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.reasonPhrase}");
    }

    final decoded = json.decode(res.body);
    if (decoded['status'] == true && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => JobModel.fromJson(e))
          .toList();
    }

    throw Exception("Format JSON tidak sesuai");
  }

  /// 🔹 Ambil semua lowongan aktif
  Future<List<JobModel>> getActiveJobs() async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/active");
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
      final list = decoded['data'] as List;
      return list.map((e) => JobModel.fromJson(e)).toList();
    }

    throw Exception("Format JSON tidak sesuai: ${res.body}");
  }

  /// 🔹 Total semua job
  Future<int> getTotalJobs() async {
    final token = await UserLocalService.getToken();
    final uri = Uri.parse('$baseUrl/jobs/total');

    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print('Request URL: $uri');
    print('Status Code: ${res.statusCode}');
    print('Response: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['total'] ?? 0;
    } else {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }
  }

  /// 🔹 Ambil job dan daftar pelamarnya
  Future<Map<String, dynamic>> getJobWithApplicants(int jobId) async {
    final token = await UserLocalService.getToken();
    final jobUri = Uri.parse("$baseUrl/jobs/$jobId");
    final applicantsUri = Uri.parse("$baseUrl/jobs/$jobId/applicants");

    final jobRes = await http.get(jobUri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final applicantsRes = await http.get(applicantsUri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (jobRes.statusCode != 200 || applicantsRes.statusCode != 200) {
      throw Exception("Gagal memuat detail pekerjaan");
    }

    final jobData = jsonDecode(jobRes.body);
    final applicantsData = jsonDecode(applicantsRes.body);

    return {
      "job": jobData["data"],
      "applicants": applicantsData["data"],
    };
  }

  /// 🔹 Hapus job
  Future<void> deleteJob(int jobId) async {
    final token = await UserLocalService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final uri = Uri.parse("$baseUrl/jobs/$jobId");
    final res = await http.delete(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception("Gagal menghapus job (${res.statusCode})");
    }
  }

  /// 🔹 Ambil detail 1 job
  Future<JobModel> getJobDetail(int jobId) async {
    final token = await UserLocalService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan. Harap login ulang.");
    }

    final uri = Uri.parse("$baseUrl/jobs/$jobId");
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
    if (decoded is Map && decoded['data'] is Map) {
      return JobModel.fromJson(decoded['data']);
    }

    throw Exception("Format JSON tidak sesuai: ${res.body}");
  }
}
