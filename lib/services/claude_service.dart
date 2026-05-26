import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _apiKey = 'AIzaSyDt61sur90eiumocB6qvSAZZ-MXXirUZ3k'; // paste your key
  static const String _model = 'gemini-1.5-flash';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  Future<String> _call(String prompt) async {
    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2000},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini error: ${response.statusCode} ${response.body}');
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
    final cleaned = text
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
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
    final cleaned = text
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    return Map<String, dynamic>.from(jsonDecode(cleaned));
  }

  // ─── 3. CHAT TUTOR ───────────────────────────────────────────────────────
  Future<String> chat({
    required String userMessage,
    required String currentTopic,
    required List<Map<String, String>> history,
  }) async {
    final historyText = history
        .map((m) => '${m['role']}: ${m['content']}')
        .join('\n');

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

  // ─── 4. RESOURCE RECOMMENDER ─────────────────────────────────────────────
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
    final cleaned = text
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
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
    final cleaned = text
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}