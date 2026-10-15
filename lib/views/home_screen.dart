import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'notification_demo_screen.dart';
import 'todo_screen.dart';
import 'vocab_home_screen.dart';
import 'todo_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final NotificationService notificationService;

  const HomeScreen({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài 08 - Notification và File'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chọn bài thực hành',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ứng dụng tổng hợp các bài trong tài liệu Bài 08. '
            'Dữ liệu được lưu cục bộ trên thiết bị.',
          ),
          const SizedBox(height: 16),
          _menuCard(
            context,
            icon: Icons.notifications_active,
            title: 'Bài tập 1 - Notification',
            subtitle: 'Gửi thông báo ngay, nhắc uống nước sau 2 phút, '
                'nhắc học sau 10 phút.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationDemoScreen(
                  notificationService: notificationService,
                ),
              ),
            ),
          ),
          _menuCard(
            context,
            icon: Icons.event_note,
            title: 'Bài tập 2 và 3 - Todo + Notification',
            subtitle: 'Chọn ngày giờ, lưu todo.txt và đặt lịch nhắc công việc.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TodoScreen(
                  notificationService: notificationService,
                ),
              ),
            ),
          ),
          _menuCard(
            context,
            icon: Icons.menu_book,
            title: 'Bài tập 4 - Học từ vựng',
            subtitle: 'Lưu từ, nhắc ôn tập, học từ, kiểm tra và xem lịch nhắc.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabHomeScreen(
                  notificationService: notificationService,
                ),
              ),
            ),
          ),
          _menuCard(
            context,
            icon: Icons.checklist,
            title: 'Bài tập về nhà - TodoList',
            subtitle: 'Thêm nhiệm vụ, chọn giờ nhắc và xác nhận hoàn thành.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TodoListScreen(
                  notificationService: notificationService,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
