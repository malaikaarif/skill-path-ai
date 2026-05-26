import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedGoal;
  String? selectedLevel;
  String? selectedHours;

  final goals = ['AI / ML Engineer', 'Full-Stack Developer', 'Data Scientist', 'Mobile Developer'];
  final levels = ['Beginner', 'Intermediate', 'Advanced'];
  final hours = ['0.5 hr', '1 hr', '2 hrs'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('What is your goal?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('We will build your personal learning path',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ...goals.map((g) => _choiceCard(g, selectedGoal, (v) => setState(() => selectedGoal = v))),
              const SizedBox(height: 24),
              const Text('Your level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: levels.map((l) => _chip(l, selectedLevel, (v) => setState(() => selectedLevel = v))).toList()),
              const SizedBox(height: 24),
              const Text('Hours per day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: hours.map((h) => _chip(h, selectedHours, (v) => setState(() => selectedHours = v))).toList()),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedGoal != null && selectedLevel != null && selectedHours != null)
                      ? () => context.go('/home')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F77DD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Generate my path', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceCard(String label, String? selected, Function(String) onTap) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF7F77DD) : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFF3C3489) : Colors.black87)),
      ),
    );
  }

  Widget _chip(String label, String? selected, Function(String) onTap) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF7F77DD) : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF3C3489) : Colors.black87)),
      ),
    );
  }
}