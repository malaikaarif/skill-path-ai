import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class RoadmapScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const RoadmapScreen({super.key, required this.extra});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<Map<String, dynamic>> roadmap = [];
  String goal = '';
  String level = '';
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

      setState(() {
        goal = profile?['goal'] ?? widget.extra['goal'] ?? '';
        level = profile?['level'] ?? widget.extra['level'] ?? '';
        roadmap = savedRoadmap ?? List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
        completedTopics = completed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        roadmap = List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
        goal = widget.extra['goal'] ?? '';
        level = widget.extra['level'] ?? '';
        _loading = false;
      });
    }
  }


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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Roadmap',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('$goal · $level',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completedTopics/${roadmap.length} done',
              style: const TextStyle(
                  color: Color(0xFF3C3489),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: roadmap.isEmpty
          ? const Center(child: Text('No roadmap yet. Go back and generate one!'))
          : RefreshIndicator(
        onRefresh: _loadFromFirestore,
        color: const Color(0xFF7F77DD),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: roadmap.length,
          itemBuilder: (context, index) {
            final topic = roadmap[index];
            final isDone = index < completedTopics;
            final isCurrent = index == completedTopics;
            final isLocked = index > completedTopics;
            return _buildTopicItem(topic, isDone, isCurrent, isLocked, index);
          },
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildTopicItem(Map<String, dynamic> topic, bool isDone,
      bool isCurrent, bool isLocked, int index) {
    return GestureDetector(
      onTap: isCurrent
          ? () => context.go('/topic', extra: {
        'topic': topic,
        'topicIndex': index,
        'roadmap': roadmap,
        'goal': goal,
        'level': level,
      })
          : isDone
          ? null
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildDot(isDone, isCurrent),
              if (index < roadmap.length - 1)
                Container(
                  width: 2,
                  height: 80,
                  color: isDone
                      ? const Color(0xFF1D9E75)
                      : Colors.grey.shade200,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.white
                    : isCurrent
                    ? const Color(0xFFEEEDFE)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF1D9E75).withValues(alpha: 0.3)
                      : isCurrent
                      ? const Color(0xFF7F77DD)
                      : Colors.grey.shade200,
                  width: isCurrent ? 1.5 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                  BoxShadow(
                    color: const Color(0xFF7F77DD).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isLocked
                                ? Colors.grey
                                : isCurrent
                                ? const Color(0xFF3C3489)
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isDone)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF1D9E75), size: 18)
                      else if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F77DD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Now',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        )
                      else if (isLocked)
                          const Icon(Icons.lock_outline,
                              color: Colors.grey, size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    topic['description'] ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                        isLocked ? Colors.grey.shade400 : Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _chip('${topic['duration_days']} days',
                          const Color(0xFFEEEDFE), const Color(0xFF534AB7)),
                      const SizedBox(width: 6),
                      _chip(topic['difficulty'] ?? '',
                          const Color(0xFFE1F5EE), const Color(0xFF0F6E56)),
                      const Spacer(),
                      if (isCurrent)
                        GestureDetector(
                          onTap: () => context.go('/topic', extra: {
                            'topic': topic,
                            'topicIndex': index,
                            'roadmap': roadmap,
                            'goal': goal,
                            'level': level,
                          }),
                          child: const Row(
                            children: [
                              Text('Start',
                                  style: TextStyle(
                                      color: Color(0xFF7F77DD),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 14, color: Color(0xFF7F77DD)),
                            ],
                          ),
                        ),
                      if (isDone)
                        GestureDetector(
                          onTap: () => context.go('/topic', extra: {
                            'topic': topic,
                            'topicIndex': index,
                            'roadmap': roadmap,
                            'goal': goal,
                            'level': level,
                          }),
                          child: const Row(
                            children: [
                              Text('Review',
                                  style: TextStyle(
                                      color: Color(0xFF1D9E75),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 14, color: Color(0xFF1D9E75)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isDone, bool isCurrent) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF1D9E75)
            : isCurrent
            ? const Color(0xFF7F77DD)
            : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: const Color(0xFF7F77DD), width: 2)
            : null,
      ),
      child: Icon(
        isDone ? Icons.check : Icons.circle,
        color: isDone || isCurrent ? Colors.white : Colors.grey.shade400,
        size: 12,
      ),
    );
  }

  Widget _chip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: textColor)),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: const Color(0xFF7F77DD),
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        if (i == 0) {
          context.go('/home', extra: {
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          });
        }
        if (i == 2) {
          context.go('/chat', extra: {
            'topic': roadmap.isNotEmpty ? roadmap[completedTopics.clamp(0, roadmap.length - 1)]['title'] : '',
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          });
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Tutor'),
      ],
    );
  }
}