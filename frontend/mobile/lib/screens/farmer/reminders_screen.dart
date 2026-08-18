import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/reminder_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState
    extends State<RemindersScreen> {
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

    await Future.wait([
      context
          .read<ReminderProvider>()
          .fetchReminders(
            token: token,
          ),
      context
          .read<CropProvider>()
          .getMyCrops(token),
    ]);
  }

  Future<void> _openAddReminderDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) =>
          const _AddReminderDialog(),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder added successfully',
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
                'Unable to update reminder',
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
          title: const Text(
            'Delete Reminder',
          ),
          content: const Text(
            'Are you sure you want to delete this reminder?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
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
              ? 'Reminder deleted successfully'
              : reminderProvider.errorMessage ??
                  'Unable to delete reminder',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                message: reminderProvider.errorMessage!,
                                onRetry: _loadData,
                              ),
                            )
                          else if (reminders.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyRemindersView(
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
    );
  }
}

const _reminderDark = Color(0xFF173F24);
const _reminderPrimary = Color(0xFF2F743F);
const _reminderLight = Color(0xFFEAF3DF);
const _reminderText = Color(0xFF1D2C21);
const _reminderMuted = Color(0xFF6C786E);

class _RemindersTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;

  const _RemindersTopBar({
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _ReminderHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Reminders',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _ReminderHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
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
  final int totalCount;
  final int pendingCount;
  final int completedCount;
  final bool isLoading;
  final VoidCallback? onAddReminder;

  const _RemindersHero({
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: TextStyle(
                        color: _reminderText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Organize irrigation, fertilization and other farm tasks.',
                      style: TextStyle(
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
                label: 'Total',
                value: totalCount,
              ),
              _ReminderCountChip(
                label: 'Pending',
                value: pendingCount,
              ),
              _ReminderCountChip(
                label: 'Completed',
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
                label: const Text(
                  'Add Reminder',
                  style: TextStyle(
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
  final ReminderModel reminder;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = reminder.status;
    final typeColor = _getReminderTypeColor(reminder.type);
    final typeIcon = _getReminderTypeIcon(reminder.type);

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
                      reminder.formattedType,
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
                  isCompleted ? 'Completed' : 'Pending',
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
          if (reminder.cropName != null &&
              reminder.cropName!.trim().isNotEmpty)
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
                      reminder.cropName!,
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
              child: const Row(
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: _reminderMuted,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'General farm reminder',
                    style: TextStyle(
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
                    isCompleted ? 'Mark Pending' : 'Mark Completed',
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
                  tooltip: 'Delete Reminder',
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
  const _AddReminderDialog();

  @override
  State<_AddReminderDialog> createState() =>
      _AddReminderDialogState();
}

class _AddReminderDialogState
    extends State<_AddReminderDialog> {
  String _selectedType = 'IRRIGATION';
  String? _selectedCropId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;

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
    if (_selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select date and time',
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
          cropId: _selectedCropId,
          type: _selectedType,
          reminderDate: reminderDate,
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
                'Unable to add reminder',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = context.watch<CropProvider>();
    final crops = cropProvider.crops;

    return Dialog(
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Reminder',
                          style: TextStyle(
                            color: _reminderText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Schedule a farm task and optionally link it to a crop.',
                          style: TextStyle(
                            color: _reminderMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: _reminderFieldDecoration(
                  label: 'Reminder Type',
                  icon: Icons.notifications_active_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'IRRIGATION',
                    child: Text('Irrigation'),
                  ),
                  DropdownMenuItem(
                    value: 'FERTILIZATION',
                    child: Text('Fertilization'),
                  ),
                  DropdownMenuItem(
                    value: 'OTHER',
                    child: Text('Other'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedType = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedCropId,
                isExpanded: true,
                decoration: _reminderFieldDecoration(
                  label: 'Crop (Optional)',
                  icon: Icons.eco_outlined,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No specific crop'),
                  ),
                  ...crops.map(
                    (crop) {
                      final cropId = crop['id']?.toString() ?? '';
                      final cropName =
                          crop['cropName']?.toString() ?? 'Unnamed Crop';

                      return DropdownMenuItem<String?>(
                        value: cropId,
                        child: Text(
                          cropName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCropId = value;
                        });
                      },
              ),
              if (crops.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'No crops available. You can still create a general reminder.',
                  style: TextStyle(
                    color: _reminderMuted,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _ReminderPickerTile(
                icon: Icons.calendar_month_outlined,
                label: 'Date',
                value: _selectedDate == null
                    ? 'Select date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                onTap: _isSaving ? null : _selectDate,
              ),
              const SizedBox(height: 12),
              _ReminderPickerTile(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: _selectedTime == null
                    ? 'Select time'
                    : _selectedTime!.format(context),
                onTap: _isSaving ? null : _selectTime,
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
                      child: const Text('Cancel'),
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
                        _isSaving ? 'Saving...' : 'Save Reminder',
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
  final VoidCallback onAddReminder;

  const _EmptyRemindersView({
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
            const Text(
              'No reminders yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _reminderText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a reminder for irrigation, fertilization, or another farm task.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
              label: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
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
              label: const Text('Try Again'),
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
