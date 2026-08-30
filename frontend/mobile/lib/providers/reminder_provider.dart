import 'package:flutter/foundation.dart';

import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService =
      ReminderService();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReminderModel> get reminders =>
      List.unmodifiable(_reminders);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchReminders({
    required String token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _reminders =
          await _reminderService.getReminders(
        token: token,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReminder({
    required String token,
    required String title,
    String? cropName,
    String? cropId,
    String type = 'OTHER',
    required DateTime reminderDate,
    List<int> repeatDays = const [],
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newReminder =
          await _reminderService.createReminder(
        token: token,
        title: title,
        cropName: cropName,
        cropId: cropId,
        type: type,
        reminderDate: reminderDate,
        repeatDays: repeatDays,
      );

      _reminders.add(newReminder);
      _sortReminders();

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReminder({
    required String token,
    required String reminderId,
    String? title,
    String? cropName,
    String? cropId,
    String? type,
    DateTime? reminderDate,
    List<int>? repeatDays,
    bool? status,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedReminder =
          await _reminderService.updateReminder(
        token: token,
        reminderId: reminderId,
        title: title,
        cropName: cropName,
        cropId: cropId,
        type: type,
        reminderDate: reminderDate,
        repeatDays: repeatDays,
        status: status,
      );

      final reminderIndex =
          _reminders.indexWhere(
        (reminder) =>
            reminder.id ==
            reminderId,
      );

      if (reminderIndex != -1) {
        _reminders[reminderIndex] =
            updatedReminder;
      } else {
        _reminders.add(
          updatedReminder,
        );
      }

      _sortReminders();

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleReminderStatus({
    required String token,
    required ReminderModel reminder,
  }) {
    return updateReminder(
      token: token,
      reminderId: reminder.id,
      status: !reminder.status,
    );
  }

  Future<bool> deleteReminder({
    required String token,
    required String reminderId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _reminderService.deleteReminder(
        token: token,
        reminderId: reminderId,
      );

      _reminders.removeWhere(
        (reminder) =>
            reminder.id ==
            reminderId,
      );

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearReminders() {
    _reminders = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _sortReminders() {
    _reminders.sort(
      (first, second) =>
          first.reminderDate.compareTo(
        second.reminderDate,
      ),
    );
  }

  void _setLoading(
    bool value,
  ) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanError(
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