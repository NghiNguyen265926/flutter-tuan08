import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final NotificationService notificationService;

  const AddTaskScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime? remindAt;

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Mo lich chon ngay va gio nhac
  Future<void> pickRemindTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      remindAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // Tao nhiem vu moi, hen gio neu nguoi dung da chon
  Future<void> saveTask() async {
    if (titleController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập tên nhiệm vụ.');
      return;
    }

    if (remindAt != null && !remindAt!.isAfter(DateTime.now())) {
      _showMessage('Thời gian nhắc phải ở tương lai.');
      return;
    }

    final task = TaskItem(
      title: titleController.text.trim(),
      note: noteController.text.trim(),
      remindAt: remindAt,
    );

    if (remindAt != null) {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(2000000000);
      await widget.notificationService.scheduleAt(
        id: id,
        title: 'Nhắc nhiệm vụ',
        body: task.title,
        scheduledTime: remindAt!,
        channelId: 'todolist_reminder_channel',
        channelName: 'Nhắc nhiệm vụ TodoList',
      );
    }

    if (mounted) {
      Navigator.pop(context, task);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhiệm vụ')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Tên nhiệm vụ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả (không bắt buộc)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.blue),
              title: const Text('Thời gian thông báo'),
              subtitle: Text(
                remindAt == null
                    ? 'Chưa thiết lập'
                    : DateFormat('dd/MM/yyyy HH:mm').format(remindAt!),
              ),
              trailing: IconButton(
                onPressed: pickRemindTime,
                icon: const Icon(Icons.calendar_month),
                tooltip: 'Chọn ngày và giờ',
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saveTask,
              icon: const Icon(Icons.save),
              label: const Text('Lưu nhiệm vụ'),
            ),
          ),
        ],
      ),
    );
  }
}
