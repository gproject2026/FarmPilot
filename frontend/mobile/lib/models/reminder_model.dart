class ReminderModel {
  final String id;
  final String farmerId;

  final String? title;
  final String? titleEn;
  final String? titleAr;

  final String? cropId;

  final String? cropName;
  final String? cropNameEn;
  final String? cropNameAr;

  final String type;

  final DateTime reminderDate;
  final List<int> repeatDays;
  final bool status;
  final DateTime createdAt;

  final String? cropType;

  ReminderModel({
    required this.id,
    required this.farmerId,
    this.title,
    this.titleEn,
    this.titleAr,
    this.cropId,
    this.cropName,
    this.cropNameEn,
    this.cropNameAr,
    required this.type,
    required this.reminderDate,
    this.repeatDays = const [],
    required this.status,
    required this.createdAt,
    this.cropType,
  });

  factory ReminderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final crop = json['crop'];

    final directCropName =
        json['cropName']
            ?.toString()
            .trim();

    final relationCropName =
        crop is Map<String, dynamic>
            ? crop['cropName']
                ?.toString()
                .trim()
            : null;

    final cropNameEn =
        json['cropNameEn']
            ?.toString()
            .trim();

    final cropNameAr =
        json['cropNameAr']
            ?.toString()
            .trim();

    final rawRepeatDays =
        json['repeatDays'];

    final repeatDays =
        rawRepeatDays is List
            ? rawRepeatDays
                .map(
                  (day) =>
                      int.tryParse(
                        day.toString(),
                      ),
                )
                .whereType<int>()
                .where(
                  (day) =>
                      day >= 0 &&
                      day <= 6,
                )
                .toSet()
                .toList()
            : <int>[];

    repeatDays.sort();

    return ReminderModel(
      id:
          json['id']?.toString() ??
          '',

      farmerId:
          json['farmerId']
                  ?.toString() ??
              '',

      title:
          json['title']
              ?.toString()
              .trim(),

      titleEn:
          json['titleEn']
              ?.toString()
              .trim(),

      titleAr:
          json['titleAr']
              ?.toString()
              .trim(),

      cropId:
          json['cropId']
              ?.toString(),

      cropName:
          directCropName != null &&
                  directCropName.isNotEmpty
              ? directCropName
              : relationCropName,

      cropNameEn:
          cropNameEn != null &&
                  cropNameEn.isNotEmpty
              ? cropNameEn
              : null,

      cropNameAr:
          cropNameAr != null &&
                  cropNameAr.isNotEmpty
              ? cropNameAr
              : null,

      type:
          json['type']
                  ?.toString() ??
              'OTHER',

      reminderDate:
          DateTime.parse(
        json['reminderDate']
            .toString(),
      ),

      repeatDays: repeatDays,

      status:
          json['status'] == true,

      createdAt:
          DateTime.parse(
        json['createdAt']
            .toString(),
      ),

      cropType:
          crop is Map<String, dynamic>
              ? crop['cropType']
                  ?.toString()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,

      'title': title,
      'titleEn': titleEn,
      'titleAr': titleAr,

      'cropId': cropId,

      'cropName': cropName,
      'cropNameEn': cropNameEn,
      'cropNameAr': cropNameAr,

      'type': type,

      'reminderDate':
          reminderDate
              .toIso8601String(),

      'repeatDays': repeatDays,

      'status': status,

      'createdAt':
          createdAt
              .toIso8601String(),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? farmerId,

    String? title,
    String? titleEn,
    String? titleAr,

    String? cropId,

    String? cropName,
    String? cropNameEn,
    String? cropNameAr,

    String? type,

    DateTime? reminderDate,
    List<int>? repeatDays,
    bool? status,
    DateTime? createdAt,

    String? cropType,
  }) {
    return ReminderModel(
      id:
          id ??
          this.id,

      farmerId:
          farmerId ??
          this.farmerId,

      title:
          title ??
          this.title,

      titleEn:
          titleEn ??
          this.titleEn,

      titleAr:
          titleAr ??
          this.titleAr,

      cropId:
          cropId ??
          this.cropId,

      cropName:
          cropName ??
          this.cropName,

      cropNameEn:
          cropNameEn ??
          this.cropNameEn,

      cropNameAr:
          cropNameAr ??
          this.cropNameAr,

      type:
          type ??
          this.type,

      reminderDate:
          reminderDate ??
          this.reminderDate,

      repeatDays:
          repeatDays ??
          this.repeatDays,

      status:
          status ??
          this.status,

      createdAt:
          createdAt ??
          this.createdAt,

      cropType:
          cropType ??
          this.cropType,
    );
  }

  String getTitle({
    required bool isArabic,
  }) {
    final localizedTitle =
        isArabic
            ? titleAr?.trim()
            : titleEn?.trim();

    if (localizedTitle != null &&
        localizedTitle.isNotEmpty) {
      return localizedTitle;
    }

    final originalTitle =
        title?.trim();

    if (originalTitle != null &&
        originalTitle.isNotEmpty) {
      return originalTitle;
    }

    return formattedTypeForLanguage(
      isArabic: isArabic,
    );
  }

  String? getCropName({
    required bool isArabic,
  }) {
    final localizedCropName =
        isArabic
            ? cropNameAr?.trim()
            : cropNameEn?.trim();

    if (localizedCropName != null &&
        localizedCropName.isNotEmpty) {
      return localizedCropName;
    }

    final originalCropName =
        cropName?.trim();

    if (originalCropName != null &&
        originalCropName.isNotEmpty) {
      return originalCropName;
    }

    return null;
  }

  String formattedTypeForLanguage({
    required bool isArabic,
  }) {
    switch (type) {
      case 'IRRIGATION':
        return isArabic
            ? 'الري'
            : 'Irrigation';

      case 'FERTILIZATION':
        return isArabic
            ? 'التسميد'
            : 'Fertilization';

      case 'OTHER':
        return isArabic
            ? 'تذكير'
            : 'Reminder';

      default:
        return type;
    }
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
        reminderDate.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        reminderDate.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final year =
        reminderDate.year
            .toString();

    return '$day/$month/$year';
  }
}