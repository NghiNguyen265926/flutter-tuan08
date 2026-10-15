import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

class PendingNotificationsScreen extends StatefulWidget {
  final NotificationService notificationService;

  const PendingNotificationsScreen({
    super.key,
    required this.notificationService,
  });

  @override
  State<PendingNotificationsScreen> createState() =>
      _PendingNotificationsScreenState();
}

class _PendingNotificationsScreenState
    extends State<PendingNotificationsScreen> {
  late Future<List<PendingNotificationRequest>> pendingFuture;

  @override
  void initState() {
    super.initState();
    pendingFuture = widget.notificationService.getPendingNotifications();
  }

  Future<void> refreshList() async {
    setState(() {
      pendingFuture = widget.notificationService.getPendingNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch nhắc đang chờ'),
        actions: [
          IconButton(
            onPressed: refreshList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<PendingNotificationRequest>>(
        future: pendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không có lịch nhắc nào đang chờ hiển thị.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active,
                      color: Colors.blue),
                  title: Text(item.title ?? '(Không có tiêu đề)'),
                  subtitle: Text(item.body ?? ''),
                  trailing: Text('ID ${item.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
