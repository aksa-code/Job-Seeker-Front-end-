import 'package:job_seeker/services/url.dart'; // Import baseUrl

class PortfolioModel {
  final int id;
  final String skill;
  final String? description;
  final String file;
  final String fileUrl;
  final int societyId;

  PortfolioModel({
    required this.id,
    required this.skill,
    this.description,
    required this.file,
    required this.fileUrl,
    required this.societyId,
  });

  // ✅ Getter untuk mendapatkan full URL
  String get fullFileUrl {
    // Jika sudah ada http/https, return as is
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    // Jika relative path, tambahkan baseUrl
    // Hapus leading slash jika ada di fileUrl
    final cleanPath = fileUrl.startsWith('/') ? fileUrl.substring(1) : fileUrl;
    return '$baseUrl/$cleanPath';
  }

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] ?? 0,
      skill: json['skill']?.toString() ?? 'No Skill',
      description: json['description']?.toString(),
      file: json['file']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      societyId: json['society_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill': skill,
      'description': description,
      'file': file,
      'file_url': fileUrl,
      'society_id': societyId,
    };
  }
}