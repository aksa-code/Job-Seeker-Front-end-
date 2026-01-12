class JobModel {
  final int id;
  final String positionName;
  final String description;
  final String companyName;
  final String status;
  final String? submission_end_date;
  final int? capacity; // ← Tambahkan ini

  JobModel({
    required this.id,
    required this.positionName,
    required this.description,
    required this.companyName,
    required this.status,
    required this.submission_end_date,
    this.capacity, // ← Tambahkan ini
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      positionName: json['position_name'] ?? '',
      description: json['description'] ?? '',
      companyName: json['company']?['company_name'] ?? '',
      status: json['status'] ?? '',
      submission_end_date: json['submission_end_date'] ?? '',
      capacity: json['capacity'], 
    );
  }
}