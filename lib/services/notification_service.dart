import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Khoi tao timezone, plugin va xin quyen hien thi thong bao
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    await _requestPermission();
  }

  // Yeu cau quyen notification tren thiet bi
  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // Tao thong tin hien thi chung cho cac notification Android
  AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  // Hien thi thong bao ngay lap tuc
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String channelId = 'bai08_general_channel',
    String channelName = 'Thong bao Bai 08',
    String? channelDescription,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: details),
    );
  }

  // Hen gio hien thi notification tai thoi diem duoc chon
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = 'bai08_schedule_channel',
    String channelName = 'Lich nhac Bai 08',
    String? channelDescription,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: details),
      // Dung che do khong can quyen exact alarm rieng tren Android.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

  }

  // Hen gio sau mot khoang thoi gian
  Future<void> scheduleAfter({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String channelId = 'bai08_schedule_channel',
    String channelName = 'Lich nhac Bai 08',
    String? channelDescription,
  }) async {
    await scheduleAt(
      id: id,
      title: title,
      body: body,
      scheduledTime: DateTime.now().add(delay),
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );
  }

  // Lay danh sach notification dang cho hien thi
  Future<List<PendingNotificationRequest>> getPendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  // Huy mot notification theo ID
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // Huy tat ca notification dang cho
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
