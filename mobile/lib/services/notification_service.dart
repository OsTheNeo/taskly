import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'data_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message: ${message.messageId}');
}

/// Tipo de callback para manejar navegación a tarea desde notificación
typedef OnNotificationTapCallback = void Function(String taskId);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DataService _dataService = DataService();

  bool _initialized = false;
  String? _fcmToken;
  String? _currentUserUid;
  OnNotificationTapCallback? _onNotificationTap;

  String? get fcmToken => _fcmToken;

  /// Establece el callback para manejar taps en notificaciones
  void setOnNotificationTap(OnNotificationTapCallback callback) {
    _onNotificationTap = callback;
  }

  /// Establece el UID del usuario actual para actualizar el token FCM
  void setCurrentUserUid(String? uid) {
    _currentUserUid = uid;
    // Si ya tenemos el token y ahora tenemos el uid, actualizar en Supabase
    if (uid != null && _fcmToken != null) {
      _updateTokenInSupabase(_fcmToken!);
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications
    await _initLocalNotifications();

    // Initialize FCM
    await _initFirebaseMessaging();

    _initialized = true;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initFirebaseMessaging() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await requestPermissions();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('[NotificationService] FCM Token: $_fcmToken');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('[NotificationService] FCM Token refreshed: $newToken');
      _updateTokenInSupabase(newToken);
    });

    // Guardar el token inicial en Supabase si tenemos usuario
    if (_fcmToken != null) {
      _updateTokenInSupabase(_fcmToken!);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[NotificationService] Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      // Show local notification when app is in foreground
      showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Taskly',
        body: notification.body ?? '',
        payload: message.data['taskId'],
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[NotificationService] Message opened app: ${message.data}');
    final taskId = message.data['taskId'] as String?;
    if (taskId != null && _onNotificationTap != null) {
      _onNotificationTap!(taskId);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notification tapped: ${response.payload}');
    final taskId = response.payload;
    if (taskId != null && taskId.isNotEmpty && _onNotificationTap != null) {
      _onNotificationTap!(taskId);
    }
  }

  /// Actualiza el token FCM en Supabase
  Future<void> _updateTokenInSupabase(String token) async {
    if (_currentUserUid == null) return;
    await _dataService.updateProfileFcmToken(
      firebaseUid: _currentUserUid!,
      fcmToken: token,
    );
  }

  Future<bool> requestPermissions() async {
    // Request FCM permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('[NotificationService] FCM permission: ${settings.authorizationStatus}');

    // Request local notification permissions
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
    } else if (Platform.isIOS) {
      final iosImpl = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }

    return granted;
  }

  /// Subscribe to a topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('[NotificationService] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('[NotificationService] Unsubscribed from topic: $topic');
  }

  /// Subscribe to household/group notifications
  Future<void> subscribeToHousehold(String householdId) async {
    await subscribeToTopic('household_$householdId');
  }

  /// Unsubscribe from household/group notifications
  Future<void> unsubscribeFromHousehold(String householdId) async {
    await unsubscribeFromTopic('household_$householdId');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taskly_notifications',
      'Taskly Notifications',
      channelDescription: 'Task reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taskly_reminders',
      'Task Reminders',
      channelDescription: 'Scheduled task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule a daily notification at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taskly_daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling notification: $e');
      // Notification scheduling failed, but don't crash the app
    }
  }

  /// Schedule a task reminder
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required TimeOfDay reminderTime,
    List<int>? weekDays, // 1=Mon, 7=Sun. If null, daily
  }) async {
    // Use taskId hash as notification ID
    final notificationId = taskId.hashCode;

    if (weekDays != null && weekDays.isNotEmpty) {
      // Schedule for specific days
      for (final day in weekDays) {
        await _scheduleWeeklyNotification(
          id: notificationId + day,
          title: 'Recordatorio: $taskTitle',
          body: 'Es hora de completar tu tarea',
          time: reminderTime,
          weekday: day,
          payload: taskId,
        );
      }
    } else {
      // Schedule daily
      await scheduleDailyNotification(
        id: notificationId,
        title: 'Recordatorio: $taskTitle',
        body: 'Es hora de completar tu tarea',
        time: reminderTime,
        payload: taskId,
      );
    }
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required int weekday,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taskly_weekly_reminders',
      'Weekly Reminders',
      channelDescription: 'Weekly task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Find next occurrence of this weekday
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Adjust to the correct weekday (1=Mon, 7=Sun)
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling weekly notification: $e');
    }
  }

  /// Cancel a task's reminder
  Future<void> cancelTaskReminder(String taskId, {List<int>? weekDays}) async {
    final notificationId = taskId.hashCode;

    if (weekDays != null && weekDays.isNotEmpty) {
      for (final day in weekDays) {
        await _localNotifications.cancel(notificationId + day);
      }
    } else {
      await _localNotifications.cancel(notificationId);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _localNotifications.pendingNotificationRequests();
  }
}
