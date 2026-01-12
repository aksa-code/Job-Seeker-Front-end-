import 'package:flutter/material.dart';
import 'package:job_seeker/controllers/company_dashboard_controller.dart';
import 'package:job_seeker/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class CompanyDashboardView extends StatefulWidget {
  const CompanyDashboardView({super.key});

  @override
  State<CompanyDashboardView> createState() => _CompanyDashboardViewState();
}

class _CompanyDashboardViewState extends State<CompanyDashboardView> {
  Timer? _autoRefreshTimer;
  CompanyDashboardController? _controller;

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        _controller?.refreshData();
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = CompanyDashboardController()..fetchDashboardData();
        _controller = controller;
        
        // Start auto refresh setelah controller siap
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoRefresh();
        });
        
        return controller;
      },
      child: Consumer<CompanyDashboardController>(
        builder: (context, c, _) => DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFE8EDF5),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFFE8EDF5),
              toolbarHeight: 80,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: Color(0xFF8E93A6),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.companyName ?? "Company Dashboard",
                      style: const TextStyle(
                        color: Color(0xFF1A1D3D),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/CompanyProfile');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4E73FF),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: c.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4E73FF),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // === IMPROVED CARD SECTION ===
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _cardTotalJobs(c.totalJobs),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: _actionButton(
                                context,
                                icon: Icons.add_circle_outline,
                                label: "Add Job",
                                color: const Color(0xFF4E73FF),
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                      context, '/addJob');

                                  if (result == true) {
                                    await c.refreshData();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === TAB BAR ===
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: const Color(0xFF4E73FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF8E93A6),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: "Active Jobs"),
                            Tab(text: "Inactive Jobs"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === TAB CONTENT ===
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildJobList(context, c, true), // Active
                            _buildJobList(context, c, false), // Inactive
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: BottomNav(0),
          ),
        ),
      ),
    );
  }

  // === Improved Total Jobs Card ===
  Widget _cardTotalJobs(int total) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B8FFF), Color(0xFF4E73FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E73FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Jobs Positions",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$total",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      );

  // === Action Button ===
  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // === Job List ===
  Widget _buildJobList(
      BuildContext context, CompanyDashboardController c, bool isActive) {
    final jobs = isActive
        ? c.jobs.where((job) => job.status == "active").toList()
        : c.jobs.where((job) => job.status == "off").toList();

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4E73FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.work_off_outlined : Icons.block_outlined,
                size: 48,
                color: const Color(0xFF4E73FF).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? "No active jobs yet" : "No inactive jobs",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D3D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive ? "Start by adding a new job" : "All jobs are active",
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8E93A6).withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4E73FF),
      onRefresh: () async => c.fetchDashboardData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: jobs.length,
        itemBuilder: (context, i) {
          final job = jobs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/jobDetail',
                    arguments: job.id,
                  );

                  // Auto reload jika job dihapus atau ada perubahan
                  if (result == true) {
                    await c.refreshData();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF4E73FF).withOpacity(0.1)
                              : const Color(0xFFFF5C5C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isActive
                              ? Icons.work_outline_rounded
                              : Icons.block_rounded,
                          color: isActive
                              ? const Color(0xFF4E73FF)
                              : const Color(0xFFFF5C5C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.positionName ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A1D3D),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color:
                                      const Color(0xFF8E93A6).withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Deadline: ${job.submission_end_date ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF8E93A6)
                                          .withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 14,
                                  color:
                                      const Color(0xFF8E93A6).withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Capacity: ${job.capacity ?? '-'} positions",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF8E93A6)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : const Color(0xFFFF5C5C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                job.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFFF5C5C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E73FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF4E73FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}