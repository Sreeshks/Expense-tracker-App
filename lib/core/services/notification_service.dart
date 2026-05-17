import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  Future<void> showBudgetAlert({
    required double currentTotal,
    required double threshold,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Alerts when spending exceeds budget limit',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Budget Limit Exceeded!',
      'Your expenses this month: ₹${currentTotal.toStringAsFixed(0)} '
          '(limit: ₹${threshold.toStringAsFixed(0)})',
      details,
    );
  }
}
