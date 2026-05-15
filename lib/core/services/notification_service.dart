import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // 1. Request permissions for FCM
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Configure Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
      },
    );

    // Channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'streak_reminders', 
      'Streak Reminders', 
      description: 'Nhắc nhở học tập hàng ngày',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Handle Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Bật sẵn lịch nhắc nhở mặc định khi khởi tạo (sẽ tự động dời sang ngày mai nếu user học bài)
    await scheduleDailyStreakReminder();

    _isInitialized = true;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_reminders',
            'Streak Reminders',
            channelDescription: 'Nhắc nhở học tập hàng ngày',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  /// Đặt lịch thông báo hàng ngày lúc 20:00
  Future<void> scheduleDailyStreakReminder({bool startFromTomorrow = false}) async {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(20, 0);
    
    if (startFromTomorrow) {
      final now = tz.TZDateTime.now(tz.local);
      final todayAt20 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
      // Nếu scheduleDate trùng với 20:00 hôm nay, dời sang ngày mai
      if (scheduledDate.isAtSameMomentAs(todayAt20) || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    await _localNotifications.zonedSchedule(
      0, 
      'VitaminC - Đừng bỏ lỡ mục tiêu!',
      'Streak của bạn đang gặp nguy hiểm! Học ngay 5 thẻ nhé!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Nhắc nhở học tập hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, 
    );
    debugPrint('Đã lên lịch nhắc nhở Streak vào 20:00 hàng ngày (bắt đầu: $scheduledDate)');
  }

  /// Hủy thông báo
  Future<void> cancelStreakReminder() async {
    await _localNotifications.cancel(0);
    debugPrint('Đã hủy nhắc nhở Streak');
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
