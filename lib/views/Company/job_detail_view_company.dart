import 'package:flutter/material.dart';
import 'package:job_seeker/services/job/job_application_service.dart';
import 'package:job_seeker/services/job/job_service.dart';
import 'package:job_seeker/services/job/job_company_service.dart';
import 'package:job_seeker/services/portfolio_service.dart';
import 'package:job_seeker/models/portfolio_model.dart';
import 'package:job_seeker/widgets/alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_seeker/services/url.dart';

class JobDetailViewCompany extends StatefulWidget {
  final int jobId;
  const JobDetailViewCompany({super.key, required this.jobId});

  @override
  State<JobDetailViewCompany> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailViewCompany> {
  final JobApplicationService _serviceJobs = JobApplicationService();
  final JobService _service = JobService();
  final JobCompanyService _companyService = JobCompanyService();
  final PortfolioService _portfolioService = PortfolioService();
  
  bool isLoading = true;
  Map<String, dynamic>? job;
  List applicants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.getJobWithApplicants(widget.jobId);
      setState(() {
        job = data["job"];
        applicants = data["applicants"];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      context.showErrorAlert('Gagal memuat data: $e', title: 'Error');
    }
  }

  Future<void> _changeStatus(int appId, String newStatus) async {
    try {
      if (newStatus.toUpperCase() == 'ACCEPTED' && (job?["capacity"] ?? 0) <= 0) {
        if (!mounted) return;
        context.showErrorAlert('Tidak bisa menerima: Capacity sudah habis!', title: 'Capacity Penuh');
        return;
      }
      
      await _serviceJobs.updateApplicationStatus(appId, newStatus);
      
      if (!mounted) return;
      context.showSuccessAlert('Status diubah menjadi $newStatus', title: 'Success');
      await _loadData();
      
    } catch (e) {
      if (!mounted) return;
      
      if (e.toString().contains('Capacity sudah habis')) {
        context.showErrorAlert('Tidak bisa menerima: Capacity sudah habis!', title: 'Capacity Penuh');
      } else {
        context.showErrorAlert('Gagal mengubah status: $e', title: 'Error');
      }
    }
  }

  Future<void> _deleteJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Job", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus job ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteJob(widget.jobId);
      if (!mounted) return;
      
      context.showSuccessAlert('Job berhasil dihapus', title: 'Success');
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      context.showErrorAlert('Gagal menghapus job: $e', title: 'Error');
    }
  }

  Future<void> _showUpdateJobDialog() async {
    if (job == null) return;

    final positionController = TextEditingController(text: job!["position_name"]);
    final capacityController = TextEditingController(text: job!["capacity"]?.toString() ?? "");
    final descriptionController = TextEditingController(text: job!["description"]);
    final startDateController = TextEditingController(text: job!["submission_start_date"]);
    final endDateController = TextEditingController(text: job!["submission_end_date"]);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFF5F7FA),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Job",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Update job information",
                              style: TextStyle(fontSize: 13, color: Color(0xFF718096)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Position Name"),
                  const SizedBox(height: 8),
                  _buildTextField(positionController, Icons.work_outline, "UI Design"),
                  const SizedBox(height: 16),
                  _buildLabel("Capacity"),
                  const SizedBox(height: 8),
                  _buildTextField(capacityController, Icons.people_outline, "5", isNumber: true),
                  const SizedBox(height: 16),
                  _buildLabel("Description"),
                  const SizedBox(height: 8),
                  _buildTextField(descriptionController, Icons.description_outlined, "Job description...", maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Start Date"),
                            const SizedBox(height: 8),
                            _buildDateField(ctx, startDateController, Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("End Date"),
                            const SizedBox(height: 8),
                            _buildDateField(ctx, endDateController, Icons.event_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Batal", style: TextStyle(color: Color(0xFF718096), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF5B86E5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != true) return;

    try {
      final data = {
        "position_name": positionController.text,
        "capacity": int.tryParse(capacityController.text) ?? 0,
        "description": descriptionController.text,
        "submission_start_date": startDateController.text,
        "submission_end_date": endDateController.text,
      };

      await _companyService.updateJob(widget.jobId, data);
      
      if (!mounted) return;
      context.showSuccessAlert('Job berhasil diupdate', title: 'Success');
      await _loadData();
      
    } catch (e) {
      if (!mounted) return;
      context.showErrorAlert('Gagal mengupdate job: $e', title: 'Error');
    }
  }

  Future<void> _openPortfolioDirectly(int societyId, String applicantName) async {
    try {
      final portfolioData = await _portfolioService.getPortfolioBySocietyId(societyId);
      
      if (portfolioData == null) {
        if (!mounted) return;
        context.showErrorAlert('Applicant belum punya portfolio', title: 'Info');
        return;
      }
      
      if (portfolioData.fileUrl.isEmpty) {
        if (!mounted) return;
        context.showErrorAlert('Portfolio tidak memiliki file yang valid', title: 'Error');
        return;
      }
      
      String fullUrl = portfolioData.fileUrl;
      
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        final cleanPath = fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl;
        fullUrl = cleanPath.startsWith('storage/') 
            ? '$storageUrl/$cleanPath' 
            : '$storageUrl/storage/$cleanPath';
      }
      
      final Uri url = Uri.parse(fullUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        context.showSuccessAlert('Membuka portfolio $applicantName...', title: 'Success');
      } else {
        if (!mounted) return;
        context.showErrorAlert('Tidak dapat membuka URL: $fullUrl', title: 'Error');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorAlert('Gagal membuka portfolio: $e', title: 'Error');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return const Color(0xFF48BB78);
      case 'REJECTED':
        return Colors.red;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF5B86E5), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B86E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDateField(BuildContext ctx, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF5B86E5), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B86E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: ctx,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          controller.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }
      },
    );
  }

  Widget _infoRowWhite(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF2D3748)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Job Detail",
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B86E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF5B86E5)),
            ),
            tooltip: "Edit Job",
            onPressed: _showUpdateJobDialog,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            ),
            tooltip: "Hapus Job",
            onPressed: _deleteJob,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B86E5)))
          : job == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.work_off_outlined, size: 64, color: Color(0xFFCBD5E0)),
                      SizedBox(height: 16),
                      Text("Job tidak ditemukan", style: TextStyle(color: Color(0xFF718096), fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF5B86E5),
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B86E5).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.work_rounded, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Position", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        job!["position_name"] ?? "-",
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _infoRowWhite(Icons.description_outlined, "Description", job!["description"] ?? "-"),
                                  const SizedBox(height: 12),
                                  _infoRowWhite(Icons.calendar_today_outlined, "Deadline", job!["submission_end_date"] ?? "-"),
                                  const SizedBox(height: 12),
                                  _infoRowWhite(Icons.people_outline_rounded, "Capacity", "${job!["capacity"] ?? "-"} positions"),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      const Text("Status: ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: job!["status"]?.toString().toUpperCase() == 'ACTIVE' ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              job!["status"]?.toString().toUpperCase() == 'ACTIVE' ? Icons.check_circle : Icons.cancel,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              job!["status"]?.toString().toUpperCase() ?? '-',
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Applicants",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                              ),
                              if (job != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      job!["capacity"] > 0 ? Icons.people : Icons.block,
                                      size: 14,
                                      color: job!["capacity"] > 0 ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      job!["capacity"] > 0 ? "Sisa ${job!["capacity"]} posisi" : "Capacity penuh",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: job!["capacity"] > 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B86E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${applicants.length} applicant${applicants.length != 1 ? 's' : ''}",
                              style: const TextStyle(color: Color(0xFF5B86E5), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (applicants.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: const [
                              Icon(Icons.people_outline, size: 64, color: Color(0xFFCBD5E0)),
                              SizedBox(height: 16),
                              Text("Belum ada pelamar", style: TextStyle(color: Color(0xFF718096), fontSize: 16)),
                            ],
                          ),
                        )
                      else
                        ...applicants.map((a) {
                          final status = a["status"] ?? "PENDING";
                          final societyId = a["society"]?["id"];
                          final applicantName = a["society"]?["user"]?["name"] ?? "-";
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B86E5).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.person_outline, color: Color(0xFF5B86E5), size: 24),
                                  ),
                                  title: Text(
                                    applicantName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 16),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
                                        const SizedBox(width: 6),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FA),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.more_vert, color: Color(0xFF2D3748), size: 20),
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (value) => _changeStatus(a["id"], value),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "ACCEPTED",
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Color(0xFF48BB78), size: 20),
                                            SizedBox(width: 12),
                                            Text("Terima"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: "REJECTED",
                                        child: Row(
                                          children: [
                                            Icon(Icons.cancel, color: Colors.red, size: 20),
                                            SizedBox(width: 12),
                                            Text("Tolak"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (societyId != null)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openPortfolioDirectly(societyId, applicantName),
                                        icon: const Icon(Icons.open_in_browser_outlined, size: 18),
                                        label: const Text('Lihat Portfolio'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF5B86E5),
                                          side: const BorderSide(color: Color(0xFF5B86E5), width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}