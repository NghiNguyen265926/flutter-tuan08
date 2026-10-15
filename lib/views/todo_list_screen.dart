import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';
import 'pending_notifications_screen.dart';

class TodoListScreen extends StatefulWidget {
  final NotificationService notificationService;

  const TodoListScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskService taskService = TaskService();
  List<TaskItem> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await taskService.loadTasks();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Mo man hinh them nhiem vu va luu vao file sau khi quay lai
  Future<void> openAddTask() async {
    final task = await Navigator.push<TaskItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          notificationService: widget.notificationService,
        ),
      ),
    );

    if (task != null) {
      setState(() {
        tasks.add(task);
      });
      await taskService.saveTasks(tasks);
      _showMessage('Đã lưu nhiệm vụ vào file.');
    }
  }

  // Hoi xac nhan truoc khi danh dau nhiem vu da hoan thanh
  Future<void> confirmCompleted(int index) async {
    final task = tasks[index];
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hoàn thành'),
        content: Text('Bạn xác nhận nhiệm vụ "${task.title}" đã hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Chưa'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đã hoàn thành'),
          ),
        ],
      ),
    );

    if (answer != true) return;

    setState(() {
      tasks[index].completed = true;
    });
    await taskService.saveTasks(tasks);

    final completedCount = tasks.where((item) => item.completed).length;
    await widget.notificationService.showNow(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2000000000),
      title: 'Cập nhật nhiệm vụ',
      body: 'Bạn đã hoàn thành $completedCount nhiệm vụ.',
      channelId: 'todolist_completed_channel',
      channelName: 'Thống kê nhiệm vụ hoàn thành',
    );
    _showMessage('Đã cập nhật trạng thái hoàn thành.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((item) => item.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoList'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTask,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Text(
                    'Đã hoàn thành $completedCount/${tasks.length} nhiệm vụ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Text('Chưa có nhiệm vụ. Nhấn + để thêm.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: task.completed
                                      ? null
                                      : (_) => confirmCompleted(index),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.note.isNotEmpty) Text(task.note),
                                    if (task.remindAt != null)
                                      Text(
                                        'Nhắc: ${DateFormat('dd/MM/yyyy HH:mm').format(task.remindAt!)}',
                                      ),
                                  ],
                                ),
                                trailing: Icon(
                                  task.remindAt == null
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: task.remindAt == null
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
