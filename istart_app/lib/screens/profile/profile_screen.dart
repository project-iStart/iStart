import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _loading = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  // Founder
  late TextEditingController _companyCtrl;
  late TextEditingController _stageCtrl;

  // Collaborator
  late TextEditingController _skillsCtrl; // comma-separated
  late TextEditingController _availabilityCtrl;

  // Investor
  late TextEditingController _focusCtrl;
  late TextEditingController _portfolioCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthProvider>().fetchProfile();
      _initControllers();
      if (mounted) setState(() {});
    });
  }

  void _initControllers() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    _nameCtrl = TextEditingController(text: user.name);
    _bioCtrl = TextEditingController(text: user.bio);
    _companyCtrl = TextEditingController(text: user.companyName);
    _stageCtrl = TextEditingController(text: user.startupStage);
    _skillsCtrl = TextEditingController(text: user.skills.join(', '));
    _availabilityCtrl = TextEditingController(text: user.availability);
    _focusCtrl = TextEditingController(text: user.investmentFocus);
    _portfolioCtrl = TextEditingController(text: user.portfolioLink);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _companyCtrl.dispose();
    _stageCtrl.dispose();
    _skillsCtrl.dispose();
    _availabilityCtrl.dispose();
    _focusCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  Color get _accent {
    final role = context.read<AuthProvider>().user?.role ?? '';
    if (role == 'founder') return const Color(0xFF6366F1);
    if (role == 'collaborator') return const Color(0xFF10B981);
    if (role == 'investor') return const Color(0xFFF59E0B);
    return const Color(0xFF6366F1);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final user = auth.user!;

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
    };

    if (user.role == 'founder') {
      data['companyName'] = _companyCtrl.text.trim();
      data['startupStage'] = _stageCtrl.text.trim();
    } else if (user.role == 'collaborator') {
      data['skills'] = _skillsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      data['availability'] = _availabilityCtrl.text.trim();
    } else if (user.role == 'investor') {
      data['investmentFocus'] = _focusCtrl.text.trim();
      data['portfolioLink'] = _portfolioCtrl.text.trim();
    }

    final ok = await auth.updateProfile(data);
    setState(() {
      _loading = false;
      _editing = !ok;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Profile updated!' : 'Update failed. Try again.'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      context.go('/login');
    }
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            enabled: _editing,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: _editing
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleSection(UserModel user) {
    if (user.role == 'founder') {
      return Column(
        children: [
          const _SectionHeader('Startup Info'),
          _field(
            'Company / Startup Name',
            _companyCtrl,
            hint: 'e.g. iStart Inc.',
          ),
          _field(
            'Startup Stage',
            _stageCtrl,
            hint: 'Idea / MVP / Early / Growth',
          ),
        ],
      );
    } else if (user.role == 'collaborator') {
      return Column(
        children: [
          const _SectionHeader('Skills & Availability'),
          _field(
            'Skills',
            _skillsCtrl,
            hint: 'Comma-separated: Flutter, UI/UX, Backend',
          ),
          _field(
            'Availability',
            _availabilityCtrl,
            hint: 'Part-time / Full-time / Weekends',
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const _SectionHeader('Investment Info'),
          _field(
            'Investment Focus',
            _focusCtrl,
            hint: 'e.g. EdTech, FinTech, SaaS',
          ),
          _field(
            'Portfolio / LinkedIn Link',
            _portfolioCtrl,
            hint: 'https://...',
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const SizedBox.shrink();
    }

    final initials = user.name.isNotEmpty
        ? user.name
              .trim()
              .split(' ')
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: _accent),
              onPressed: () => setState(() => _editing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: _accent,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.4)),
              ),
              child: Text(
                user.role[0].toUpperCase() + user.role.substring(1),
                style: TextStyle(
                  color: _accent,
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Common fields
            const _SectionHeader('Basic Info'),
            _field('Name', _nameCtrl),
            _readOnlyField('Email', user.email),
            _field(
              'Bio',
              _bioCtrl,
              maxLines: 3,
              hint: 'Tell the community about yourself...',
            ),

            const SizedBox(height: 8),

            // Role-specific fields
            _roleSection(user),

            const SizedBox(height: 24),

            // Save / Cancel buttons (edit mode only)
            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editing = false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
