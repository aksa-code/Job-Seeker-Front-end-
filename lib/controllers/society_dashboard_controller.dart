import 'package:flutter/material.dart';
import 'package:job_seeker/models/job_model.dart';
import 'package:job_seeker/services/job/job_service.dart';

class SocietyDashboardController extends ChangeNotifier {
  final JobService jobService = JobService();

  List<JobModel> jobs = [];
  List<JobModel> filteredJobs = [];
  bool isLoading = false;

  Future<void> fetchJobs() async {
    isLoading = true;
    notifyListeners();

    try {
      final loadedJobs = await jobService.getActiveJobs();
      jobs = loadedJobs;
      filteredJobs = loadedJobs;
    } catch (e) {
      debugPrint("❌ Error fetch jobs: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterJobs(String query) {
    final q = query.toLowerCase();
    filteredJobs = jobs.where((job) {
      final pos = job.positionName?.toLowerCase() ?? '';
      final comp = job.companyName?.toLowerCase() ?? '';
      return pos.contains(q) || comp.contains(q);
    }).toList();
    notifyListeners();
  }
}
