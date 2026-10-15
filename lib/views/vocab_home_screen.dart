import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/notification_service.dart';
import '../services/vocab_service.dart';
import 'pending_notifications_screen.dart';
import 'vocab_quiz_screen.dart';
import 'vocab_study_screen.dart';

class VocabHomeScreen extends StatefulWidget {
  final NotificationService notificationService;

  const VocabHomeScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<VocabHomeScreen> createState() => _VocabHomeScreenState();
}

class _VocabHomeScreenState extends State<VocabHomeScreen> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final VocabService vocabService = VocabService();
  List<VocabWord> words = [];
  int correctCount = 0;
  int wrongCount = 0;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  Future<void> loadWords() async {
    words = await vocabService.loadWords();
    if (mounted) {
      setState(() {});
    }
  }

  // Luu tu vung, thong bao ket qua va hen gio on tap sau 10 phut
  Future<void> saveAndRemind() async {
    if (wordController.text.trim().isEmpty ||
        meaningController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập từ vựng và nghĩa của từ.');
      return;
    }

    final word = VocabWord(
      word: wordController.text.trim(),
      meaning: meaningController.text.trim(),
      createdAt: DateTime.now(),
    );
    setState(() {
      words.add(word);
    });
    await vocabService.saveWords(words);

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2000000000);
    await widget.notificationService.showNow(
      id: id,
      title: 'Đã lưu từ vựng',
      body: 'Đã lưu "${word.word}". Hãy ôn tập sau 10 phút.',
      channelId: 'vocab_saved_channel',
      channelName: 'Đã lưu từ vựng',
    );
    await widget.notificationService.scheduleAfter(
      id: id + 1,
      title: 'Đến giờ ôn tập từ vựng',
      body: 'Hãy ôn từ "${word.word}" - ${word.meaning}.',
      delay: const Duration(minutes: 10),
      channelId: 'vocab_review_channel',
      channelName: 'Nhắc ôn tập từ vựng',
    );

    wordController.clear();
    meaningController.clear();
    _showMessage('Đã lưu từ và tạo lịch nhắc ôn tập sau 10 phút.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học từ vựng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Lịch nhắc',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PendingNotificationsScreen(
                  notificationService: widget.notificationService,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'VOCABULARY\nHọc từ mỗi ngày',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Học từ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VocabStudyScreen(
                      notificationService: widget.notificationService,
                    ),
                  ),
                ).then((_) => loadWords());
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Kiểm tra từ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VocabQuizScreen(
                      notificationService: widget.notificationService,
                    ),
                  ),
                ).then((_) => loadWords());
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Lịch nhắc'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PendingNotificationsScreen(
                      notificationService: widget.notificationService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _scoreCard(
                  label: 'Đúng',
                  count: correctCount,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _scoreCard(
                  label: 'Sai',
                  count: wrongCount,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: wordController,
            decoration: const InputDecoration(
              labelText: 'Nhập từ vựng',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.translate),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: meaningController,
            decoration: const InputDecoration(
              labelText: 'Nghĩa của từ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.menu_book),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saveAndRemind,
              icon: const Icon(Icons.save),
              label: const Text('Lưu và Nhắc học sau 10 phút'),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Từ đã lưu (${words.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (words.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Chưa có từ vựng. Hãy thêm từ đầu tiên.'),
            )
          else
            ...words.reversed.map(
              (word) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.abc)),
                  title: Text(word.word),
                  subtitle: Text(word.meaning),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _scoreCard({
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color)),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
