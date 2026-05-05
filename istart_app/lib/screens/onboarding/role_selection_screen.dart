// lib/screens/onboarding/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _roles = [
  _RoleData(
    key: 'founder',
    label: 'Founder',
    accent: Color(0xFF6366F1),
    description: 'Post your startup idea, build a team, and attract investors.',
    icon: Icons.rocket_launch_outlined,
  ),
  _RoleData(
    key: 'collaborator',
    label: 'Collaborator',
    accent: Color(0xFF10B981),
    description: 'Join promising startups and contribute your skills.',
    icon: Icons.group_outlined,
  ),
  _RoleData(
    key: 'investor',
    label: 'Investor',
    accent: Color(0xFFF59E0B),
    description: 'Discover ideas worth funding and connect with founders.',
    icon: Icons.trending_up_outlined,
  ),
];

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedKey;
  Color _accentColor = const Color(0xFF6366F1);

  void _select(String key, Color accent) {
    setState(() {
      _selectedKey = key;
      _accentColor = accent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 1.2,
              colors: [
                _accentColor.withOpacity(0.08),
                const Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'I am a...',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your role in the iStart ecosystem.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    itemCount: _roles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final role = _roles[i];
                      final selected = _selectedKey == role.key;
                      return _RoleCard(
                        data: role,
                        selected: selected,
                        onTap: () => _select(role.key, role.accent),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  opacity: _selectedKey != null ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedKey == null
                          ? null
                          : () => context.go('/register',
                              extra: {'role': _selectedKey}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _RoleData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? data.accent.withOpacity(0.12)
            : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? data.accent : Colors.white.withOpacity(0.08),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.accent.withOpacity(selected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.accent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedOpacity(
                opacity: selected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(Icons.check_circle_rounded,
                    color: data.accent, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleData {
  const _RoleData({
    required this.key,
    required this.label,
    required this.accent,
    required this.description,
    required this.icon,
  });

  final String key;
  final String label;
  final Color accent;
  final String description;
  final IconData icon;
}