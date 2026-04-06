import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'responder_alerts_channel',
    'responder alerts',
    description: 'alerts for incoming incidents',
    importance: Importance.max,
    playSound: true,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // request notification permission
    await _messaging.requestPermission();

    // initialize local notifications
    await _initializeLocalNotifications();

    // get and save fcm token
    await _handleToken();

    // listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('foreground message: ${message.data}');
      await _showNotificationFromRemoteMessage(message);
    });

    // listen when user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('notification tapped: ${message.data}');
      // todo: navigate to specific screen if needed
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidInit,
    );

    await _localNotifications.initialize(
      settings: settings,
    );

    // create notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _handleToken() async {
    final token = await _messaging.getToken();

    if (token != null) {
      debugPrint('fcm token: $token');
      await _saveToken(token);
    }

    // listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('fcm token refreshed: $newToken');
      await _saveToken(newToken);
    });
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final query = await FirebaseFirestore.instance
        .collection('responders')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      debugPrint('no responder doc found for this uid');
      return;
    }

    final docId = query.docs.first.id;

    await FirebaseFirestore.instance
        .collection('responders')
        .doc(docId)
        .update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('fcm token saved to responder doc');
  }

  Future<void> _showNotificationFromRemoteMessage(
    RemoteMessage message,
  ) async {
    final data = message.data;

    final title = data['title'] ?? 'new alert';
    final body = data['body'] ?? 'incident reported';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('alert1'),
      ),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: data.toString(),
    );
  }
}