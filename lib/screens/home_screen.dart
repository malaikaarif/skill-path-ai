import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const HomeScreen({super.key, required this.extra});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> roadmap = [];
  String goal = '';
  String level = '';
  String _name = '';
  int streakDays = 1;
  int completedTopics = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    setState(() => _loading = true);
    try {
      final profile = await FirebaseService.getUserProfile();
      final savedRoadmap = await FirebaseService.getRoadmap();
      final completed = await FirebaseService.getCompletedTopics();
      final streak = await FirebaseService.updateStreak();

      setState(() {
        goal = profile?['goal'] ?? widget.extra['goal'] ?? '';
        level = profile?['level'] ?? widget.extra['level'] ?? '';
        _name = profile?['name'] ?? widget.extra['name'] ?? '';
        roadmap = savedRoadmap ?? _safeRoadmapFromExtra();
        completedTopics = completed;
        streakDays = streak;
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('Firestore load error: $e');
      debugPrint('$stack');
      setState(() {
        roadmap = _safeRoadmapFromExtra();
        goal = widget.extra['goal'] ?? '';
        level = widget.extra['level'] ?? '';
        _name = widget.extra['name'] ?? '';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _safeRoadmapFromExtra() {
    final rawList = (widget.extra['roadmap'] ?? []) as List;
    return rawList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['tags'] != null) {
        map['tags'] = List<String>.from((map['tags'] as List).map((e) => e.toString()));
      }
      return map;
    }).toList();
  }

  double get progressPercent =>
      roadmap.isEmpty ? 0 : completedTopics / roadmap.length;

  Map<String, dynamic>? get todayTopic =>
      roadmap.isNotEmpty ? roadmap[completedTopics.clamp(0, roadmap.length - 1)] : null;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F7FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7F77DD)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFromFirestore,
          color: const Color(0xFF7F77DD),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildTodayTask(),
                const SizedBox(height: 24),
                _buildRoadmapPreview(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning${_name.isNotEmpty ? ', $_name' : ''} 👋',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(goal,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/profile', extra: {
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          }),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF7F77DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('🔥', '$streakDays', 'day streak', const Color(0xFFFAEEDA)),
        const SizedBox(width: 12),
        _statCard('✅', '${(progressPercent * 100).toInt()}%',
            'complete', const Color(0xFFE1F5EE)),
        const SizedBox(width: 12),
        _statCard('📚', '${roadmap.length}', 'topics', const Color(0xFFEEEDFE)),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTask() {
    if (todayTopic == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF7F77DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's task",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(todayTopic!['title'] ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(todayTopic!['description'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              _taskChip('${todayTopic!['duration_days']} days'),
              const SizedBox(width: 8),
              _taskChip(todayTopic!['difficulty'] ?? ''),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/roadmap', extra: {
                  'roadmap': roadmap,
                  'goal': goal,
                  'level': level,
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Start',
                      style: TextStyle(
                          color: Color(0xFF7F77DD),
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taskChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildRoadmapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your roadmap',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => context.go('/roadmap', extra: {
                'roadmap': roadmap,
                'goal': goal,
                'level': level,
              }),
              child: const Text('See all',
                  style: TextStyle(
                      color: Color(0xFF7F77DD),
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...roadmap.take(4).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final topic = entry.value;
          final isDone = i < completedTopics;
          final isCurrent = i == completedTopics;
          return _roadmapItem(topic, isDone, isCurrent, i);
        }),
      ],
    );
  }

  Widget _roadmapItem(Map<String, dynamic> topic, bool isDone,
      bool isCurrent, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFEEEDFE) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xFF7F77DD) : Colors.grey.shade200,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF1D9E75)
                  : isCurrent
                  ? const Color(0xFF7F77DD)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              color: isDone || isCurrent ? Colors.white : Colors.grey,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic['title'] ?? '',
                    style: TextStyle(
                        fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? const Color(0xFF3C3489)
                            : Colors.black87)),
                Text(
                    '${topic['duration_days']} days · ${topic['difficulty']}',
                    style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (isCurrent)
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF7F77DD)),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xFF7F77DD),
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        if (i == 1) context.go('/roadmap', extra: {'roadmap': roadmap, 'goal': goal, 'level': level});
        if (i == 2) context.go('/chat', extra: {'topic': todayTopic?['title'] ?? ''});
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Tutor'),
      ],
    );
  }
}