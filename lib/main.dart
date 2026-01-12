import 'package:flutter/material.dart';
import 'package:job_seeker/views/Company/add_job_view.dart';
import 'package:job_seeker/views/Company/company_profile_view.dart';
import 'package:job_seeker/views/Company/dashboard_company_view.dart';
import 'package:job_seeker/views/Company/job_detail_view_company.dart'as Company;
import 'package:job_seeker/views/Company/register_company_view.dart';
import 'package:job_seeker/views/Society/add_portfolio_view.dart';
import 'package:job_seeker/views/Society/dashboard_society_view.dart';
import 'package:job_seeker/views/Society/history_job_applied.dart';
import 'package:job_seeker/views/Society/portfolio_view.dart';
import 'package:job_seeker/views/Society/profile_society.dart';
import 'package:job_seeker/views/Society/register_society_view.dart';
import 'package:job_seeker/views/login_user.dart';
import 'package:job_seeker/views/register_user_view.dart';
import 'package:job_seeker/views/splash_screen_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {

        // Splash
        '/splash': (context) => const SplashScreenView(),

        // === AUTH ===
        '/register': (context) => const RegisterUserView(),
        '/registerSociety': (context) => const RegisterSocietyView(),
        '/registerCompany': (context) => const RegisterCompanyView(),
        '/loginUser': (context) => const LoginView(),

        // === COMPANY ===
        '/HomeCompany': (context) => const CompanyDashboardView(),
        '/addJob': (context) => const AddJobView(),
        '/CompanyProfile': (context) => const CompanyProfileView(),

        // === SOCIETY ===
        '/HomeSociety': (context) => const HomeSocietyView(),
        '/History': (context) => const ApplicationHistoryView(),
        '/ViewPortfolio': (context) => const PortfolioListView(),
        '/addPortfolio': (context) => const PortfolioAddView(),
        '/SocietyProfile': (context) => const SocietyProfileView(),
      },

      // ✅ ROUTE dengan ARGUMENT
      onGenerateRoute: (settings) {
        if (settings.name == '/jobDetail') {
          final jobId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) =>
                Company.JobDetailViewCompany(jobId: jobId), // ✅ pakai prefix
          );
        }
        return null;
      },
    );
  }
}
