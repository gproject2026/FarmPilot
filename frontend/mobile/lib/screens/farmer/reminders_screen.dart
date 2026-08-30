import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState
    extends State<RemindersScreen> {
  bool _isArabic = false;

  void _setLanguage(bool isArabic) {
    if (_isArabic == isArabic) {
      return;
    }

    setState(() {
      _isArabic = isArabic;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadData();
      },
    );
  }

  Future<void> _loadData() async {
    final authProvider =
        context.read<AuthProvider>();

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await context
        .read<ReminderProvider>()
        .fetchReminders(
          token: token,
        );
  }

  Future<void> _openAddReminderDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _AddReminderDialog(
        isArabic: _isArabic,
      ),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تمت إضافة التذكير بنجاح'
                : 'Reminder added successfully',
          ),
        ),
      );
    }
  }

  Future<void> _toggleStatus(
    ReminderModel reminder,
  ) async {
    final authProvider =
        context.read<AuthProvider>();

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      return;
    }

    final success = await context
        .read<ReminderProvider>()
        .toggleReminderStatus(
          token: token,
          reminder: reminder,
        );

    if (!mounted) {
      return;
    }

    if (!success) {
      final errorMessage = context
          .read<ReminderProvider>()
          .errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ??
                (_isArabic
                    ? 'تعذر تحديث التذكير'
                    : 'Unable to update reminder'),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    ReminderModel reminder,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _isArabic
                ? 'حذف التذكير'
                : 'Delete Reminder',
          ),
          content: Text(
            _isArabic
                ? 'هل أنت متأكد أنك تريد حذف هذا التذكير؟'
                : 'Are you sure you want to delete this reminder?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _isArabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _isArabic ? 'حذف' : 'Delete',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final token =
        context.read<AuthProvider>().token;

    if (token == null || token.isEmpty) {
      return;
    }

    final success = await context
        .read<ReminderProvider>()
        .deleteReminder(
          token: token,
          reminderId: reminder.id,
        );

    if (!mounted) {
      return;
    }

    final reminderProvider =
        context.read<ReminderProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isArabic
                  ? 'تم حذف التذكير بنجاح'
                  : 'Reminder deleted successfully')
              : reminderProvider.errorMessage ??
                  (_isArabic
                      ? 'تعذر حذف التذكير'
                      : 'Unable to delete reminder'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF4),
        body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          final reminders = reminderProvider.reminders;
          final completedCount =
              reminders.where((reminder) => reminder.status).length;
          final pendingCount = reminders.length - completedCount;

          return Stack(
            children: [
              const Positioned.fill(
                child: _RemindersBackdrop(),
              ),
              Column(
                children: [
                  _RemindersTopBar(
                    isArabic: _isArabic,
                    onLanguageChanged: _setLanguage,
                    onBack: () => Navigator.pop(context),
                    onRefresh:
                        reminderProvider.isLoading ? null : _loadData,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: _reminderPrimary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1320,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    26,
                                    24,
                                    18,
                                  ),
                                  child: _RemindersHero(
                                    isArabic: _isArabic,
                                    totalCount: reminders.length,
                                    pendingCount: pendingCount,
                                    completedCount: completedCount,
                                    isLoading: reminderProvider.isLoading,
                                    onAddReminder:
                                        reminderProvider.isLoading
                                            ? null
                                            : _openAddReminderDialog,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (reminderProvider.isLoading &&
                              reminders.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _reminderPrimary,
                                ),
                              ),
                            )
                          else if (reminderProvider.errorMessage != null &&
                              reminders.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _ErrorView(
                                isArabic: _isArabic,
                                message: reminderProvider.errorMessage!,
                                onRetry: _loadData,
                              ),
                            )
                          else if (reminders.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyRemindersView(
                                isArabic: _isArabic,
                                onAddReminder: _openAddReminderDialog,
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                42,
                              ),
                              sliver: SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.crossAxisExtent;

                                  final crossAxisCount = width >= 1180
                                      ? 3
                                      : width >= 760
                                          ? 2
                                          : 1;

                                  return SliverGrid(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final reminder = reminders[index];

                                        return _ReminderCard(
                                          isArabic: _isArabic,
                                          reminder: reminder,
                                          onStatusChanged: () {
                                            _toggleStatus(reminder);
                                          },
                                          onDelete: () {
                                            _confirmDelete(reminder);
                                          },
                                        );
                                      },
                                      childCount: reminders.length,
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 255,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

const _reminderDark = Color(0xFF173F24);
const _reminderPrimary = Color(0xFF2F743F);
const _reminderLight = Color(0xFFEAF3DF);
const _reminderText = Color(0xFF1D2C21);
const _reminderMuted = Color(0xFF6C786E);

class _RemindersTopBar extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;

  const _RemindersTopBar({
    required this.isArabic,
    required this.onLanguageChanged,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _ReminderHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: isArabic ? 'رجوع' : 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDDECB8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _reminderDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isArabic ? 'التذكيرات' : 'Reminders',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Directionality(
              textDirection: TextDirection.ltr,
              child: PopupMenuButton<String>(
                tooltip:
                    isArabic ? 'تغيير اللغة' : 'Change Language',
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                color: const Color(0xFFF8FAF4),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (language) {
                  onLanguageChanged(language == 'ar');
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: !isArabic
                              ? _reminderPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        const Text('English'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: isArabic
                              ? _reminderPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        const Text('Arabic'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.language_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),
            _ReminderHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: isArabic ? 'تحديث' : 'Refresh',
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ReminderHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(
          alpha: onTap == null ? 0.05 : 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 21,
              color: onTap == null ? Colors.white54 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RemindersHero extends StatelessWidget {
  final bool isArabic;
  final int totalCount;
  final int pendingCount;
  final int completedCount;
  final bool isLoading;
  final VoidCallback? onAddReminder;

  const _RemindersHero({
    required this.isArabic,
    required this.totalCount,
    required this.pendingCount,
    required this.completedCount,
    required this.isLoading,
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _reminderCardDecoration(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _reminderLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: _reminderPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'التذكيرات' : 'Reminders',
                      style: const TextStyle(
                        color: _reminderText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'نظّم مهام الري والتسميد وباقي مهام المزرعة.'
                          : 'Organize irrigation, fertilization and other farm tasks.',
                      style: const TextStyle(
                        color: _reminderMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ReminderCountChip(
                label: isArabic ? 'الإجمالي' : 'Total',
                value: totalCount,
              ),
              _ReminderCountChip(
                label: isArabic ? 'قيد الانتظار' : 'Pending',
                value: pendingCount,
              ),
              _ReminderCountChip(
                label: isArabic ? 'مكتمل' : 'Completed',
                value: completedCount,
              ),
              ElevatedButton.icon(
                onPressed: onAddReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _reminderPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9FB5A4),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(
                  isArabic ? 'إضافة تذكير' : 'Add Reminder',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 18),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _ReminderCountChip extends StatelessWidget {
  final String label;
  final int value;

  const _ReminderCountChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: _reminderPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final bool isArabic;
  final ReminderModel reminder;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.isArabic,
    required this.reminder,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = reminder.status;
    final typeColor = _getReminderTypeColor(reminder.type);
    final typeIcon = _getReminderTypeIcon(reminder.type);

    final localizedCropName =
        reminder.getCropName(
      isArabic: isArabic,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _reminderCardDecoration(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.getTitle(
                        isArabic: isArabic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCompleted
                            ? _reminderMuted
                            : _reminderText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _reminderMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE8F3E7)
                      : const Color(0xFFFFF0DE),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isCompleted
                      ? (isArabic ? 'مكتمل' : 'Completed')
                      : (isArabic ? 'قيد الانتظار' : 'Pending'),
                  style: TextStyle(
                    color: isCompleted
                        ? const Color(0xFF3F8A50)
                        : const Color(0xFFC8792C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (localizedCropName != null &&
              localizedCropName.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCF9),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE3E9DF),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: _reminderPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizedCropName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _reminderText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCF9),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE3E9DF),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: _reminderMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic
                        ? 'تذكير عام للمزرعة'
                        : 'General farm reminder',
                    style: const TextStyle(
                      color: _reminderMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStatusChanged,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? const Color(0xFFF1F6E9)
                        : _reminderPrimary,
                    foregroundColor: isCompleted
                        ? _reminderPrimary
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: Icon(
                    isCompleted
                        ? Icons.undo_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isCompleted
                        ? (isArabic
                            ? 'إعادة إلى الانتظار'
                            : 'Mark Pending')
                        : (isArabic
                            ? 'تحديد كمكتمل'
                            : 'Mark Completed'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: isArabic ? 'حذف التذكير' : 'Delete Reminder',
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3F3),
                    foregroundColor: const Color(0xFFC65353),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _getReminderTypeIcon(String type) {
  switch (type) {
    case 'IRRIGATION':
      return Icons.water_drop_outlined;
    case 'FERTILIZATION':
      return Icons.science_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

Color _getReminderTypeColor(String type) {
  switch (type) {
    case 'IRRIGATION':
      return const Color(0xFF4C78A8);
    case 'FERTILIZATION':
      return const Color(0xFF4F8A5B);
    default:
      return const Color(0xFFC8792C);
  }
}

class _AddReminderDialog
    extends StatefulWidget {
  final bool isArabic;

  const _AddReminderDialog({
    required this.isArabic,
  });

  @override
  State<_AddReminderDialog> createState() =>
      _AddReminderDialogState();
}

class _AddReminderDialogState
    extends State<_AddReminderDialog> {
  bool get isArabic => widget.isArabic;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _cropNameController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Set<int> _selectedRepeatDays = <int>{};

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _cropNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year + 5,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ?? TimeOfDay.now(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedTime = result;
      });
    }
  }

  Future<void> _saveReminder() async {
    final title =
        _titleController.text.trim();

    final cropName =
        _cropNameController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يرجى كتابة عنوان التذكير'
                : 'Please enter a reminder title',
          ),
        ),
      );

      return;
    }

    if (_selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يرجى اختيار التاريخ والوقت'
                : 'Please select date and time',
          ),
        ),
      );

      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      return;
    }

    final reminderDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() {
      _isSaving = true;
    });

    final success = await context
        .read<ReminderProvider>()
        .createReminder(
          token: token,
          title: title,
          cropName:
              cropName.isEmpty ? null : cropName,
          type: 'OTHER',
          reminderDate: reminderDate,
          repeatDays: _selectedRepeatDays.toList()..sort(),
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      final errorMessage = context
          .read<ReminderProvider>()
          .errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ??
                (isArabic
                    ? 'تعذر إضافة التذكير'
                    : 'Unable to add reminder'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560,
        constraints: const BoxConstraints(
          maxHeight: 720,
        ),
        decoration: _reminderCardDecoration(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _reminderLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_alert_outlined,
                      color: _reminderPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'إضافة تذكير' : 'Add Reminder',
                          style: const TextStyle(
                            color: _reminderText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'اكتب التذكير واسم المحصول وحدد التاريخ والوقت.'
                              : 'Enter the reminder and crop name, then choose the date and time.',
                          style: const TextStyle(
                            color: _reminderMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isArabic ? 'إغلاق' : 'Close',
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                enabled: !_isSaving,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    _reminderFieldDecoration(
                  label: isArabic
                      ? 'عنوان التذكير'
                      : 'Reminder Title',
                  icon:
                      Icons.notifications_active_outlined,
                ).copyWith(
                  hintText: isArabic
                      ? 'مثال: رش الأشجار'
                      : 'Example: Spray the trees',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                    _cropNameController,
                enabled: !_isSaving,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    _reminderFieldDecoration(
                  label: isArabic
                      ? 'اسم المحصول (اختياري)'
                      : 'Crop Name (Optional)',
                  icon: Icons.eco_outlined,
                ).copyWith(
                  hintText: isArabic
                      ? 'مثال: الطماطم'
                      : 'Example: Tomato',
                ),
              ),
              const SizedBox(height: 16),
              _ReminderPickerTile(
                icon: Icons.calendar_month_outlined,
                label: isArabic ? 'التاريخ' : 'Date',
                value: _selectedDate == null
                    ? (isArabic ? 'اختر التاريخ' : 'Select date')
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                onTap: _isSaving ? null : _selectDate,
              ),
              const SizedBox(height: 12),
              _ReminderPickerTile(
                icon: Icons.access_time_rounded,
                label: isArabic ? 'الوقت' : 'Time',
                value: _selectedTime == null
                    ? (isArabic ? 'اختر الوقت' : 'Select time')
                    : _selectedTime!.format(context),
                onTap: _isSaving ? null : _selectTime,
              ),
               const SizedBox(height: 16),
               _RepeatDaysSelector(
                 isArabic: isArabic,
                 selectedDays: _selectedRepeatDays,
                 enabled: !_isSaving,
                 onDayChanged: (day) {
                   setState(() {
                     if (_selectedRepeatDays.contains(day)) {
                       _selectedRepeatDays.remove(day);
                     } else {
                       _selectedRepeatDays.add(day);
                     }
                   });
                 },
               ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _reminderMuted,
                        side: const BorderSide(
                          color: Color(0xFFD8E2D4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _reminderPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF9FB5A4),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving
                            ? (isArabic ? 'جارٍ الحفظ...' : 'Saving...')
                            : (isArabic ? 'حفظ التذكير' : 'Save Reminder'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _RepeatDaysSelector extends StatelessWidget {
  final bool isArabic;
  final Set<int> selectedDays;
  final bool enabled;
  final ValueChanged<int> onDayChanged;

  const _RepeatDaysSelector({
    required this.isArabic,
    required this.selectedDays,
    required this.enabled,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    const days = <int, Map<String, String>>{
      0: {'en': 'Sun', 'ar': 'أحد'},
      1: {'en': 'Mon', 'ar': 'إثن'},
      2: {'en': 'Tue', 'ar': 'ثلا'},
      3: {'en': 'Wed', 'ar': 'أرب'},
      4: {'en': 'Thu', 'ar': 'خمي'},
      5: {'en': 'Fri', 'ar': 'جمع'},
      6: {'en': 'Sat', 'ar': 'سبت'},
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8E2D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _reminderLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.repeat_rounded,
                  color: _reminderPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'تكرار أسبوعي' : 'Weekly Repeat',
                      style: const TextStyle(
                        color: _reminderText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedDays.isEmpty
                          ? (isArabic
                              ? 'بدون تكرار - مرة واحدة'
                              : 'No repeat - one time')
                          : (isArabic
                              ? 'يتكرر في الأيام المحددة'
                              : 'Repeats on selected days'),
                      style: const TextStyle(
                        color: _reminderMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.entries.map((entry) {
              final day = entry.key;
              final selected = selectedDays.contains(day);

              return FilterChip(
                selected: selected,
                onSelected: enabled ? (_) => onDayChanged(day) : null,
                label: Text(entry.value[isArabic ? 'ar' : 'en']!),
                showCheckmark: false,
                selectedColor: _reminderPrimary,
                backgroundColor: const Color(0xFFF1F6E9),
                disabledColor: const Color(0xFFF3F4F1),
                side: BorderSide(
                  color: selected
                      ? _reminderPrimary
                      : const Color(0xFFD8E2D4),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _reminderText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


class _ReminderPickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ReminderPickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFDFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFD8E2D4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _reminderLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: _reminderPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _reminderMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: _reminderText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _reminderMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _reminderFieldDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: _reminderMuted,
    ),
    prefixIcon: Icon(
      icon,
      color: _reminderPrimary,
      size: 21,
    ),
    filled: true,
    fillColor: const Color(0xFFFCFDFB),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 17,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xFFD8E2D4),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xFFD8E2D4),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: _reminderPrimary,
        width: 1.5,
      ),
    ),
  );
}

class _EmptyRemindersView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onAddReminder;

  const _EmptyRemindersView({
    required this.isArabic,
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: _reminderCardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: _reminderLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: _reminderPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'لا توجد تذكيرات بعد' : 'No reminders yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _reminderText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أضف تذكيرًا للري أو التسميد أو أي مهمة أخرى في المزرعة.'
                  : 'Add a reminder for irrigation, fertilization, or another farm task.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _reminderMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _reminderPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(isArabic ? 'إضافة تذكير' : 'Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool isArabic;
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.isArabic,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: _reminderCardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Color(0xFFC65353),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _reminderText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _reminderPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isArabic ? 'حاول مرة أخرى' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemindersBackdrop extends StatelessWidget {
  const _RemindersBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAF4),
                  Color(0xFFFFFCF5),
                  Color(0xFFF3F8EC),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 190,
            child: _ReminderGlow(
              size: 450,
              color: const Color(0xFFCFE6B4),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: _ReminderGlow(
              size: 520,
              color: const Color(0xFFE7DFAF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _ReminderGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _reminderCardDecoration(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFFDCE5D8),
    ),
    boxShadow: [
      BoxShadow(
        color: _reminderDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
