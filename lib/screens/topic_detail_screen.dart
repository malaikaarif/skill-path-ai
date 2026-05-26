import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/claude_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const TopicDetailScreen({super.key, required this.extra});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  Map<String, dynamic> topic = {};
  List<Map<String, dynamic>> resources = [];
  List<Map<String, dynamic>> roadmap = [];
  String goal = '';
  String level = '';
  bool loadingResources = true;

  @override
  void initState() {
    super.initState();
    topic = widget.extra['topic'] ?? {};
    roadmap = List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
    goal = widget.extra['goal'] ?? '';
    level = widget.extra['level'] ?? '';
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      final result = await ClaudeService().getResources(
        topic: topic['title'] ?? '',
        level: level,
      );
      setState(() {
        resources = result;
        loadingResources = false;
      });
    } catch (e) {
      setState(() => loadingResources = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.go('/roadmap', extra: {
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          }),
        ),
        title: const Text('Topic Detail',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopicHeader(),
            const SizedBox(height: 24),
            _buildTags(),
            const SizedBox(height: 24),
            _buildResourcesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7F77DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              topic['difficulty'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            topic['title'] ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            topic['description'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                '${topic['duration_days']} days estimated',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final tags = List<String>.from(topic['tags'] ?? []);
    if (tags.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Topics covered',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((tag) => Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(tag,
                style: const TextStyle(
                    color: Color(0xFF3C3489), fontSize: 12)),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resources',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        loadingResources
            ? const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF7F77DD)))
            : resources.isEmpty
            ? const Text('No resources found',
            style: TextStyle(color: Colors.grey))
            : Column(
          children: resources
              .map((r) => _resourceCard(r))
              .toList(),
        ),
      ],
    );
  }

  Widget _resourceCard(Map<String, dynamic> r) {
    final isVideo = r['type'] == 'video';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isVideo
                  ? const Color(0xFFFCEBEB)
                  : const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo ? Icons.play_circle_outline : Icons.article_outlined,
              color: isVideo
                  ? const Color(0xFFE24B4A)
                  : const Color(0xFF7F77DD),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                Text(r['duration'] ?? '',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/quiz', extra: {
              'topic': topic,
              'roadmap': roadmap,
              'goal': goal,
              'level': level,
            }),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Take Quiz',
                style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F77DD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/chat', extra: {
              'topic': topic['title'],
              'roadmap': roadmap,
              'goal': goal,
              'level': level,
            }),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Ask AI Tutor',
                style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7F77DD),
              side: const BorderSide(color: Color(0xFF7F77DD)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}