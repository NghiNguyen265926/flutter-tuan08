import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/notification_service.dart';
import '../services/vocab_service.dart';

class VocabQuizScreen extends StatefulWidget {
  final NotificationService notificationService;

  const VocabQuizScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<VocabQuizScreen> createState() => _VocabQuizScreenState();
}

class _VocabQuizScreenState extends State<VocabQuizScreen> {
  final VocabService vocabService = VocabService();
  List<VocabWord> words = [];
  List<String> options = [];
  int questionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  bool finished = false;
  bool answered = false;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    words = await vocabService.loadWords();
    if (words.isNotEmpty) {
      makeOptions();
    }
    if (mounted) {
      setState(() {});
    }
  }

  VocabWord? get currentWord {
    if (words.isEmpty || questionIndex >= words.length) return null;
    return words[questionIndex];
  }

  // Tao danh sach dap an tu nhung nghia da luu
  void makeOptions() {
    final word = currentWord;
    if (word == null) return;

    final answerList = <String>{word.meaning};
    for (final item in words) {
      answerList.add(item.meaning);
    }
    options = answerList.toList()..shuffle();
    if (options.length > 4) {
      options = options.take(4).toList();
    }
    if (!options.contains(word.meaning)) {
      options[0] = word.meaning;
    }
    options.shuffle();
  }

  // Nguoi dung chon dap an
  Future<void> chooseAnswer(String answer) async {
    final word = currentWord;
    if (word == null || answered) return;

    final isCorrect = answer.trim().toLowerCase() ==
        word.meaning.trim().toLowerCase();
    setState(() {
      answered = true;
      if (isCorrect) {
        correctCount++;
        feedback = 'Đúng! ${word.word} nghĩa là ${word.meaning}.';
      } else {
        wrongCount++;
        feedback = 'Sai. Đáp án đúng: ${word.meaning}.';
      }
    });
  }

  Future<void> nextQuestion() async {
    if (questionIndex + 1 >= words.length) {
      setState(() {
        finished = true;
      });
      await showResult();
      return;
    }

    setState(() {
      questionIndex++;
      answered = false;
      feedback = '';
      makeOptions();
    });
  }

  Future<void> showResult() async {
    final total = correctCount + wrongCount;
    final rate = total == 0 ? 0 : correctCount * 100 / total;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành bài kiểm tra'),
        content: Text(
          'Số câu đúng: $correctCount\n'
          'Số câu sai: $wrongCount\n'
          'Tỉ lệ đúng: ${rate.toStringAsFixed(1)}%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void restartQuiz() {
    setState(() {
      questionIndex = 0;
      correctCount = 0;
      wrongCount = 0;
      finished = false;
      answered = false;
      feedback = '';
      makeOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = currentWord;
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra từ')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: words.isEmpty
            ? const Center(
                child: Text('Bạn cần lưu từ vựng trước khi kiểm tra.'),
              )
            : finished
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events,
                            size: 70, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text('Đúng: $correctCount  |  Sai: $wrongCount'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: restartQuiz,
                          child: const Text('Làm lại'),
                        ),
                      ],
                    ),
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
                      const SizedBox(height: 22),
                      Text('Câu ${questionIndex + 1}/${words.length}',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const Text('Chọn nghĩa đúng của từ:'),
                              const SizedBox(height: 12),
                              Text(
                                word?.word ?? '',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...options.map(
                        (answer) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            onPressed: answered ? null : () => chooseAnswer(answer),
                            child: Text(answer),
                          ),
                        ),
                      ),
                      if (feedback.isNotEmpty) ...[
                        Card(
                          color: feedback.startsWith('Đúng!')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(feedback),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: nextQuestion,
                          child: Text(
                            questionIndex + 1 == words.length
                                ? 'Xem kết quả'
                                : 'Câu tiếp theo',
                          ),
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
