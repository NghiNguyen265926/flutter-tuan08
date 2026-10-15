
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_6/main.dart';
import 'package:flutter_application_6/services/notification_service.dart';

// Tao service gia de test giao dien.
// Khong goi plugin thong bao that khi chay widget test.
class FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {
    // Khong can khoi tao plugin trong bai test.
  }
}

void main() {
  testWidgets('MyApp hien thi giao dien', (
    WidgetTester tester,
  ) async {
    // Khoi tao ung dung voi service gia.
    await tester.pumpWidget(
      MyApp(
        notificationService: FakeNotificationService(),
      ),
    );

    // Kiem tra ung dung co MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
