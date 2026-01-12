import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Cukup satu ini
import 'package:http/http.dart' as http;
import 'package:job_seeker/models/portfolio_model.dart';
import 'package:job_seeker/services/url.dart';
import 'package:job_seeker/services/user_local_service.dart';

class PortfolioService {
  Future<void> addPortfolio({
    required String skill,
    String? description,
    File? file, // mobile/desktop
    Uint8List? bytes, // web
    required String filename,
  }) async {
    final token = await UserLocalService.getToken();

    final uri = Uri.parse('$baseUrl/portfolio');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['skill'] = skill;
    if (description != null) {
      request.fields['description'] = description;
    }

    if (kIsWeb) {
      // ✅ Web: pakai bytes
      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ));
      }
    } else {
      // ✅ Mobile/Desktop: pakai path
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
        ));
      }
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload gagal. Code: ${response.statusCode}');
    }
  }

  Future<PortfolioModel?> getPortfolio() async {
    final token = await UserLocalService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/portfolio'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body['status'] == true && body['data'] != null) {
        return PortfolioModel.fromJson(body['data']); // ✅ langsung ambil object
      } else {
        return null;
      }
    } else {
      throw Exception('Gagal ambil portfolio: ${response.body}');
    }
  }

  Future<PortfolioModel?> getPortfolioBySocietyId(int societyId) async {
  final token = await UserLocalService.getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/portfolio/society/$societyId'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('🔍 API URL: $baseUrl/portfolio/society/$societyId');
  print('🔍 Status Code: ${response.statusCode}');
  print('🔍 Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    
    print('🔍 Body Status: ${body['status']}');
    print('🔍 Body Data: ${body['data']}');

    if (body['status'] == true && body['data'] != null) {
      // Cek apakah data adalah List atau Object
      if (body['data'] is List) {
        // Jika List, ambil item pertama
        final List dataList = body['data'];
        print('🔍 Data adalah List dengan ${dataList.length} item');
        
        if (dataList.isNotEmpty) {
          print('🔍 Item pertama: ${dataList[0]}');
          print('🔍 file_url dari item pertama: ${dataList[0]['file_url']}');
          print('🔍 file dari item pertama: ${dataList[0]['file']}');
          
          // ✅ PERBAIKAN MANUAL: Rename 'file' ke 'file_url' sebelum parsing
          if (dataList[0]['file'] != null && dataList[0]['file_url'] == null) {
            dataList[0]['file_url'] = dataList[0]['file'];
            print('✅ Berhasil rename field file -> file_url: ${dataList[0]['file_url']}');
          }
          
          return PortfolioModel.fromJson(dataList[0]);
        } else {
          print('❌ List kosong');
          return null; // List kosong = belum ada portfolio
        }
      } else {
        // Jika Object, langsung parse
        print('🔍 Data adalah Object: ${body['data']}');
        print('🔍 file_url dari object: ${body['data']['file_url']}');
        print('🔍 file dari object: ${body['data']['file']}');
        
        // ✅ PERBAIKAN MANUAL: Rename 'file' ke 'file_url' sebelum parsing
        if (body['data']['file'] != null && body['data']['file_url'] == null) {
          body['data']['file_url'] = body['data']['file'];
          print('✅ Berhasil rename field file -> file_url: ${body['data']['file_url']}');
        }
        
        return PortfolioModel.fromJson(body['data']);
      }
    } else {
      print('❌ Status false atau data null');
      return null; // Society belum punya portfolio
    }
  } else if (response.statusCode == 404) {
    print('❌ 404 - Portfolio tidak ditemukan');
    // Portfolio tidak ditemukan
    return null;
  } else {
    print('❌ Error: ${response.statusCode} - ${response.body}');
    throw Exception('Gagal ambil portfolio: ${response.body}');
  }
}

  Future<void> deletePortfolio(int id) async {
    final token = await UserLocalService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/portfolio'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus portfolio: ${response.body}");
    }
  }
}
