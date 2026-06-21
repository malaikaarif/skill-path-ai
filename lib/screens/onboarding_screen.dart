import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/claude_service.dart';
import '../services/firebase_service.dart';
import '../services/roadmap_generator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedGoal;
  String? selectedLevel;
  String? selectedHours;
  bool _loading = false;
  final _nameController = TextEditingController();

  final goals = [
    {'title': 'AI / ML Engineer', 'icon': '🤖', 'desc': 'Build intelligent systems'},
    {'title': 'Full-Stack Developer', 'icon': '💻', 'desc': 'Build web & mobile apps'},
    {'title': 'Data Scientist', 'icon': '📊', 'desc': 'Analyze and visualize data'},
    {'title': 'Mobile Developer', 'icon': '📱', 'desc': 'Build iOS & Android apps'},
    {'title': 'Cloud Engineer', 'icon': '☁️', 'desc': 'Design cloud infrastructure'},
    {'title': 'Cybersecurity Expert', 'icon': '🔒', 'desc': 'Protect digital systems'},
    {'title': 'DSA & Competitive Programming', 'icon': '🧩', 'desc': 'Master algorithms'},
    {'title': 'Penetration Tester', 'icon': '🕵️', 'desc': 'Ethical hacking & security'},
    {'title': 'DevOps Engineer', 'icon': '⚙️', 'desc': 'CI/CD & infrastructure'},
    {'title': 'Blockchain Developer', 'icon': '🔗', 'desc': 'Web3 & smart contracts'},
  ];

  final levels = [
    {'title': 'Beginner', 'icon': '🌱', 'desc': 'Just starting out'},
    {'title': 'Intermediate', 'icon': '🚀', 'desc': 'Know the basics'},
    {'title': 'Advanced', 'icon': '⚡', 'desc': 'Ready for deep dives'},
  ];

  final hours = [
    {'title': '0.5 hr', 'desc': '30 min/day'},
    {'title': '1 hr', 'desc': '1 hour/day'},
    {'title': '2 hrs', 'desc': '2 hours/day'},
    {'title': '3+ hrs', 'desc': '3+ hours/day'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle('👤 What\'s your name?'),
              const SizedBox(height: 12),
              _buildNameField(),
              const SizedBox(height: 28),
              _buildSectionTitle('🎯 What is your goal?'),
              const SizedBox(height: 12),
              _buildGoalGrid(),
              const SizedBox(height: 28),
              _buildSectionTitle('📈 Your current level'),
              const SizedBox(height: 12),
              _buildLevelCards(),
              const SizedBox(height: 28),
              _buildSectionTitle('⏰ Hours per day'),
              const SizedBox(height: 12),
              _buildHoursRow(),
              const SizedBox(height: 40),
              _buildGenerateButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7F77DD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('SkillPath AI',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7F77DD))),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Build your learning path',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('AI will create a personalized roadmap just for you',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: 'Enter your name',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF7F77DD)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7F77DD), width: 2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }

  Widget _buildGoalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: MediaQuery.of(context).size.width > 600 ? 3.0 : 1.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: goals.length,
      itemBuilder: (context, i) {
        final goal = goals[i];
        final isSelected = selectedGoal == goal['title'];
        return GestureDetector(
          onTap: () => setState(() => selectedGoal = goal['title']),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF7F77DD) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [BoxShadow(
                  color: const Color(0xFF7F77DD).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3))]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(goal['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(goal['title']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFF3C3489)
                            : Colors.black87)),
                Text(goal['desc']!,
                    style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? const Color(0xFF534AB7)
                            : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCards() {
    return Row(
      children: levels.map((l) {
        final isSelected = selectedLevel == l['title'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedLevel = l['title']),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF7F77DD) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(l['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(l['title']!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF3C3489)
                              : Colors.black87)),
                  Text(l['desc']!,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHoursRow() {
    return Row(
      children: hours.map((h) {
        final isSelected = selectedHours == h['title'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedHours = h['title']),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF7F77DD) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(h['title']!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected
                              ? const Color(0xFF3C3489)
                              : Colors.black87)),
                  Text(h['desc']!,
                      style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = selectedGoal != null &&
        selectedLevel != null &&
        selectedHours != null &&
        _nameController.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canGenerate && !_loading ? _generateRoadmap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F77DD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _loading
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('AI is building your path...',
                style: TextStyle(fontSize: 16)),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 20),
            SizedBox(width: 8),
            Text('Generate my path',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _generateRoadmap() async {
    setState(() => _loading = true);
    try {
      final roadmap = RoadmapGenerator.generate(
        goal: selectedGoal!,
        level: selectedLevel!,
        hoursPerDay: selectedHours!,
      );

      final name = _nameController.text.trim();

      // Save to Firebase
      await FirebaseService.saveUserProfile(
        goal: selectedGoal!,
        level: selectedLevel!,
        hoursPerDay: selectedHours!,
        name: name,
      );
      await FirebaseService.saveRoadmap(roadmap);

      if (mounted) {
        context.go('/home', extra: {
          'roadmap': roadmap,
          'goal': selectedGoal,
          'level': selectedLevel,
          'hours': selectedHours,
          'name': name,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: const Color(0xFFE24B4A)),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
}