import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/claude_service.dart';
import '../services/firebase_service.dart';

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
  bool _markingComplete = false;
  int topicIndex = 0;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    topic = widget.extra['topic'] ?? {};
    roadmap = List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
    goal = widget.extra['goal'] ?? '';
    level = widget.extra['level'] ?? '';
    topicIndex = widget.extra['topicIndex'] ?? 0;
    isCompleted = topic['completed'] == true;
    _loadResources();
  }

  Future<void> _loadResources() async {
    final tags = List<String>.from(topic['tags'] ?? []);
    final local = ClaudeService().getResourcesLocal(
      topic: topic['title'] ?? '',
      tags: tags,
    );

    if (local.isNotEmpty) {
      setState(() {
        resources = local;
        loadingResources = false;
      });
    } else {
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
  }

  Future<void> _markComplete() async {
    if (isCompleted || _markingComplete) return;
    setState(() => _markingComplete = true);

    try {
      // Update roadmap list
      final updatedRoadmap = roadmap.map((t) => Map<String, dynamic>.from(t)).toList();
      updatedRoadmap[topicIndex]['completed'] = true;

      final newCompleted = topicIndex + 1;

      // Save to Firestore
      await FirebaseService.saveProgress(
        completedTopics: newCompleted,
        roadmap: updatedRoadmap,
      );

      setState(() {
        isCompleted = true;
        roadmap = updatedRoadmap;
        _markingComplete = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Topic completed! Great work!'),
            backgroundColor: Color(0xFF1D9E75),
          ),
        );
        // Go back to roadmap after short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/roadmap', extra: {
            'roadmap': updatedRoadmap,
            'goal': goal,
            'level': level,
          });
        }
      }
    } catch (e) {
      setState(() => _markingComplete = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
        actions: [
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: Color(0xFF1D9E75)),
            ),
        ],
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
        color: isCompleted ? const Color(0xFF1D9E75) : const Color(0xFF7F77DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              if (isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('✅ Completed',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            topic['title'] ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: CircularProgressIndicator(color: Color(0xFF7F77DD)))
            : resources.isEmpty
            ? const Text('No resources found',
            style: TextStyle(color: Colors.grey))
            : Column(
          children: resources.map((r) => _resourceCard(r)).toList(),
        ),
      ],
    );
  }

  Widget _resourceCard(Map<String, dynamic> r) {
    final isVideo = r['type'] == 'video';
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(r['url'] ?? '');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
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
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Mark Complete button — only show if not yet completed
        if (!isCompleted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markingComplete ? null : _markComplete,
              icon: _markingComplete
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                  _markingComplete ? 'Saving...' : 'Mark as Complete',
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (!isCompleted) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/quiz', extra: {
              'topic': topic,
              'topicIndex': topicIndex,
              'roadmap': roadmap,
              'goal': goal,
              'level': level,
            }),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Take Quiz', style: TextStyle(fontSize: 16)),
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
            label:
            const Text('Ask AI Tutor', style: TextStyle(fontSize: 16)),
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