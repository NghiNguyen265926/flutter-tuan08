import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationDemoScreen extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationDemoScreen({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Noti Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active,
                  size: 72, color: Colors.blue),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await notificationService.showNow(
                    id: 101,
                    title: 'Nhắc học từ vựng',
                    body: 'Bạn đã học 5 từ mới hôm nay chưa?',
                    channelId: 'learn_english_channel',
                    channelName: 'Học Anh Văn',
                  );
                },
                child: const Text('Gửi thông báo nhắc học Ngoại ngữ'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await notificationService.scheduleAfter(
                    id: 102,
                    title: 'Uống nước',
                    body: 'Nhắc uống nước đúng giờ',
                    delay: const Duration(minutes: 2),
                    channelId: 'drink_water_channel',
                    channelName: 'Uống nước',
                  );
                  _showMessage(context, 'Đã hẹn giờ nhắc uống nước sau 2 phút.');
                },
                child: const Text('Gửi thông báo nhắc uống nước sau 2 phút'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await notificationService.scheduleAfter(
                    id: 103,
                    title: 'Nhắc học Ngoại ngữ',
                    body: 'Đã đến giờ ôn tập từ vựng.',
                    delay: const Duration(minutes: 10),
                    channelId: 'learn_english_later_channel',
                    channelName: 'Nhắc học Ngoại ngữ',
                  );
                  _showMessage(
                    context,
                    'Đã hẹn giờ nhắc học Ngoại ngữ sau 10 phút.',
                  );
                },
                child: const Text(
                  'Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
