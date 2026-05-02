// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../feed/feed_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const FeedScreen(),
    const SizedBox.shrink(), // Saved — placeholder
    const NotificationScreen(), // Alerts ✓
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'founder';
    final accent = _accentForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _pages[_currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        accent: accent,
        role: role,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'collaborator':
        return const Color(0xFF10B981);
      case 'investor':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.accent,
    required this.role,
    required this.onTap,
  });

  final int currentIndex;
  final Color accent;
  final String role;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Feed',
                selected: currentIndex == 0,
                accent: accent,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bookmark_outline_rounded,
                label: 'Saved',
                selected: currentIndex == 1,
                accent: accent,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.notifications_none_rounded,
                label: 'Alerts',
                selected: currentIndex == 2,
                accent: accent,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                accent: accent,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? accent : Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accent : Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
