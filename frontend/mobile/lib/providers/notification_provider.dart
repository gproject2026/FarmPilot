import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService notificationService =
      NotificationService();

  bool isLoading = false;

  List<dynamic> notifications = [];

  String? errorMessage;

  int get unreadCount {
    return notifications.where((notification) {
      if (notification is! Map) {
        return false;
      }

      final notificationMap =
          Map<String, dynamic>.from(
        notification,
      );

      return notificationMap['isRead'] != true;
    }).length;
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      notifications =
          await notificationService
              .getMyNotifications();
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    if (notificationId.isEmpty) {
      return false;
    }

    errorMessage = null;

    try {
      final updatedNotification =
          await notificationService.markAsRead(
        notificationId,
      );

      final index =
          notifications.indexWhere((notification) {
        if (notification is! Map) {
          return false;
        }

        final notificationMap =
            Map<String, dynamic>.from(
          notification,
        );

        return notificationMap['id']?.toString() ==
            notificationId;
      });

      if (index != -1) {
        notifications[index] =
            updatedNotification;
      }

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      notifyListeners();

      return false;
    }
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications =
        notifications.where((notification) {
      if (notification is! Map) {
        return false;
      }

      final notificationMap =
          Map<String, dynamic>.from(
        notification,
      );

      return notificationMap['isRead'] != true;
    }).toList();

    for (final notification
        in unreadNotifications) {
      if (notification is! Map) {
        continue;
      }

      final notificationMap =
          Map<String, dynamic>.from(
        notification,
      );

      final notificationId =
          notificationMap['id']?.toString() ?? '';

      if (notificationId.isNotEmpty) {
        await markAsRead(notificationId);
      }
    }
  }

  void clearNotifications() {
    notifications = [];
    errorMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}