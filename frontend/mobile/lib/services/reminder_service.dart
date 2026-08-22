import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/reminder_model.dart';

class ReminderService {
  Future<List<ReminderModel>> getReminders({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/reminders',
      ),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(
        response.body,
      );

      if (decodedBody is! List) {
        throw Exception(
          'Invalid reminders response',
        );
      }

      return decodedBody
          .map(
            (item) => ReminderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to load reminders',
      ),
    );
  }

  Future<ReminderModel> createReminder({
    required String token,
    required String title,
    String? cropName,
    String? cropId,
    String type = 'OTHER',
    required DateTime reminderDate,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AppConstants.baseUrl}/reminders',
      ),
      headers: _headers(token),
      body: jsonEncode({
        'title': title.trim(),

        if (cropName != null &&
            cropName.trim().isNotEmpty)
          'cropName': cropName.trim(),

        if (cropId != null &&
            cropId.isNotEmpty)
          'cropId': cropId,

        'type': type,

        'reminderDate':
            reminderDate.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return ReminderModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to create reminder',
      ),
    );
  }

  Future<ReminderModel> updateReminder({
    required String token,
    required String reminderId,
    String? title,
    String? cropName,
    String? cropId,
    String? type,
    DateTime? reminderDate,
    bool? status,
  }) async {
    final body = <String, dynamic>{};

    if (title != null) {
      body['title'] = title.trim();
    }

    if (cropName != null) {
      body['cropName'] = cropName.trim();
    }

    if (cropId != null) {
      body['cropId'] = cropId;
    }

    if (type != null) {
      body['type'] = type;
    }

    if (reminderDate != null) {
      body['reminderDate'] =
          reminderDate.toUtc().toIso8601String();
    }

    if (status != null) {
      body['status'] = status;
    }

    final response = await http.patch(
      Uri.parse(
        '${AppConstants.baseUrl}/reminders/$reminderId',
      ),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return ReminderModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to update reminder',
      ),
    );
  }

  Future<void> deleteReminder({
    required String token,
    required String reminderId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${AppConstants.baseUrl}/reminders/$reminderId',
      ),
      headers: _headers(token),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        _readErrorMessage(
          response.body,
          'Failed to delete reminder',
        ),
      );
    }
  }

  Map<String, String> _headers(
    String token,
  ) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _readErrorMessage(
    String responseBody,
    String fallbackMessage,
  ) {
    try {
      final decodedBody = jsonDecode(
        responseBody,
      );

      if (decodedBody is Map<String, dynamic>) {
        final message =
            decodedBody['message'];

        if (message is String) {
          return message;
        }

        if (message is List) {
          return message.join(', ');
        }
      }
    } catch (_) {
      // Use the fallback message.
    }

    return fallbackMessage;
  }
}