// lib/screens/profile/public_profile_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final dio = await ApiClient.getClient();
      final res = await dio.get('/auth/users/${widget.userId}');
      setState(() {
        _user = Map<String, dynamic>.from(res.data as Map);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load profile.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = (_user?['role'] ?? '') as String;
    final accent = _accentForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                  color: const Color(0xFF6366F1), strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', color: Colors.white54)))
              : _buildProfile(accent),
    );
  }

  Widget _buildProfile(Color accent) {
    final u = _user!;
    final role = (u['role'] ?? '') as String;
    final name = (u['name'] ?? '') as String;
    final email = (u['email'] ?? '') as String;
    final bio = (u['bio'] ?? '') as String;
    final company = (u['companyName'] ?? '') as String;
    final stage = (u['startupStage'] ?? '') as String;
    final skills = u['skills'] is List
        ? List<String>.from(u['skills'] as List)
        : <String>[];
    final availability = (u['availability'] ?? '') as String;
    final investmentFocus = (u['investmentFocus'] ?? '') as String;
    final portfolio = (u['portfolioLink'] ?? '') as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + role
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: accent.withOpacity(0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role[0].toUpperCase() + role.substring(1),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          if (bio.isNotEmpty) ...[
            _sectionLabel('About'),
            const SizedBox(height: 8),
            Text(bio,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5)),
            const SizedBox(height: 20),
          ],

          if (email.isNotEmpty) _infoRow(Icons.mail_outline_rounded, email),
          if (company.isNotEmpty)
            _infoRow(Icons.business_rounded, company),
          if (stage.isNotEmpty)
            _infoRow(Icons.flag_outlined, 'Stage: $stage'),
          if (availability.isNotEmpty)
            _infoRow(Icons.schedule_rounded, availability),
          if (investmentFocus.isNotEmpty)
            _infoRow(Icons.trending_up_rounded, investmentFocus),
          if (portfolio.isNotEmpty)
            _infoRow(Icons.link_rounded, portfolio),

          if (skills.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel('Skills'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accent.withOpacity(0.3), width: 1),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: accent)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 0.5,
        ),
      );

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: Colors.white70)),
            ),
          ],
        ),
      );

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