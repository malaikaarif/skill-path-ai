import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/claude_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const ChatScreen({super.key, required this.extra});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  List<Map<String, dynamic>> roadmap = [];
  String topic = '';
  String goal = '';
  String level = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    topic = widget.extra['topic'] ?? 'your current topic';
    roadmap = List<Map<String, dynamic>>.from(widget.extra['roadmap'] ?? []);
    goal = widget.extra['goal'] ?? '';
    level = widget.extra['level'] ?? '';
    _messages.add({
      'role': 'assistant',
      'content': 'Hi! I am your AI tutor for **$topic**. Ask me anything — concepts, examples, or practice questions. I am here to help! 🎓',
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await ClaudeService().chat(
        userMessage: text,
        currentTopic: topic,
        history: _messages
            .where((m) => m['role'] != 'assistant' || _messages.indexOf(m) != 0)
            .toList(),
      );
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I had trouble connecting. Please try again.'
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F77DD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/roadmap', extra: {
            'roadmap': roadmap,
            'goal': goal,
            'level': level,
          }),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Tutor',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(topic,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 18),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopicBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final msg = _messages[index];
                return _buildMessage(msg);
              },
            ),
          ),
          _buildSuggestedQuestions(),
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildTopicBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFEEEDFE),
      child: Row(
        children: [
          const Icon(Icons.book_outlined,
              color: Color(0xFF7F77DD), size: 16),
          const SizedBox(width: 8),
          Text('Topic: $topic',
              style: const TextStyle(
                  color: Color(0xFF3C3489),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7F77DD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF7F77DD)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg['content'] ?? '',
                style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 14,
                    height: 1.5),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7F77DD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    color: Color(0xFF7F77DD),
                    backgroundColor: Color(0xFFEEEDFE),
                  ),
                ),
                SizedBox(width: 8),
                Text('Thinking...',
                    style:
                    TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'Explain simply',
      'Give an example',
      'Why is this important?',
    ];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _sendMessage(suggestions[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFAFA9EC)),
            ),
            child: Text(suggestions[i],
                style: const TextStyle(
                    color: Color(0xFF3C3489), fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask anything about $topic...',
                hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F7FF),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7F77DD),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color(0xFF7F77DD),
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        if (i == 0) context.go('/home', extra: {'roadmap': roadmap, 'goal': goal, 'level': level});
        if (i == 1) context.go('/roadmap', extra: {'roadmap': roadmap, 'goal': goal, 'level': level});
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Tutor'),
      ],
    );
  }
}