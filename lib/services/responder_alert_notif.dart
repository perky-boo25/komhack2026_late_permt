import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class RealtimeResponderAlertService {
  RealtimeResponderAlertService._();

  static final RealtimeResponderAlertService instance =
      RealtimeResponderAlertService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incidentSubscription;

  final Set<String> _alreadyAlertedIds = {};
  bool _initialized = false;
  bool _processedInitialSnapshot = false;

  /// Call once before listening.
  Future<void> initialize() async {
    if (_initialized) return;

    await _requestNotificationPermission();
    await _initializeLocalNotifications();

    _initialized = true;
    debugPrint('Responder alert service initialized');
  }

  /// Start Firestore real-time listening for the logged-in responder.
  Future<void> startListening() async {
    await initialize();

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('No logged-in responder found.');
      return;
    }

    final responderDoc =
        await _firestore.collection('responders').doc(user.uid).get();

    if (!responderDoc.exists) {
      debugPrint('Responder document not found for uid: ${user.uid}');
      return;
    }

    final responderData = responderDoc.data();
    if (responderData == null) {
      debugPrint('Responder data is null.');
      return;
    }

    final barangay = (responderData['barangay'] ?? '').toString().trim();
    if (barangay.isEmpty) {
      debugPrint('Responder barangay is missing.');
      return;
    }

    // Stop old listener first
    await _incidentSubscription?.cancel();
    _incidentSubscription = null;

    // Reset tracking
    _alreadyAlertedIds.clear();
    _processedInitialSnapshot = false;

    _incidentSubscription = _firestore
        .collection('incidents')
        .where('barangay', isEqualTo: barangay)
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) async {
        await _handleSnapshot(snapshot);
      },
      onError: (error) {
        debugPrint('Incident listener error: $error');
      },
    );

    debugPrint('Listening for incidents in barangay: $barangay');
  }

  /// Stop Firestore listener.
  Future<void> stopListening() async {
    await _incidentSubscription?.cancel();
    _incidentSubscription = null;
  }

  /// Dispose service if ever needed.
  Future<void> disposeService() async {
    await stopListening();
    await _audioPlayer.dispose();
  }

  /// Handles incoming Firestore snapshots.
  Future<void> _handleSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    // Ignore old incidents that already exist when listener starts
    if (!_processedInitialSnapshot) {
      for (final doc in snapshot.docs) {
        _alreadyAlertedIds.add(doc.id);
      }
      _processedInitialSnapshot = true;
      debugPrint('Initial snapshot processed.');
      return;
    }

    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;

      final doc = change.doc;
      final data = doc.data();
      if (data == null) continue;

      if (_alreadyAlertedIds.contains(doc.id)) continue;
      _alreadyAlertedIds.add(doc.id);

      final reportType = (data['reportType'] ?? 'Emergency').toString();
      final street = (data['street'] ?? 'Unknown location').toString();
      final description = (data['description'] ?? '').toString();
      final time = (data['time'] ?? '').toString();

      final List<String> bodyParts = [
        street,
        if (time.isNotEmpty) time,
        if (description.isNotEmpty) description,
      ];

      final body = bodyParts.join(' • ');

      await _playAlertSound();
      await _showLocalNotification(
        id: doc.id.hashCode,
        title: 'New $reportType alert',
        body: body.isEmpty ? 'A new incident was reported.' : body,
      );

      debugPrint('Triggered alert for incident ${doc.id}');
    }
  }

  /// Requests notification permission.
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      debugPrint('Notification permission already granted');
      return;
    }

    if (status.isDenied || status.isRestricted || status.isLimited) {
      final result = await Permission.notification.request();
      debugPrint('Notification permission result: $result');
      return;
    }

    if (status.isPermanentlyDenied) {
      debugPrint('Notification permission permanently denied');
      await openAppSettings();
    }
  }

  /// Initializes local notifications and creates Android channel.
  Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
    );

    const channel = AndroidNotificationChannel(
      'responder_alerts_channel',
      'Responder Alerts',
      description: 'Real-time alerts for responders',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert1'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Plays in-app alert sound.
  Future<void> _playAlertSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('sounds/alert1.mp3'),
      );
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  /// Shows local notification.
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'responder_alerts_channel',
      'Responder Alerts',
      channelDescription: 'Real-time alerts for responders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert1'),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> testNotification() async {
  await initialize();

  await _showLocalNotification(
    id: 999,
    title: 'Test Notification',
    body: 'If you can see this, local notifications work.',
  );

  await _playAlertSound();
}
}