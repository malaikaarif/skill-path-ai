import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/roadmap_generator.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const ProfileScreen({super.key, required this.extra});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String goal = '';
  String level = '';
  String hoursPerDay = '';
  int completedTopics = 0;
  int totalTopics = 0;
  int streak = 0;
  bool loading = true;
  bool _editing = false;
  bool _saving = false;

  String? _editGoal;
  String? _editLevel;
  String? _editHours;

  final goals = [
    'AI / ML Engineer', 'Full-Stack Developer', 'Data Scientist',
    'Mobile Developer', 'Cloud Engineer', 'Cybersecurity Expert',
    'DSA & Competitive Programming', 'Penetration Tester',
    'DevOps Engineer', 'Blockchain Developer',
  ];
  final levels = ['Beginner', 'Intermediate', 'Advanced'];
  final hoursOptions = ['0.5 hr', '1 hr', '2 hrs', '3+ hrs'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);
    final profile = await FirebaseService.getUserProfile();
    final roadmap = await FirebaseService.getRoadmap();
    final completed = await FirebaseService.getCompletedTopics();

    setState(() {
      name = profile?['name'] ?? '';
      email = FirebaseService.currentUser?.email ?? '';
      goal = profile?['goal'] ?? '';
      level = profile?['level'] ?? '';
      hoursPerDay = profile?['hoursPerDay'] ?? '';
      totalTopics = roadmap?.length ?? 0;
      completedTopics = completed;
      streak = profile?['streak'] ?? 0;
      _editGoal = goal;
      _editLevel = level;
      _editHours = hoursPerDay;
      loading = false;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);

    final goalChanged = _editGoal != goal || _editLevel != level;

    await FirebaseService.updateGoalAndLevel(
      goal: _editGoal!,
      level: _editLevel!,
      hoursPerDay: _editHours!,
    );

    // If goal or level changed significantly, offer to regenerate roadmap
    if (goalChanged && mounted) {
      final shouldRegenerate = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update your roadmap?'),
          content: const Text(
              'You changed your goal or level. Would you like to generate a new roadmap based on these changes? Your current progress will be reset.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep current roadmap'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F77DD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate new roadmap'),
            ),
          ],
        ),
      );

      if (shouldRegenerate == true) {
        final newRoadmap = RoadmapGenerator.generate(
          goal: _editGoal!,
          level: _editLevel!,
          hoursPerDay: _editHours!,
        );
        await FirebaseService.saveRoadmap(newRoadmap);
        await FirebaseService.saveProgress(completedTopics: 0, roadmap: newRoadmap);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF1D9E75),
        ),
      );
      setState(() {
        _editing = false;
        _saving = false;
        goal = _editGoal!;
        level = _editLevel!;
        hoursPerDay = _editHours!;
      });
      await _loadProfile();
    }
  }

  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?'),
        content: const Text('You\'ll need to sign in again to continue your learning journey.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService.signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F7FF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7F77DD))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.go('/home', extra: widget.extra),
        ),
        title: const Text('Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (!_editing)
            TextButton(
              onPressed: () => setState(() => _editing = true),
              child: const Text('Edit',
                  style: TextStyle(color: Color(0xFF7F77DD), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarHeader(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _editing ? _buildEditForm() : _buildInfoCard(),
            const SizedBox(height: 24),
            if (!_editing) _buildDangerZone(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B52C8), Color(0xFF9B94E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Text(name.isNotEmpty ? name : 'Learner',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('🔥', '$streak', 'streak'),
        const SizedBox(width: 10),
        _statCard('✅', '$completedTopics', 'done'),
        const SizedBox(width: 10),
        _statCard('📚', '$totalTopics', 'topics'),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.flag_outlined, 'Goal', goal),
          const Divider(height: 24),
          _infoRow(Icons.bar_chart, 'Level', level),
          const Divider(height: 24),
          _infoRow(Icons.schedule, 'Daily commitment', hoursPerDay),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7F77DD), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(value.isNotEmpty ? value : '—',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _editGoal,
            decoration: _dropdownDecoration(),
            items: goals
                .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _editGoal = v),
          ),
          const SizedBox(height: 16),
          const Text('Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _editLevel,
            decoration: _dropdownDecoration(),
            items: levels
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _editLevel = v),
          ),
          const SizedBox(height: 16),
          const Text('Hours per day', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _editHours,
            decoration: _dropdownDecoration(),
            items: hoursOptions
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (v) => setState(() => _editHours = v),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                    _editing = false;
                    _editGoal = goal;
                    _editLevel = level;
                    _editHours = hoursPerDay;
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F77DD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F7FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7F77DD), width: 2),
      ),
    );
  }

  Widget _buildDangerZone() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmSignOut,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Sign out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE24B4A),
          side: const BorderSide(color: Color(0xFFE24B4A)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}