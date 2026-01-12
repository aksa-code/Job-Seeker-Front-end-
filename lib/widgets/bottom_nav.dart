import 'package:flutter/material.dart';
import 'package:job_seeker/services/user_local_service.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  const BottomNav(this.currentIndex, {Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    final role = await UserLocalService.getRole();
    if (!mounted) return;
    setState(() {
      userRole = role ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    if (userRole == 'HRD') {
      return _buildModernBottomNav(
        currentIndex: widget.currentIndex.clamp(0, 1),
        items: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            route: '/HomeCompany',
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            route: '/CompanyProfile',
          ),
        ],
      );
    }

    else if (userRole == 'Society') {
      return _buildModernBottomNav(
        currentIndex: widget.currentIndex.clamp(0, 3),
        items: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            route: '/HomeSociety',
          ),
          _NavItem(
            icon: Icons.description_rounded,
            label: 'History',
            route: '/History',
          ),
          _NavItem(
            icon: Icons.work_rounded,
            label: 'Portfolio',
            route: '/ViewPortfolio',
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            route: '/SocietyProfile',
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildModernBottomNav({
    required int currentIndex,
    required List<_NavItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => Flexible(
                child: _buildNavItem(
                  item: items[index],
                  isActive: currentIndex == index,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, items[index].route);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4E73FF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4E73FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: isActive ? Colors.white : const Color(0xFF8E93A6),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF4E73FF)
                      : const Color(0xFF8E93A6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// 🎨 Alternative Style - Floating Bottom Nav (Responsive)
class BottomNavFloating extends StatefulWidget {
  final int currentIndex;
  const BottomNavFloating(this.currentIndex, {Key? key}) : super(key: key);

  @override
  State<BottomNavFloating> createState() => _BottomNavFloatingState();
}

class _BottomNavFloatingState extends State<BottomNavFloating> {
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    final role = await UserLocalService.getRole();
    if (!mounted) return;
    setState(() {
      userRole = role ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    List<_NavItem> items = [];

    if (userRole == 'HRD') {
      items = [
        _NavItem(icon: Icons.home_rounded, label: 'Home', route: '/HomeCompany'),
        _NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/CompanyProfile'),
      ];
    } else if (userRole == 'Society') {
      items = [
        _NavItem(icon: Icons.home_rounded, label: 'Home', route: '/HomeSociety'),
        _NavItem(icon: Icons.description_rounded, label: 'History', route: '/History'),
        _NavItem(icon: Icons.work_rounded, label: 'Portfolio', route: '/ViewPortfolio'),
        _NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/SocietyProfile'),
      ];
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E73FF).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => Flexible(
                child: _buildFloatingNavItem(
                  item: items[index],
                  isActive: widget.currentIndex.clamp(0, items.length - 1) == index,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, items[index].route);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required _NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isActive ? 8 : 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4E73FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: isActive ? Colors.white : const Color(0xFF8E93A6),
                size: isActive ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF4E73FF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}