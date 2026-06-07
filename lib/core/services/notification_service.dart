import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:vitaminc/core/services/local_db_service.dart';
import 'package:vitaminc/routing/app_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // v21.0.0: all parameters are now named
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
        if (response.payload != null) {
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            context.go(response.payload!);
          }
        }
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
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
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
      // v21.0.0: all parameters are now named
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
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
  Future<void> scheduleDailyStreakReminder({
    bool startFromTomorrow = false,
  }) async {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(20, 0);

    if (startFromTomorrow) {
      final now = tz.TZDateTime.now(tz.local);
      final todayAt20 = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20,
        0,
      );
      // Nếu scheduleDate trùng với 20:00 hôm nay, dời sang ngày mai
      if (scheduledDate.isAtSameMomentAs(todayAt20) ||
          scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    // v21.0.0: all parameters are now named; UILocalNotificationDateInterpretation removed
    await _localNotifications.zonedSchedule(
      id: 0,
      title: 'VitaminC - Đừng bỏ lỡ mục tiêu!',
      body: 'Streak của bạn đang gặp nguy hiểm! Học ngay 5 thẻ nhé!',
      payload: '/library',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Nhắc nhở học tập hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint(
      'Đã lên lịch nhắc nhở Streak vào 20:00 hàng ngày (bắt đầu: $scheduledDate)',
    );
  }

  /// Hủy thông báo Streak
  Future<void> cancelStreakReminder() async {
    // v21.0.0: cancel() now uses named parameter
    await _localNotifications.cancel(id: 0);
    debugPrint('Đã hủy nhắc nhở Streak');
  }

  /// Lên lịch thông báo từ vựng ngẫu nhiên lúc 12:00 trưa mỗi ngày (Học bị động)
  /// Lấy 1 từ ngẫu nhiên từ Local DB để hiển thị trên màn hình khóa
  Future<void> scheduleVocabReminder(LocalDbService localDb) async {
    String title = '📚 VitaminC - Từ vựng hôm nay';
    String body = 'Mở app để học từ mới nhé!';

    try {
      final allCards = localDb.getLocalDueCards();
      if (allCards.isNotEmpty) {
        final randomCard = allCards[Random().nextInt(allCards.length)];
        title = '📚 Từ vựng: ${randomCard.word}';
        body = randomCard.meaning;
        if (randomCard.example != null && randomCard.example!.isNotEmpty) {
          body += ' — VD: ${randomCard.example}';
        }
      }
    } catch (e) {
      debugPrint('Lỗi lấy vocab cho notification: $e');
    }

    final scheduledDate = _nextInstanceOfTime(12, 0);

    await _localNotifications.zonedSchedule(
      id: 1, // ID = 1 (khác ID = 0 của Streak reminder)
      title: title,
      body: body,
      payload: '/home',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vocab_reminders',
          'Vocab Reminders',
          channelDescription: 'Nhắc nhở từ vựng hàng ngày',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Đã lên lịch nhắc từ vựng lúc 12:00 (từ: $title)');
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Lên lịch thông báo test sau 15 giây để test chức năng Deep Link
  Future<void> scheduleTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 15));

    await _localNotifications.zonedSchedule(
      id: 99,
      title: 'VitaminC - Test Deep Link',
      body:
          'Bấm vào đây để xem app có tự động mở và nhảy sang màn Thư viện (Library) hay không!',
      payload: '/library',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Kênh test thông báo',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('Đã hẹn thông báo test sau 15 giây.');
  }
}
