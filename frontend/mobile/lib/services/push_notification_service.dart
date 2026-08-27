import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  static const String webVapidKey =
      'BF2K7a59ij-dIO6q1ewweJ8P3SXJ7QCf9KiXw33sSfl98AGvKTI12HEbMxAPlUgAuCnGXJoMVmNCsA-loh1-oCk';

  String? _token;

  String? get token => _token;

  Stream<RemoteMessage> get foregroundMessages =>
      _foregroundMessageController.stream;

  Future<String?> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return null;
    }

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await _waitForApnsToken();
    }

    _token = await _getToken();

    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;

      if (kDebugMode) {
        print('FarmPilot refreshed FCM token: $newToken');
      }
    });

    await _foregroundMessageSubscription?.cancel();

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
      message,
    ) {
      _foregroundMessageController.add(message);

      if (kDebugMode) {
        print(
          'FarmPilot foreground notification: '
          '${message.notification?.title}',
        );
      }
    });

    if (kDebugMode) {
      print('FarmPilot FCM token: $_token');
    }

    return _token;
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return _messaging.getToken(vapidKey: webVapidKey);
    }

    return _messaging.getToken();
  }

  Future<void> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final token = await _messaging.getAPNSToken();

      if (token != null && token.isNotEmpty) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();

    _token = null;
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _foregroundMessageController.close();
  }
}
