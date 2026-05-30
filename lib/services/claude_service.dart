import '../config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _apiKey = Config.groqKey;
  static const String _model = 'llama-3.3-70b-versatile';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // ─── REAL RESOURCE LIBRARY ───────────────────────────────────────────────
  static const Map<String, List<Map<String, String>>> _resources = {
    'python': [
      {'title': 'Python for Everybody - Free', 'url': 'https://www.coursera.org/specializations/python', 'type': 'course', 'platform': 'Coursera', 'duration': '8 months'},
      {'title': 'CS50P - Free Harvard Course', 'url': 'https://cs50.harvard.edu/python', 'type': 'course', 'platform': 'Harvard', 'duration': 'Self-paced'},
      {'title': 'Python Full Course - FreeCodeCamp', 'url': 'https://www.youtube.com/watch?v=rfscVS0vtbw', 'type': 'video', 'platform': 'YouTube', 'duration': '4.5 hrs'},
    ],
    'machine learning': [
      {'title': 'ML Specialization - Andrew Ng', 'url': 'https://www.coursera.org/specializations/machine-learning-introduction', 'type': 'course', 'platform': 'Coursera', 'duration': '3 months'},
      {'title': 'Fast.ai - Free Practical ML', 'url': 'https://course.fast.ai', 'type': 'course', 'platform': 'Fast.ai', 'duration': 'Self-paced'},
      {'title': 'ML Course - StatQuest', 'url': 'https://www.youtube.com/@statquest', 'type': 'video', 'platform': 'YouTube', 'duration': 'Series'},
    ],
    'neural networks': [
      {'title': '3Blue1Brown Neural Networks', 'url': 'https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi', 'type': 'video', 'platform': 'YouTube', 'duration': '4 videos'},
      {'title': 'Deep Learning Specialization', 'url': 'https://www.coursera.org/specializations/deep-learning', 'type': 'course', 'platform': 'Coursera', 'duration': '5 months'},
      {'title': 'Neural Networks - Andrej Karpathy', 'url': 'https://www.youtube.com/watch?v=VMj-3S1tku0', 'type': 'video', 'platform': 'YouTube', 'duration': '2.5 hrs'},
    ],
    'deep learning': [
      {'title': 'Deep Learning Specialization', 'url': 'https://www.coursera.org/specializations/deep-learning', 'type': 'course', 'platform': 'Coursera', 'duration': '5 months'},
      {'title': 'Fast.ai Deep Learning', 'url': 'https://course.fast.ai', 'type': 'course', 'platform': 'Fast.ai', 'duration': 'Self-paced'},
      {'title': 'MIT Deep Learning 6.S191', 'url': 'https://introtodeeplearning.com', 'type': 'course', 'platform': 'MIT', 'duration': 'Self-paced'},
    ],
    'data science': [
      {'title': 'IBM Data Science - Free Audit', 'url': 'https://www.coursera.org/professional-certificates/ibm-data-science', 'type': 'course', 'platform': 'Coursera', 'duration': '3 months'},
      {'title': 'Kaggle Free Courses', 'url': 'https://www.kaggle.com/learn', 'type': 'course', 'platform': 'Kaggle', 'duration': 'Self-paced'},
      {'title': 'CS50 AI - Harvard Free', 'url': 'https://cs50.harvard.edu/ai', 'type': 'course', 'platform': 'Harvard', 'duration': 'Self-paced'},
    ],
    'numpy': [
      {'title': 'NumPy Official Tutorial', 'url': 'https://numpy.org/doc/stable/user/quickstart.html', 'type': 'article', 'platform': 'NumPy Docs', 'duration': '2 hrs'},
      {'title': 'NumPy Full Course', 'url': 'https://www.youtube.com/watch?v=QUT1VHiLmmI', 'type': 'video', 'platform': 'YouTube', 'duration': '1 hr'},
      {'title': 'Kaggle NumPy', 'url': 'https://www.kaggle.com/learn/intro-to-programming', 'type': 'course', 'platform': 'Kaggle', 'duration': 'Self-paced'},
    ],
    'pandas': [
      {'title': 'Pandas Official Docs', 'url': 'https://pandas.pydata.org/docs/getting_started/index.html', 'type': 'article', 'platform': 'Pandas Docs', 'duration': '3 hrs'},
      {'title': 'Kaggle Pandas Course - Free', 'url': 'https://www.kaggle.com/learn/pandas', 'type': 'course', 'platform': 'Kaggle', 'duration': 'Self-paced'},
      {'title': 'Pandas Full Course', 'url': 'https://www.youtube.com/watch?v=vmEHCJofslg', 'type': 'video', 'platform': 'YouTube', 'duration': '1 hr'},
    ],
    'nlp': [
      {'title': 'HuggingFace NLP Course - Free', 'url': 'https://huggingface.co/learn/nlp-course', 'type': 'course', 'platform': 'HuggingFace', 'duration': 'Self-paced'},
      {'title': 'Stanford NLP CS224N', 'url': 'https://web.stanford.edu/class/cs224n', 'type': 'course', 'platform': 'Stanford', 'duration': 'Self-paced'},
      {'title': 'NLP Zero to Hero', 'url': 'https://www.youtube.com/playlist?list=PLQY2H8rRoyvzDbLUZkbudP-MFQZwNmU4S', 'type': 'video', 'platform': 'YouTube', 'duration': 'Series'},
    ],
    'computer vision': [
      {'title': 'Stanford CS231N', 'url': 'https://cs231n.stanford.edu', 'type': 'course', 'platform': 'Stanford', 'duration': 'Self-paced'},
      {'title': 'OpenCV Python Tutorial', 'url': 'https://www.youtube.com/watch?v=oXlwWbU8l2o', 'type': 'video', 'platform': 'YouTube', 'duration': '3 hrs'},
      {'title': 'Kaggle Computer Vision', 'url': 'https://www.kaggle.com/learn/computer-vision', 'type': 'course', 'platform': 'Kaggle', 'duration': 'Self-paced'},
    ],
    'statistics': [
      {'title': 'Statistics with Python - Coursera', 'url': 'https://www.coursera.org/specializations/statistics-with-python', 'type': 'course', 'platform': 'Coursera', 'duration': '3 months'},
      {'title': 'Khan Academy Statistics', 'url': 'https://www.khanacademy.org/math/statistics-probability', 'type': 'course', 'platform': 'Khan Academy', 'duration': 'Self-paced'},
      {'title': 'StatQuest Statistics', 'url': 'https://www.youtube.com/@statquest', 'type': 'video', 'platform': 'YouTube', 'duration': 'Series'},
    ],
    'flutter': [
      {'title': 'Flutter Official Docs', 'url': 'https://docs.flutter.dev', 'type': 'article', 'platform': 'Flutter', 'duration': 'Reference'},
      {'title': 'Flutter Full Course - FreeCodeCamp', 'url': 'https://www.youtube.com/watch?v=VPvVD8t02U8', 'type': 'video', 'platform': 'YouTube', 'duration': '6 hrs'},
      {'title': 'Flutter & Dart Bootcamp - Udemy', 'url': 'https://www.udemy.com/course/flutter-bootcamp-with-dart', 'type': 'course', 'platform': 'Udemy', 'duration': '27 hrs'},
    ],
    'javascript': [
      {'title': 'JavaScript.info - Free', 'url': 'https://javascript.info', 'type': 'article', 'platform': 'javascript.info', 'duration': 'Self-paced'},
      {'title': 'FreeCodeCamp JavaScript', 'url': 'https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures', 'type': 'course', 'platform': 'FreeCodeCamp', 'duration': 'Self-paced'},
      {'title': 'JavaScript Full Course', 'url': 'https://www.youtube.com/watch?v=PkZNo7MFNFg', 'type': 'video', 'platform': 'YouTube', 'duration': '3.5 hrs'},
    ],
    'algorithms': [
      {'title': 'CS50 - Free Harvard', 'url': 'https://cs50.harvard.edu/x', 'type': 'course', 'platform': 'Harvard', 'duration': 'Self-paced'},
      {'title': 'Algorithms - Princeton Coursera', 'url': 'https://www.coursera.org/learn/algorithms-part1', 'type': 'course', 'platform': 'Coursera', 'duration': '6 weeks'},
      {'title': 'NeetCode DSA Course', 'url': 'https://neetcode.io/courses/dsa-for-beginners/0', 'type': 'course', 'platform': 'NeetCode', 'duration': 'Self-paced'},
    ],
    'sql': [
      {'title': 'SQLZoo - Free Interactive', 'url': 'https://sqlzoo.net', 'type': 'course', 'platform': 'SQLZoo', 'duration': 'Self-paced'},
      {'title': 'Kaggle SQL Course - Free', 'url': 'https://www.kaggle.com/learn/intro-to-sql', 'type': 'course', 'platform': 'Kaggle', 'duration': 'Self-paced'},
      {'title': 'SQL Full Course', 'url': 'https://www.youtube.com/watch?v=HXV3zeQKqGY', 'type': 'video', 'platform': 'YouTube', 'duration': '4 hrs'},
    ],
  };

  // ─── LOCAL RESOURCE MATCHER ──────────────────────────────────────────────
  List<Map<String, dynamic>> getResourcesLocal({
    required String topic,
    required List<String> tags,
  }) {
    final topicLower = topic.toLowerCase();

    // Match by tags first
    for (final tag in tags) {
      if (_resources.containsKey(tag.toLowerCase())) {
        return _resources[tag.toLowerCase()]!
            .map((r) => Map<String, dynamic>.from(r))
            .toList();
      }
    }

    // Match by topic name
    for (final key in _resources.keys) {
      if (topicLower.contains(key) || key.contains(topicLower)) {
        return _resources[key]!
            .map((r) => Map<String, dynamic>.from(r))
            .toList();
      }
    }

    // Fallback
    return [
      {
        'title': 'Search on YouTube',
        'url': 'https://www.youtube.com/results?search_query=${topic.replaceAll(' ', '+')}',
        'type': 'video',
        'platform': 'YouTube',
        'duration': 'varies',
      },
      {
        'title': 'Free courses on Coursera',
        'url': 'https://www.coursera.org/search?query=${topic.replaceAll(' ', '+')}',
        'type': 'course',
        'platform': 'Coursera',
        'duration': 'varies',
      },
    ];
  }

  Future<String> _call(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('Groq error: ${response.statusCode} ${response.body}');
    }
  }

  // ─── 1. ROADMAP GENERATION ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateRoadmap({
    required String goal,
    required String level,
    required String hoursPerDay,
  }) async {
    final prompt = '''
You are an expert learning path designer.
Generate a personalized learning roadmap for someone who wants to become a $goal.
Their current level is $level and they can study $hoursPerDay per day.

Return ONLY a valid JSON array with exactly 10 topics. No explanation, no markdown, no code blocks. Just raw JSON.
Each topic must have these exact fields:
[
  {
    "id": "topic_1",
    "title": "Topic title",
    "description": "One sentence description",
    "duration_days": 3,
    "difficulty": "beginner",
    "tags": ["tag1", "tag2"],
    "score": 1.0,
    "order": 1
  }
]
''';

    final text = await _call(prompt);
    final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ─── 2. DAILY TASK GENERATOR ─────────────────────────────────────────────
  Future<Map<String, dynamic>> generateDailyTask({
    required String currentTopic,
    required String goal,
    required String level,
    required int streakDays,
  }) async {
    final prompt = '''
You are a learning coach. Generate today's learning task.
Current topic: $currentTopic
Goal: $goal
Level: $level
Streak: $streakDays days

Return ONLY raw JSON, no markdown, no code blocks:
{
  "title": "Task title",
  "description": "What to do today",
  "duration_minutes": 45,
  "type": "video",
  "resource_url": "https://youtube.com",
  "tip": "One motivational tip"
}
''';

    final text = await _call(prompt);
    final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
    return Map<String, dynamic>.from(jsonDecode(cleaned));
  }

  // ─── 3. CHAT TUTOR ───────────────────────────────────────────────────────
  Future<String> chat({
    required String userMessage,
    required String currentTopic,
    required List<Map<String, String>> history,
  }) async {
    final historyText = history.map((m) => '${m['role']}: ${m['content']}').join('\n');

    final prompt = '''
You are an expert tutor helping a student learn $currentTopic.
Explain concepts simply. Use examples. Be encouraging.
Keep responses concise — max 3 short paragraphs.

Conversation so far:
$historyText

Student: $userMessage
Tutor:''';

    return await _call(prompt);
  }

  // ─── 4. RESOURCE RECOMMENDER (AI fallback) ───────────────────────────────
  Future<List<Map<String, dynamic>>> getResources({
    required String topic,
    required String level,
  }) async {
    final prompt = '''
Recommend 3 learning resources for "$topic" at $level level.
Return ONLY a valid JSON array, no markdown, no code blocks:
[
  {
    "title": "Resource title",
    "type": "video",
    "url": "https://youtube.com",
    "duration": "20 min",
    "description": "One sentence about this resource"
  }
]
''';

    final text = await _call(prompt);
    final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ─── 5. QUIZ GENERATOR ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String topic,
    required String level,
  }) async {
    final prompt = '''
Generate 3 multiple choice quiz questions for "$topic" at $level level.
Return ONLY a valid JSON array, no markdown, no code blocks:
[
  {
    "question": "Question text?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0,
    "explanation": "Why this is correct"
  }
]
''';

    final text = await _call(prompt);
    final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}