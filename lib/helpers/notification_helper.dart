import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'dart:async';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  final Map<int, Timer> _timers = {};

  Future<void> init() async {
    if (_initialized) return;
    try {
      final String localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'todo_channel_id',
        'Todo Reminders',
        description: 'Channel for Todo List reminders',
        importance: Importance.max,
      ),
    );

    await requestPermissions();
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
       await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    await init();
    final DateTime now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      // If the time already passed, trigger shortly instead of skipping.
      final DateTime fallback = now.add(const Duration(seconds: 5));
      await _scheduleWithFallback(id, title, body, fallback);
      _scheduleInAppFallback(id, title, body, fallback);
      return;
    }

    await _scheduleWithFallback(id, title, body, scheduledTime);
    _scheduleInAppFallback(id, title, body, scheduledTime);
  }

  Future<void> cancelNotification(int id) async {
    await init();
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _scheduleWithFallback(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_channel_id',
        'Todo Reminders',
        channelDescription: 'Channel for Todo List reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fallback for devices that fail zoned scheduling.
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _scheduleInAppFallback(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) {
    final Duration delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;
    _timers[id]?.cancel();
    _timers[id] = Timer(delay, () async {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel_id',
            'Todo Reminders',
            channelDescription: 'Channel for Todo List reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }
}
