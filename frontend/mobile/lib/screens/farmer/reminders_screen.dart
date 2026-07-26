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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadReminders();
      },
    );
  }

  Future<void> _loadReminders() async {
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
      backgroundColor:
          const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadReminders,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: _openAddReminderDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ReminderProvider>(
        builder: (
          context,
          reminderProvider,
          child,
        ) {
          if (reminderProvider.isLoading &&
              reminderProvider
                  .reminders.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (reminderProvider
              .errorMessage !=
              null &&
              reminderProvider
                  .reminders.isEmpty) {
            return _ErrorView(
              message: reminderProvider
                  .errorMessage!,
              onRetry: _loadReminders,
            );
          }

          if (reminderProvider
              .reminders.isEmpty) {
            return _EmptyRemindersView(
              onAddReminder:
                  _openAddReminderDialog,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReminders,
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: reminderProvider
                  .reminders.length,
              itemBuilder: (
                context,
                index,
              ) {
                final reminder =
                    reminderProvider
                        .reminders[index];

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
            ),
          );
        },
      ),
    );
  }
}

class _ReminderCard
    extends StatelessWidget {
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

    return Card(
      margin:
          const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor(
                  reminder.type,
                ).withValues(
                  alpha: 0.15,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                _getTypeIcon(
                  reminder.type,
                ),
                color: _getTypeColor(
                  reminder.type,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.formattedType,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration
                              .lineThrough
                          : null,
                      color: isCompleted
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reminder.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  if (reminder.cropName !=
                      null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.grass,
                          size: 17,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            reminder.cropName!,
                            style:
                                const TextStyle(
                              color:
                                  Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                              .withValues(
                              alpha: 0.12,
                            )
                          : Colors.orange
                              .withValues(
                              alpha: 0.12,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Completed'
                          : 'Pending',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : Colors.orange[800],
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Checkbox(
                  value: isCompleted,
                  activeColor: Colors.green,
                  onChanged: (_) {
                    onStatusChanged();
                  },
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'IRRIGATION':
        return Icons.water_drop;
      case 'FERTILIZATION':
        return Icons.eco;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'IRRIGATION':
        return Colors.blue;
      case 'FERTILIZATION':
        return Colors.green;
      default:
        return Colors.orange;
    }
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
    return AlertDialog(
      title: const Text(
        'Add Reminder',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration:
                  const InputDecoration(
                labelText: 'Reminder Type',
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'IRRIGATION',
                  child: Text('Irrigation'),
                ),
                DropdownMenuItem(
                  value: 'FERTILIZATION',
                  child:
                      Text('Fertilization'),
                ),
                DropdownMenuItem(
                  value: 'OTHER',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.green,
              ),
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              onTap: _selectDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.access_time,
                color: Colors.green,
              ),
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!
                        .format(context),
              ),
              onTap: _selectTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isSaving ? null : _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _EmptyRemindersView
    extends StatelessWidget {
  final VoidCallback onAddReminder;

  const _EmptyRemindersView({
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 90,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No reminders yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add a reminder for irrigation, fertilization, or another farm task.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddReminder,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Reminder',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,
                foregroundColor:
                    Colors.white,
              ),
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
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}