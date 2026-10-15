import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/notification_service.dart';
import '../services/vocab_service.dart';

class VocabStudyScreen extends StatefulWidget {
  final NotificationService notificationService;

  const VocabStudyScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<VocabStudyScreen> createState() => _VocabStudyScreenState();
}

class _VocabStudyScreenState extends State<VocabStudyScreen> {
  final VocabService vocabService = VocabService();
  final TextEditingController answerController = TextEditingController();
  List<VocabWord> words = [];
  int index = 0;
  int correctCount = 0;
  int wrongCount = 0;
  String feedback = '';
  bool hasChecked = false;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> loadWords() async {
    words = await vocabService.loadWords();
    if (mounted) {
      setState(() {});
    }
  }

  VocabWord? get currentWord {
    if (words.isEmpty) return null;
    return words[index % words.length];
  }

  // Kiem tra nghia nguoi dung nhap
  Future<void> checkAnswer() async {
    final word = currentWord;
    if (word == null || answerController.text.trim().isEmpty) {
      _showMessage('Hãy nhập nghĩa của từ trước khi chọn Check.');
      return;
    }

    final isCorrect = answerController.text.trim().toLowerCase() ==
        word.meaning.trim().toLowerCase();

    setState(() {
      hasChecked = true;
      if (isCorrect) {
        correctCount++;
        feedback = 'Chính xác! ${word.word} nghĩa là ${word.meaning}.';
      } else {
        wrongCount++;
        feedback = 'Chưa đúng. Đáp án: ${word.meaning}.';
      }
    });

    if (!isCorrect && wrongCount % 3 == 0) {
      await widget.notificationService.showNow(
        id: DateTime.now().millisecondsSinceEpoch.remainder(2000000000),
        title: 'Cố gắng ôn tập thêm nhé!',
        body: 'Bạn đã trả lời sai $wrongCount lần. Hãy thử lại.',
        channelId: 'vocab_wrong_channel',
        channelName: 'Nhắc khi trả lời sai',
      );
    }
  }

  void nextWord() {
    if (words.isEmpty) return;
    setState(() {
      index = (index + 1) % words.length;
      answerController.clear();
      feedback = '';
      hasChecked = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = currentWord;
    return Scaffold(
      appBar: AppBar(title: const Text('Học từ')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: word == null
            ? const Center(
                child: Text('Chưa có từ vựng. Hãy lưu từ ở màn hình chính.'),
              )
            : ListView(
                children: [
                  Row(
                    children: [
                      Expanded(child: _scoreCard('Đúng', correctCount, Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(child: _scoreCard('Sai', wrongCount, Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hãy nhập nghĩa của từ sau',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        word.word,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập nghĩa của từ',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => checkAnswer(),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: hasChecked ? null : checkAnswer,
                    child: const Text('Check'),
                  ),
                  if (feedback.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Card(
                      color: feedback.startsWith('Chính xác')
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(feedback),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: nextWord,
                      child: const Text('Từ tiếp theo'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _scoreCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color)),
            Text('$count', style: TextStyle(fontSize: 24, color: color)),
          ],
        ),
      ),
    );
  }
}
