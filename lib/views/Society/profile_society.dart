import 'package:flutter/material.dart';
import 'package:job_seeker/services/job/job_profile_service.dart';
import 'package:job_seeker/services/user_local_service.dart';
import 'package:job_seeker/views/Society/register_society_view.dart';
import 'package:job_seeker/widgets/bottom_nav.dart';
import 'package:job_seeker/widgets/alert.dart';
import 'package:job_seeker/widgets/custom_appbar.dart';

class SocietyProfileView extends StatefulWidget {
  const SocietyProfileView({super.key});

  @override
  State<SocietyProfileView> createState() => _SocietyProfileViewState();
}

class _SocietyProfileViewState extends State<SocietyProfileView> {
  final JobProfileService _serviceProfile = JobProfileService();
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _serviceProfile.getSocietyProfile();
      if (mounted) {
        setState(() {
          profile = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await UserLocalService.clearAll();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/loginUser', (route) => false);

    context.showSuccessAlert(
      'Berhasil logout',
      title: 'Success',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF5),
      appBar: const CustomAppBar(
        title: "My Profile",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : profile == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileCard(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
      bottomNavigationBar: BottomNav(3),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image (tanpa edit button kecil)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B8FFF), Color(0xFF4E73FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            profile!['name'] ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D3D),
            ),
          ),
          const SizedBox(height: 24),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                  'Date of Birth', _formatDate(profile!['date_of_birth'])),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE8EDF5),
              ),
              _buildStatItem('Gender', profile!['gender'] ?? '-'),
            ],
          ),
          const SizedBox(height: 24),
          // Profile Details
          _buildDetailItem(Icons.email_outlined, 'Email', profile!['email']),
          const SizedBox(height: 12),
          _buildDetailItem(Icons.phone_outlined, 'Phone', profile!['phone']),
          const SizedBox(height: 12),
          _buildDetailItem(
              Icons.location_on_outlined, 'Address', profile!['address']),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E73FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8E93A6),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4E73FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E93A6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1D3D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            color: const Color(0xFF4E73FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterSocietyView(isEditMode: true),
                ),
              ).then((_) => _loadProfile());
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.logout,
            label: 'Log out',
            color: const Color(0xFF4E73FF),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1D3D),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    return date.toString().split(' ')[0];
  }
}
