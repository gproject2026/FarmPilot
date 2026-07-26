class ReminderModel {
  final String id;
  final String farmerId;
  final String? cropId;
  final String type;
  final DateTime reminderDate;
  final bool status;
  final DateTime createdAt;

  final String? cropName;
  final String? cropType;

  ReminderModel({
    required this.id,
    required this.farmerId,
    this.cropId,
    required this.type,
    required this.reminderDate,
    required this.status,
    required this.createdAt,
    this.cropName,
    this.cropType,
  });

  factory ReminderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final crop = json['crop'];

    return ReminderModel(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      cropId: json['cropId']?.toString(),
      type: json['type']?.toString() ?? 'OTHER',
      reminderDate: DateTime.parse(
        json['reminderDate'].toString(),
      ),
      status: json['status'] == true,
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
      cropName: crop is Map<String, dynamic>
          ? crop['cropName']?.toString()
          : null,
      cropType: crop is Map<String, dynamic>
          ? crop['cropType']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cropId': cropId,
      'type': type,
      'reminderDate': reminderDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? farmerId,
    String? cropId,
    String? type,
    DateTime? reminderDate,
    bool? status,
    DateTime? createdAt,
    String? cropName,
    String? cropType,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cropId: cropId ?? this.cropId,
      type: type ?? this.type,
      reminderDate:
          reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cropName: cropName ?? this.cropName,
      cropType: cropType ?? this.cropType,
    );
  }

  String get formattedType {
    switch (type) {
      case 'IRRIGATION':
        return 'Irrigation';

      case 'FERTILIZATION':
        return 'Fertilization';

      case 'OTHER':
        return 'Other';

      default:
        return type;
    }
  }

  String get formattedDate {
    final day =
        reminderDate.day.toString().padLeft(2, '0');
    final month =
        reminderDate.month.toString().padLeft(2, '0');
    final year = reminderDate.year.toString();

    return '$day/$month/$year';
  }
}