import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance =
      NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(
  tz.getLocation('Asia/Kolkata'),
);

  const androidSettings =
      AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const settings =
      InitializationSettings(
    android: androidSettings,
  );

  await notifications.initialize(
    settings,
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

  Future<void> showTestNotification() async {
    await notifications.show(
      1,
      'Glucose Logger',
      'Time to log your glucose reading 🩸',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'glucose_channel',
          'Glucose Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  Future<void> scheduleDailyReminder({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  print("NOW: $now");
  print("LOCAL TZ: ${tz.local}");
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(
      const Duration(days: 1),
    );
  }
  print("Scheduling notification");
  print("Hour: $hour");
  print("Minute: $minute");
  print("Scheduled date: $scheduledDate");

  await notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.now(tz.local)
    .add(const Duration(seconds: 10)),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'glucose_channel',
        'Glucose Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode:
        AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: null,
  );
}
Future<void> scheduleDailyReminders() async {
  await scheduleDailyReminder(
    id: 101,
    title: 'Glucose Logger',
    body: 'Did you record your latest glucose reading?',
    hour: DateTime.now().hour,

    minute: DateTime.now().minute + 1,
  );

  await scheduleDailyReminder(
    id: 102,
    title: 'Glucose Logger',
    body: 'Don\'t forget today\'s readings.',
    hour: 14,
    minute: 0,
  );

  await scheduleDailyReminder(
    id: 103,
    title: 'Glucose Logger',
    body: 'Record your glucose readings for today.',
    hour: 19,
    minute: 0,
  );

  await scheduleDailyReminder(
    id: 104,
    title: 'Glucose Logger',
    body: 'Missing logs? Add them before bed.',
    hour: 22,
    minute: 30,
  );
}
Future<void> printPendingNotifications() async {
  final pending =
      await notifications.pendingNotificationRequests();

  print(
    "Pending notifications count: ${pending.length}",
  );

  for (final n in pending) {
    print(
      "ID: ${n.id} Title: ${n.title}",
    );
  }
}
}
// test github contribution