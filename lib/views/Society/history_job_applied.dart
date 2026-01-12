import 'package:flutter/material.dart';
import 'package:job_seeker/controllers/application_history_controller.dart';
import 'package:job_seeker/widgets/bottom_nav.dart';
import 'package:job_seeker/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class ApplicationHistoryView extends StatefulWidget {
  const ApplicationHistoryView({super.key});

  @override
  State<ApplicationHistoryView> createState() => _ApplicationHistoryViewState();
}

class _ApplicationHistoryViewState extends State<ApplicationHistoryView> {
  // ✅ Filter state: 'ALL', 'ACCEPTED', 'REJECTED'
  String _selectedFilter = 'ALL';

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

  // ✅ Filter history berdasarkan status
  List<dynamic> _getFilteredHistory(List<dynamic> history) {
    if (_selectedFilter == 'ALL') {
      return history;
    }
    return history.where((item) {
      final status = (item['status'] ?? '').toString().toUpperCase();
      return status == _selectedFilter;
    }).toList();
  }

  // ✅ Get count by status
  int _getCountByStatus(List<dynamic> history, String status) {
    if (status == 'ALL') return history.length;
    return history.where((item) {
      final itemStatus = (item['status'] ?? '').toString().toUpperCase();
      return itemStatus == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApplicationHistoryController()..fetchHistory(),
      child: Consumer<ApplicationHistoryController>(
        builder: (context, controller, _) {
          final filteredHistory = _getFilteredHistory(controller.history);

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: const CustomAppBar(
              title: "Application History",
            ),
            body: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5B86E5)),
                  )
                : controller.history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.history_outlined,
                              size: 64,
                              color: Color(0xFFCBD5E0),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Belum ada lamaran",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section with Filters
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Applications',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildFilterChip(
                                      label: 'All',
                                      count: _getCountByStatus(
                                          controller.history, 'ALL'),
                                      isSelected: _selectedFilter == 'ALL',
                                      onTap: () =>
                                          setState(() => _selectedFilter = 'ALL'),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(
                                      label: 'Accepted',
                                      count: _getCountByStatus(
                                          controller.history, 'ACCEPTED'),
                                      isSelected: _selectedFilter == 'ACCEPTED',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'ACCEPTED'),
                                      color: const Color(0xFF48BB78),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(
                                      label: 'Rejected',
                                      count: _getCountByStatus(
                                          controller.history, 'REJECTED'),
                                      isSelected: _selectedFilter == 'REJECTED',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'REJECTED'),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // List Section
                          Expanded(
                            child: filteredHistory.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _selectedFilter == 'ACCEPTED'
                                              ? Icons.check_circle_outline
                                              : Icons.cancel_outlined,
                                          size: 64,
                                          color: const Color(0xFFCBD5E0),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _selectedFilter == 'ACCEPTED'
                                              ? 'Belum ada lamaran diterima'
                                              : 'Belum ada lamaran ditolak',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF718096),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    color: const Color(0xFF5B86E5),
                                    onRefresh: () => controller.fetchHistory(),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: filteredHistory.length,
                                      itemBuilder: (context, i) {
                                        final item = filteredHistory[i];
                                        final pos = item['position'];
                                        final comp = pos?['company'];
                                        final status =
                                            item['status'] ?? 'PENDING';
                                        final applyDate =
                                            item['apply_date'] ?? '';

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFF5B86E5)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .work_outline_rounded,
                                                        color:
                                                            Color(0xFF5B86E5),
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            pos?['position_name'] ??
                                                                '-',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xFF2D3748),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .business_outlined,
                                                                size: 14,
                                                                color: Color(
                                                                    0xFF718096),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Expanded(
                                                                child: Text(
                                                                  comp?['company_name'] ??
                                                                      '-',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                        0xFF718096),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                const Divider(
                                                    height: 1,
                                                    color: Color(0xFFE2E8F0)),
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Status Badge
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                                status)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            _getStatusIcon(
                                                                status),
                                                            size: 14,
                                                            color:
                                                                _getStatusColor(
                                                                    status),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            status
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  _getStatusColor(
                                                                      status),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Apply Date
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_today_outlined,
                                                          size: 14,
                                                          color:
                                                              Color(0xFF718096),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          applyDate.toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF718096),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
            bottomNavigationBar: BottomNav(1),
          );
        },
      ),
    );
  }

  // ✅ Widget untuk Filter Chip
  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF5B86E5);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? chipColor : chipColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : chipColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : chipColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}