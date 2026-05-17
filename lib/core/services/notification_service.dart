import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Request notification permissions for Android 13+
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
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

  Future<void> showOtpNotification({required String otp}) async {
    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'OTP Notifications',
      channelDescription: 'Shows OTP verification codes',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      'Your OTP Code',
      'Your verification code is: $otp',
      details,
    );
  }
}
