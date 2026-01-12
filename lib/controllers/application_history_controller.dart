import 'package:flutter/material.dart';
import 'package:job_seeker/services/job/job_application_service.dart';

class ApplicationHistoryController extends ChangeNotifier {
  final JobApplicationService jobApplicationService = JobApplicationService();

  bool isLoading = false;
  List<dynamic> history = [];

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await jobApplicationService.getApplicationHistory();
      history = data;
      
      // Sort by apply_date descending (newest first)
      history.sort((a, b) {
        final dateA = a['apply_date'] ?? '';
        final dateB = b['apply_date'] ?? '';
        return dateB.toString().compareTo(dateA.toString());
      });
    } catch (e) {
      debugPrint("❌ Gagal memuat riwayat lamaran: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
