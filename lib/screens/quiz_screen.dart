import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/claude_service.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const QuizScreen({super.key, required this.extra});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic> topic = {};
  List<Map<String, dynamic>> roadmap = [];
  String goal = '';
  String level = '';
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  int? selectedAnswer;
  bool answered = false;
  int correctCount = 0;
  bool loading = true;
  bool quizDone = false;
  List<Map<String, dynamic>> adaptedRoadmap = [];

  @override
  void initState() {
    super.initState();
    topic = widget.extra['topic'] ?? {};
    roadmap = List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
    goal = widget.extra['goal'] ?? '';
    level = widget.extra['level'] ?? '';
    adaptedRoadmap = List<Map<String, dynamic>>.from(roadmap);
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final result = await ClaudeService().generateQuiz(
        topic: topic['title'] ?? '',
        level: level,
      );
      setState(() {
        questions = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ── THE ADAPTIVE ML LOGIC ──────────────────────────────────────────────
  List<Map<String, dynamic>> _adaptRoadmap(double score) {
    final updated = adaptedRoadmap.map((t) {
      final updatedTopic = Map<String, dynamic>.from(t);
      final tags = List<String>.from(t['tags'] ?? []);
      final currentTags = List<String>.from(topic['tags'] ?? []);
      final overlap = tags.where((tag) => currentTags.contains(tag)).length;

      if (t['id'] == topic['id']) {
        // Current topic — update score based on quiz result
        updatedTopic['score'] = score >= 0.7 ? 1.5 : 0.5;
        updatedTopic['completed'] = score >= 0.7;
      } else if (overlap > 0 && score < 0.5) {
        // Related topics — boost if user struggled (needs revision)
        updatedTopic['score'] =
            (t['score'] as double? ?? 1.0) + (overlap * 0.3);
        updatedTopic['needsRevision'] = true;
      } else if (overlap > 0 && score >= 0.8) {
        // Related topics — user aced it, can move faster
        updatedTopic['score'] =
            (t['score'] as double? ?? 1.0) - (overlap * 0.2);
      }
      return updatedTopic;
    }).toList();

    // Re-sort: completed first, then by score descending
    updated.sort((a, b) {
      if (a['completed'] == true && b['completed'] != true) return -1;
      if (b['completed'] == true && a['completed'] != true) return 1;
      final aScore = a['score'] as double? ?? 1.0;
      final bScore = b['score'] as double? ?? 1.0;
      return bScore.compareTo(aScore);
    });

    return updated;
  }

  void _selectAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == questions[currentQuestion]['correct_index']) {
        correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      // Quiz done — run adaptive algorithm
      final score = correctCount / questions.length;
      final newRoadmap = _adaptRoadmap(score);
      setState(() {
        quizDone = true;
        adaptedRoadmap = newRoadmap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF7F77DD)),
              const SizedBox(height: 16),
              Text('Generating quiz for ${topic['title']}...',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (quizDone) return _buildResultScreen();

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load quiz'),
              ElevatedButton(
                onPressed: () => context.go('/roadmap', extra: {
                  'roadmap': roadmap,
                  'goal': goal,
                  'level': level,
                }),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.go('/roadmap', extra: {
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          }),
        ),
        title: Text(topic['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
            const SizedBox(height: 32),
            _buildQuestion(),
            const SizedBox(height: 24),
            _buildOptions(),
            const SizedBox(height: 16),
            if (answered) _buildExplanation(),
            const SizedBox(height: 16),
            if (answered) _buildNextButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${currentQuestion + 1} of ${questions.length}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('$correctCount correct',
                style: const TextStyle(
                    color: Color(0xFF1D9E75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentQuestion + 1) / questions.length,
          backgroundColor: Colors.grey.shade200,
          color: const Color(0xFF7F77DD),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Text(
      questions[currentQuestion]['question'] ?? '',
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
    );
  }

  Widget _buildOptions() {
    final options =
    List<String>.from(questions[currentQuestion]['options'] ?? []);
    final correctIndex =
        questions[currentQuestion]['correct_index'] as int? ?? 0;

    return Column(
      children: options.asMap().entries.map((entry) {
        final i = entry.key;
        final option = entry.value;
        Color borderColor = Colors.grey.shade300;
        Color bgColor = Colors.white;
        Widget? trailingIcon;

        if (answered) {
          if (i == correctIndex) {
            borderColor = const Color(0xFF1D9E75);
            bgColor = const Color(0xFFE1F5EE);
            trailingIcon = const Icon(Icons.check_circle,
                color: Color(0xFF1D9E75));
          } else if (i == selectedAnswer) {
            borderColor = const Color(0xFFE24B4A);
            bgColor = const Color(0xFFFCEBEB);
            trailingIcon =
            const Icon(Icons.cancel, color: Color(0xFFE24B4A));
          }
        } else if (selectedAnswer == i) {
          borderColor = const Color(0xFF7F77DD);
          bgColor = const Color(0xFFEEEDFE);
        }

        return GestureDetector(
          onTap: () => _selectAnswer(i),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text(option,
                        style: const TextStyle(fontSize: 15))),
                trailingIcon ?? const SizedBox.shrink(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Color(0xFF7F77DD), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              questions[currentQuestion]['explanation'] ?? '',
              style: const TextStyle(
                  color: Color(0xFF3C3489), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = currentQuestion == questions.length - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F77DD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(isLast ? 'See Results' : 'Next Question',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = correctCount / questions.length;
    final passed = score >= 0.7;
    final changedTopics = adaptedRoadmap
        .where((t) => t['needsRevision'] == true)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Score circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFFE1F5EE)
                      : const Color(0xFFFCEBEB),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$correctCount/${questions.length}',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: passed
                                ? const Color(0xFF1D9E75)
                                : const Color(0xFFE24B4A))),
                    Text(passed ? 'Passed!' : 'Keep going',
                        style: TextStyle(
                            color: passed
                                ? const Color(0xFF1D9E75)
                                : const Color(0xFFE24B4A),
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed
                    ? 'Great job! Your roadmap has been updated.'
                    : 'No worries! Your roadmap has been adjusted.',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // AI adaptation result
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFF7F77DD), size: 18),
                        const SizedBox(width: 8),
                        const Text('AI re-ranked your path',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3C3489))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (passed)
                      const _AdaptRow(
                          icon: Icons.arrow_upward,
                          color: Color(0xFF1D9E75),
                          text: 'Next topics moved up — you are ready')
                    else
                      const _AdaptRow(
                          icon: Icons.refresh,
                          color: Color(0xFFE24B4A),
                          text: 'Revision topics added to your path'),
                    if (changedTopics.isNotEmpty)
                      ...changedTopics.take(2).map((t) => _AdaptRow(
                        icon: Icons.bookmark_outline,
                        color: const Color(0xFFBA7517),
                        text: '${t['title']} marked for revision',
                      )),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/roadmap', extra: {
                    'roadmap': adaptedRoadmap,
                    'goal': goal,
                    'level': level,
                    'completedTopics': 1,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F77DD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View updated roadmap',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdaptRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _AdaptRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}