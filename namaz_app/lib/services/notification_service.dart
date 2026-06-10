import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

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

    // 3. Configure iOS settings (do NOT request permissions on startup)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
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
  }

  // Request permissions on demand
  Future<void> requestPermissions() async {
    // For iOS/macOS/Darwin
    final iosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // For Android 13+ (SDK 33+)
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
      // Do not request exact alarm permission here as it redirects the user
      // to settings on Android 13/14+ which is disruptive during onboarding.
      // Exact alarms will work if pre-granted, or fallback to inexact in schedule.
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

    final prefs = await SharedPreferences.getInstance();
    final bool imsakEnabled = prefs.getBool('notification_prayer_imsak') ?? true;
    final bool sabahEnabled = prefs.getBool('notification_prayer_sabah') ?? true; // Maps to Güneş
    final bool ogleEnabled = prefs.getBool('notification_prayer_ogle') ?? true;
    final bool ikindiEnabled = prefs.getBool('notification_prayer_ikindi') ?? true;
    final bool aksamEnabled = prefs.getBool('notification_prayer_aksam') ?? true;
    final bool yatsiEnabled = prefs.getBool('notification_prayer_yatsi') ?? true;
    final bool soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
    final int offset = prefs.getInt('notification_timing_offset') ?? 0;

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
        // Filter by settings
        bool isPrayerEnabled = true;
        if (prayerName == 'İmsak') {
          isPrayerEnabled = imsakEnabled;
        } else if (prayerName == 'Güneş') {
          isPrayerEnabled = sabahEnabled;
        } else if (prayerName == 'Öğle') {
          isPrayerEnabled = ogleEnabled;
        } else if (prayerName == 'İkindi') {
          isPrayerEnabled = ikindiEnabled;
        } else if (prayerName == 'Akşam') {
          isPrayerEnabled = aksamEnabled;
        } else if (prayerName == 'Yatsı') {
          isPrayerEnabled = yatsiEnabled;
        }

        if (!isPrayerEnabled) continue;

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

        // Subtract offset to get the scheduled time
        final scheduledDate = DateTime(year, month, day, hour, minute)
            .subtract(Duration(minutes: offset));

        // Only schedule future notifications
        if (scheduledDate.isAfter(now)) {
          final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

          // Configure sound - use separate channels for adhan vs default
          // Android notification channels are immutable after creation,
          // so we need different channel IDs for different sound configs
          final AndroidNotificationDetails androidDetails = soundEnabled
              ? const AndroidNotificationDetails(
                  'adhan_sound_channel',
                  'Ezan Alarmları (Ezan Sesli)',
                  channelDescription:
                      'Ezan vakitlerinde ezan sesi ile bildirim gönderir.',
                  importance: Importance.max,
                  priority: Priority.high,
                  sound: RawResourceAndroidNotificationSound('adhan'),
                  playSound: true,
                )
              : const AndroidNotificationDetails(
                  'adhan_default_channel',
                  'Ezan Alarmları (Varsayılan Ses)',
                  channelDescription:
                      'Ezan vakitlerinde varsayılan bildirim sesi ile bildirim gönderir.',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                );

          // iOS custom sound config (expects adhan.mp3 in App Bundle resources)
          final DarwinNotificationDetails iosDetails =
              DarwinNotificationDetails(
                sound: soundEnabled ? 'adhan.wav' : 'default',
                presentSound: true,
                presentAlert: true,
                presentBadge: true,
              );

          final NotificationDetails platformDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          try {
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
          } catch (e) {
            print("Failed to schedule exact alarm, falling back to inexact: $e");
            try {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                id: notificationId - 1,
                title: 'Ezan Vakti ($prayerName)',
                body:
                    'Günün bu kutsal vaktinde ibadete davet. $prayerName vakti girdi.',
                scheduledDate: tzScheduledDate,
                notificationDetails: platformDetails,
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
                payload: prayerName,
              );
            } catch (innerEx) {
              print("Failed to schedule inexact alarm: $innerEx");
            }
          }

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
    // Request permission first to ensure dialog pops up if needed
    await requestPermissions();

    final prefs = await SharedPreferences.getInstance();
    final bool soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;

    // Use separate channels for adhan vs default sound (Android channels are immutable)
    final AndroidNotificationDetails androidDetails = soundEnabled
        ? const AndroidNotificationDetails(
            'test_adhan_channel',
            'Test Bildirimleri (Ezan Sesli)',
            channelDescription:
                'Ezan bildirim sesini test etmek için kullanılır.',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('adhan'),
            playSound: true,
          )
        : const AndroidNotificationDetails(
            'test_default_channel',
            'Test Bildirimleri (Varsayılan Ses)',
            channelDescription:
                'Varsayılan bildirim sesini test etmek için kullanılır.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: soundEnabled ? 'adhan.wav' : 'default',
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
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
