// lib/core/services/local_notification_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  
  // Store scheduled notification IDs for management
  final Map<String, List<int>> _medicineNotificationIds = {};

  // WorkManager callback dispatcher
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await LocalNotificationService()._executeBackgroundTask(task, inputData);
      return Future.value(true);
    });
  }

  Future<void> _executeBackgroundTask(String task, Map<String, dynamic>? inputData) async {
    if (task == 'medicine_reminder') {
      await initialize();
      await showImmediateNotification(
        medicineId: inputData?['medicineId'] ?? '',
        medicineName: inputData?['medicineName'] ?? 'Medicine',
        dosage: inputData?['dosage'] ?? '',
      );
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    
    // ✅ ANDROID: Set up notification icon and channel
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ✅ IOS: Set up notification settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    // ✅ ANDROID: Request permission for Android 13+
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // ✅ Initialize WorkManager for background tasks (Android)
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    }

    // ✅ IOS: Request permissions
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;
    print('✅ Local Notification Service Initialized for ${Platform.operatingSystem}');
  }

  // Called when notification is received while app is in foreground (iOS only)
  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print('📱 Foreground notification received on iOS: $title');
  }

  // Called when user taps on notification
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    print('📱 Notification tapped with payload: $payload');
    
    // Handle notification action (Take Medicine / Snooze)
    if (response.actionId == 'take') {
      print('✅ User tapped TAKE MEDICINE');
      // Navigate to medicine screen or mark as taken
    } else if (response.actionId == 'snooze') {
      print('⏰ User tapped SNOOZE');
      // Schedule snooze notification
    }
  }

  // Called when notification is received in background
  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) async {
    print('📱 Background notification tapped: ${response.payload}');
  }

  // ✅ Schedule medicine reminder (Works on both Android & iOS)
  Future<void> scheduleMedicineReminder({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required int hour,
    required int minute,
    required List<int> daysOfWeek, // 1=Monday, 7=Sunday
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    
    for (var day in daysOfWeek) {
      var scheduledDate = _nextInstanceOfDayAndTime(now, day, hour, minute);
      
      final notificationId = _generateNotificationId(medicineId, hour, minute, day);
      
      // Store notification ID for this medicine
      if (!_medicineNotificationIds.containsKey(medicineId)) {
        _medicineNotificationIds[medicineId] = [];
      }
      _medicineNotificationIds[medicineId]!.add(notificationId);

      // ✅ ANDROID: Notification details with actions
      final androidDetails = AndroidNotificationDetails(
        'medicine_reminder_channel',
        'Medicine Reminders',
        channelDescription: 'Reminders to take your medicine on time',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        fullScreenIntent: true,
        ongoing: false,
        autoCancel: true,
        category: AndroidNotificationCategory.alarm,
        actions: [
          const AndroidNotificationAction(
            'take',
            '✅ Take Medicine',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            '⏰ Snooze 15 min',
            showsUserInterface: false,
          ),
        ],
      );

      // ✅ IOS: Notification details with interruption level for time-sensitive
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'medicine_reminder',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // ✅ Schedule notification (works on both platforms)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '💊 Time to take $medicineName',
        'Take $dosage of $medicineName now. Don\'t miss your dose!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'medicine_$medicineId',
      );

      print('✅ [${Platform.operatingSystem}] Scheduled reminder for $medicineName at $hour:$minute on day $day');
    }
  }

  // ✅ Schedule all medicine reminders
  Future<void> scheduleAllMedicineReminders(List<Map<String, dynamic>> medicines) async {
    await cancelAllMedicineReminders();
    
    for (var medicine in medicines) {
      final medicineId = medicine['id']?.toString() ?? '';
      final medicineName = medicine['name']?.toString() ?? 'Medicine';
      final dosage = medicine['dosage']?.toString() ?? '';
      final times = (medicine['times'] as List<dynamic>?) ?? [];
      
      if (medicineId.isEmpty || times.isEmpty) continue;
      
      for (var timeStr in times) {
        final parsedTime = _parseTimeString(timeStr.toString());
        if (parsedTime != null) {
          await scheduleMedicineReminder(
            medicineId: medicineId,
            medicineName: medicineName,
            dosage: dosage,
            hour: parsedTime['hour']!,
            minute: parsedTime['minute']!,
            daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Daily
          );
        }
      }
    }
    
    print('✅ [${Platform.operatingSystem}] Scheduled ${_medicineNotificationIds.length} medicine reminders');
  }

  // ✅ Show immediate notification (works on both platforms)
  Future<void> showImmediateNotification({
    required String medicineId,
    required String medicineName,
    required String dosage,
  }) async {
    if (!_initialized) await initialize();

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    final androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      '💊 Time to take $medicineName',
      'Take $dosage of $medicineName now',
      notificationDetails,
      payload: 'medicine_$medicineId',
    );
  }

  // ✅ Cancel reminders for a specific medicine
  Future<void> cancelMedicineReminders(String medicineId) async {
    final notificationIds = _medicineNotificationIds[medicineId] ?? [];
    for (var id in notificationIds) {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
    _medicineNotificationIds.remove(medicineId);
    print('🗑️ [${Platform.operatingSystem}] Cancelled reminders for medicine: $medicineId');
  }

  // ✅ Cancel all medicine reminders
  Future<void> cancelAllMedicineReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _medicineNotificationIds.clear();
    print('🗑️ [${Platform.operatingSystem}] Cancelled all medicine reminders');
  }

  // ✅ Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Helper: Calculate next occurrence of a specific day and time
  tz.TZDateTime _nextInstanceOfDayAndTime(
      tz.TZDateTime now, int targetDay, int hour, int minute) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    
    int currentDay = now.weekday;
    int daysToAdd = (targetDay - currentDay) % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    
    scheduledDate = scheduledDate.add(Duration(days: daysToAdd));
    
    if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  // Helper: Parse time string like "8:00 AM" or "14:00"
  Map<String, int>? _parseTimeString(String timeStr) {
    try {
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final period = parts[1];
        
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
        
        return {'hour': hour, 'minute': minute};
      }
      
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return {
          'hour': int.parse(parts[0]),
          'minute': int.parse(parts[1])
        };
      }
    } catch (e) {
      print('❌ Error parsing time: $timeStr - $e');
    }
    return null;
  }

  int _generateNotificationId(String medicineId, int hour, int minute, int day) {
    final hash = '$medicineId-$hour-$minute-$day'.hashCode;
    return hash.abs() % 100000;
  }
}