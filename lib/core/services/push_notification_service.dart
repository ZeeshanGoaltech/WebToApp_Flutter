import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/repositories/push_repository.dart';

class PushNotificationService extends GetxService {
  PushNotificationService(this._pushRepository, this._session);

  static const String _notificationPermissionPromptedKey =
      'notification_permission_prompted';

  final PushRepository _pushRepository;
  final SessionService _session;

  String? _lastSyncedToken;

  Future<PushNotificationService> init() async {
    await _configureForegroundPresentation();
    _listenForMessages();
    _listenForTokenRefresh();
    _listenForAuthChanges();
    await syncTokenWithBackend();
    await _handleInitialMessage();
    return this;
  }

  /// Prompts on first home visit — not during splash startup.
  Future<void> requestPermissionIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_notificationPermissionPromptedKey) == true) return;

    await _requestPermission();
    await prefs.setBool(_notificationPermissionPromptedKey, true);
    await syncTokenWithBackend();
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null && kDebugMode) {
      debugPrint('App opened from notification: ${message.data}');
    }
  }

  Future<void> syncTokenWithBackend() async {
    if (!_session.isAuthenticated) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (token == _lastSyncedToken) return;

      await _pushRepository.registerFcmToken(token);
      _lastSyncedToken = token;
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token sync failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token sync failed: $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    if (!Platform.isAndroid) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _configureForegroundPresentation() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _listenForMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      AppToast.info(
        notification.title ?? 'Notification',
        description: notification.body,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        debugPrint('Notification opened: ${message.data}');
      }
    });
  }

  void _listenForTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      _lastSyncedToken = null;
      if (!_session.isAuthenticated) return;

      try {
        await _pushRepository.registerFcmToken(token);
        _lastSyncedToken = token;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FCM token refresh sync failed: $e');
        }
      }
    });
  }

  void _listenForAuthChanges() {
    ever(_session.user, (_) {
      _lastSyncedToken = null;
      syncTokenWithBackend();
    });
    ever(_session.isGuest, (isGuest) {
      if (isGuest) {
        _lastSyncedToken = null;
      }
    });
  }
}
