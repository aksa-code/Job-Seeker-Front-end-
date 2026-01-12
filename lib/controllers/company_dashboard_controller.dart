import 'package:flutter/material.dart';
import 'package:job_seeker/models/job_model.dart';
import 'package:job_seeker/services/job/job_application_service.dart';
import 'package:job_seeker/services/job/job_company_service.dart';
import 'package:job_seeker/services/job/job_service.dart';
import 'package:job_seeker/services/user_local_service.dart';

class CompanyDashboardController extends ChangeNotifier {
  final JobCompanyService companyService = JobCompanyService();
  final JobApplicationService applicationService = JobApplicationService();
  final JobService jobService = JobService();

  List<JobModel> jobs = [];
  List<JobModel> get filteredJobs => jobs
      .where(
          (job) => (job.positionName ?? '').toLowerCase().contains(searchQuery))
      .toList();

  List applicants = [];
  int totalJobs = 0;
  String searchQuery = "";
  bool isLoading = false;
  
  // ✅ Tambahan untuk company name
  String? companyName;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Ambil company name dari API/local storage
      await _loadCompanyName();
      
      final companyJobs = await companyService.getCompanyJobs();
      totalJobs = await jobService.getTotalJobs();

      jobs = companyJobs;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Method untuk load company name dari API
  Future<void> _loadCompanyName() async {
    try {
      // Ambil company profile dari API
      final companyProfile = await companyService.getCompanyProfile();
      
      // Debug: Print response untuk lihat struktur
      debugPrint("=== COMPANY PROFILE RESPONSE ===");
      debugPrint(companyProfile.toString());
      
      // Ambil company_name dari response.company
      companyName = companyProfile['company']?['company_name'];
      
      debugPrint("Company name loaded from API: $companyName");
      
      // Jika masih null, fallback ke user name
      if (companyName == null || companyName!.isEmpty) {
        companyName = await UserLocalService.getName();
        debugPrint("Using user name as fallback: $companyName");
      }
      
      // Jika tetap null, set default
      if (companyName == null || companyName!.isEmpty) {
        companyName = "Company Dashboard";
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading company name: $e");
      // Fallback ke user name jika API error
      companyName = await UserLocalService.getName() ?? "Company Dashboard";
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    searchQuery = value.toLowerCase();
    notifyListeners();
  }

  // Method untuk refresh data (dipanggil setelah add job)
  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  Future<void> fetchApplicants(int jobId) async {
    try {
      applicants = await applicationService.getApplicants(jobId);
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal fetch applicants: $e");
    }
  }
}