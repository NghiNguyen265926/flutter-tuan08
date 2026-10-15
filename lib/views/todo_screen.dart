import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';

class TodoScreen extends StatefulWidget {
  final NotificationService notificationService;

  const TodoScreen({super.key, required this.notificationService});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();
  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Doc du lieu da luu trong file todo.txt
  Future<void> loadData() async {
    todos = await fileService.loadTodos();
    if (mounted) {
      setState(() {});
    }
  }

  // Them cong viec, ghi file va hen gio notification
  Future<void> addTodo() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      _showMessage('Vui lòng nhập tên công việc và chọn thời gian.');
      return;
    }

    if (!selectedTime!.isAfter(DateTime.now())) {
      _showMessage('Thời gian nhắc phải ở tương lai.');
      return;
    }

    final todo = Todo(
      title: controller.text.trim(),
      time: selectedTime!,
    );

    setState(() {
      todos.add(todo);
    });
    await fileService.saveTodos(todos);

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2000000000);
    await widget.notificationService.showNow(
      id: id,
      title: 'Đã lưu lịch công việc',
      body: 'Đã thêm lịch: ${todo.title}',
      channelId: 'todo_saved_channel',
      channelName: 'Đã lưu công việc',
    );
    await widget.notificationService.scheduleAt(
      id: id + 1,
      title: 'Nhắc công việc',
      body: todo.title,
      scheduledTime: todo.time,
      channelId: 'todo_reminder_channel',
      channelName: 'Nhắc công việc',
    );

    controller.clear();
    setState(() {
      selectedTime = null;
    });
    _showMessage('Đã lưu công việc và thiết lập lịch nhắc.');
  }

  // Chon ngay va gio thuc hien
  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Todo App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Tên công việc',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? 'Chưa chọn thời gian'
                        : formatTime(selectedTime!),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: pickDateTime,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Chọn thời gian'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTodo,
              child: const Text('Lưu'),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh sách công việc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text('Chưa có công việc nào.'))
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final bgColor = colors[index % colors.length];
                        return Card(
                          color: bgColor,
                          child: ListTile(
                            leading: const Icon(Icons.task_alt),
                            title: Text(
                              todo.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formatTime(todo.time)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
