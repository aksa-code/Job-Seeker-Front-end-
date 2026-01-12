import 'package:flutter/material.dart';
import 'package:job_seeker/models/portfolio_model.dart';
import 'package:job_seeker/services/portfolio_service.dart';
import 'package:job_seeker/views/Society/add_portfolio_view.dart';
import 'package:job_seeker/Widgets/view_card_portfolio.dart';
import 'package:job_seeker/widgets/bottom_nav.dart';
import 'package:job_seeker/widgets/alert.dart';
import 'package:job_seeker/widgets/custom_appbar.dart';

class PortfolioListView extends StatefulWidget {
  const PortfolioListView({super.key});

  @override
  State<PortfolioListView> createState() => _PortfolioListViewState();
}

class _PortfolioListViewState extends State<PortfolioListView> {
  final PortfolioService service = PortfolioService();
  late Future<PortfolioModel?> _futurePortfolio;

  @override
  void initState() {
    super.initState();
    _futurePortfolio = service.getPortfolio();
  }

  void _refreshPortfolio() {
    setState(() {
      _futurePortfolio = service.getPortfolio();
    });
  }

  Future<void> _deletePortfolio(int id) async {
    try {
      await service.deletePortfolio(id);
      if (!mounted) return;
      
      _refreshPortfolio();
    } catch (e) {
      if (!mounted) return;
      context.showErrorAlert(
        'Failed to delete portfolio: $e',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(
        title: "My Portfolio",
      ),
      body: FutureBuilder<PortfolioModel?>(
        future: _futurePortfolio,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B86E5)),
            );
          }

          final portfolio = snapshot.data;

          if (portfolio == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B86E5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_special_outlined,
                      size: 64,
                      color: Color(0xFF5B86E5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "No portfolio yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add your portfolio to showcase your skills",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PortfolioAddView(
                              hasExistingPortfolio: false),
                        ),
                      );
                      _refreshPortfolio();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Portfolio',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B86E5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5B86E5).withOpacity(0.1),
                        const Color(0xFF36D1DC).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5B86E5).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B86E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_special_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Your portfolio showcases your skills and achievements",
                          style: TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PortfolioCard(
                  portfolio: portfolio,
                  onDelete: () => _deletePortfolio(portfolio.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<PortfolioModel?>(
        future: _futurePortfolio,
        builder: (context, snapshot) {
          final hasPortfolio = snapshot.data != null;
          if (!hasPortfolio) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PortfolioAddView(hasExistingPortfolio: true),
                ),
              );
              _refreshPortfolio();
            },
            backgroundColor: const Color(0xFF5B86E5),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text(
              'Update Portfolio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 4,
          );
        },
      ),
      bottomNavigationBar: BottomNav(2),
    );
  }
}