import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezone database
    tz.initializeTimeZones();
    // Default to Europe/Istanbul (Turkey time)
    final istanbul = tz.getLocation('Europe/Istanbul');
    tz.setLocalLocation(istanbul);

    // 2. Configure Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configure iOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 4. Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("Notification clicked: ${details.payload}");
      },
    );

    // 5. Request permissions for Android 13+ (SDK 33+)
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // Cancel all pending notifications
  Future<void> cancelAllAlarms() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Schedule alarms for upcoming prayer times
  Future<void> schedulePrayerAlarms(
    List<Map<String, dynamic>> prayerTimes,
  ) async {
    // First cancel existing to prevent duplicates
    await cancelAllAlarms();

    final now = DateTime.now();
    int notificationId = 100;

    // Define prayer names for display
    const List<String> prayers = [
      'İmsak',
      'Güneş',
      'Öğle',
      'İkindi',
      'Akşam',
      'Yatsı',
    ];

    // Schedule for the next 7 days in the cached times list
    int scheduledCount = 0;
    for (var dayTime in prayerTimes) {
      final String? dateStr = dayTime['MiladiTarihKisa']; // e.g. "21.05.2026"
      if (dateStr == null) continue;

      // Parse date parts
      final parts = dateStr.split('.');
      if (parts.length != 3) continue;
      final int day = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int year = int.parse(parts[2]);

      for (var prayerName in prayers) {
        final String? timeStr =
            dayTime[prayerName == 'Öğle'
                ? 'Ogle'
                : prayerName == 'İkindi'
                ? 'Ikindi'
                : prayerName == 'Akşam'
                ? 'Aksam'
                : prayerName == 'Yatsı'
                ? 'Yatsi'
                : prayerName == 'Güneş'
                ? 'Gunes'
                : 'Imsak'];
        if (timeStr == null) continue;

        // Parse time parts
        final timeParts = timeStr.split(':');
        if (timeParts.length != 2) continue;
        final int hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);

        final scheduledDate = DateTime(year, month, day, hour, minute);

        // Only schedule future notifications
        if (scheduledDate.isAfter(now)) {
          final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

          // Configure sound
          // Android: Uses the resource raw/adhan.mp3 (without extension)
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
                'adhan_alarms_channel',
                'Ezan Alarmları',
                channelDescription:
                    'Ezan vakitlerinde kısa ezan sesi ile bildirim gönderir.',
                importance: Importance.max,
                priority: Priority.high,
                sound: RawResourceAndroidNotificationSound('adhan'),
                playSound: true,
              );

          // iOS custom sound config (expects adhan.mp3 in App Bundle resources)
          const DarwinNotificationDetails iosDetails =
              DarwinNotificationDetails(
                sound: 'adhan.mp3',
                presentSound: true,
                presentAlert: true,
                presentBadge: true,
              );

          const NotificationDetails platformDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            id: notificationId++,
            title: 'Ezan Vakti ($prayerName)',
            body:
                'Günün bu kutsal vaktinde ibadete davet. $prayerName vakti girdi.',
            scheduledDate: tzScheduledDate,
            notificationDetails: platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: prayerName,
          );

          scheduledCount++;
          // Cap it at 50 notifications to prevent OS limits
          if (scheduledCount >= 50) return;
        }
      }
    }
    print("Scheduled $scheduledCount alarms.");
  }

  // Play test alarm for user feedback
  Future<void> playTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_alarms_channel',
          'Test Bildirimleri',
          channelDescription:
              'Ezan bildirim sesini test etmek için kullanılır.',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'adhan.mp3',
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: 'Ezan Sesi Testi',
      body: 'Kısa ezan sesi başarıyla çalınıyor.',
      notificationDetails: platformDetails,
    );
  }
}
