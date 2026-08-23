import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

import 'customer/customer_orders_screen.dart';
import 'farmer/farmer_orders_screen.dart';
import 'farmer/notification_diagnosis_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

const Color _notifDarkGreen = Color(0xFF173F24);
const Color _notifPrimaryGreen = Color(0xFF2F6B3D);
const Color _notifLightGreen = Color(0xFFDDECB8);
const Color _notifBackground = Color(0xFFF8FAF4);
const Color _notifTextPrimary = Color(0xFF1D2C21);
const Color _notifTextSecondary = Color(0xFF68756B);

class _NotificationsScreenState
    extends State<NotificationsScreen> {
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
        _loadNotifications();
      },
    );
  }

  Future<void> _loadNotifications() async {
    try {
      await Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _markAllAsRead() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (notificationProvider.unreadCount == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isArabic
                  ? 'تمت قراءة جميع الإشعارات بالفعل'
                  : 'All notifications are already read',
            ),
          ),
        );

      return;
    }

    await notificationProvider.markAllAsRead();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            notificationProvider.errorMessage ??
                (_isArabic
                    ? 'تم تحديد جميع الإشعارات كمقروءة'
                    : 'All notifications marked as read'),
          ),
          backgroundColor:
              notificationProvider.errorMessage == null
                  ? Colors.green
                  : Colors.red,
        ),
      );
  }

  Future<void> _deleteNotification(
    Map<String, dynamic> notification,
  ) async {
    final notificationId =
        notification['id']?.toString() ?? '';

    if (notificationId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _isArabic
                ? 'حذف الإشعار'
                : 'Delete notification',
          ),
          content: Text(
            _isArabic
                ? 'هل تريد حذف هذا الإشعار؟'
                : 'Are you sure you want to delete this notification?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                _isArabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                _isArabic ? 'حذف' : 'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final success =
        await notificationProvider.deleteNotification(
      notificationId,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (_isArabic
                    ? 'تم حذف الإشعار'
                    : 'Notification deleted')
                : (notificationProvider.errorMessage ??
                    (_isArabic
                        ? 'تعذر حذف الإشعار'
                        : 'Failed to delete notification')),
          ),
          backgroundColor:
              success ? Colors.green : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context);

    return Directionality(
      textDirection:
          _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: _notifBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: _NotificationsBackdrop()),
          RefreshIndicator(
            onRefresh: _loadNotifications,
            color: _notifPrimaryGreen,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _NotificationsHeader(
                    isArabic: _isArabic,
                    onLanguageChanged: _setLanguage,
                    unreadCount: notificationProvider.unreadCount,
                    isLoading: notificationProvider.isLoading,
                    onBack: () => Navigator.pop(context),
                    onMarkAllRead: _markAllAsRead,
                    onRefresh: _loadNotifications,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                    child: _NotificationsIntro(
                      isArabic: _isArabic,
                      total: notificationProvider.notifications.length,
                      unread: notificationProvider.unreadCount,
                    ),
                  ),
                ),
                if (notificationProvider.isLoading &&
                    notificationProvider.notifications.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _notifPrimaryGreen,
                      ),
                    ),
                  )
                else if (notificationProvider.notifications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyNotifications(
                      isArabic: _isArabic,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 42),
                    sliver: SliverList.separated(
                      itemCount: notificationProvider.notifications.length,
separatorBuilder: (_, _) =>  
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = Map<String, dynamic>.from(
                          notificationProvider.notifications[index],
                        );
                        return _NotificationCard(
                          isArabic: _isArabic,
                          notification: notification,
                          onDelete: () => _deleteNotification(
                            notification,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}


class _NotificationsHeader extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<bool> onLanguageChanged;
  final int unreadCount;
  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function() onMarkAllRead;
  final Future<void> Function() onRefresh;

  const _NotificationsHeader({
    required this.isArabic,
    required this.onLanguageChanged,
    required this.unreadCount,
    required this.isLoading,
    required this.onBack,
    required this.onMarkAllRead,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _notifDarkGreen.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _NotifHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: isArabic ? 'رجوع' : 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _notifLightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child:  Icon(
                Icons.eco_rounded,
                color: _notifDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
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
                  SizedBox(height: 2),
                  Text(
                    isArabic ? 'الإشعارات' : 'Notifications',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (unreadCount > 0) ...[
              _NotifHeaderButton(
                icon: Icons.done_all_rounded,
                tooltip: isArabic ? 'تحديد الكل كمقروء' : 'Mark all as read',
                onTap: isLoading ? null : onMarkAllRead,
              ),
              const SizedBox(width: 8),
            ],
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
                              ? _notifPrimaryGreen
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
                              ? _notifPrimaryGreen
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
            const SizedBox(width: 8),
            _NotifHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: isArabic ? 'تحديث' : 'Refresh',
              onTap: isLoading ? null : onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _NotifHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: onTap == null ? 0.05 : 0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: onTap == null ? Colors.white54 : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsIntro extends StatelessWidget {
  final bool isArabic;
  final int total;
  final int unread;

  const _NotificationsIntro({
    required this.isArabic,
    required this.total,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            Colors.white,
            Color(0xFFFFFEFA),
            Color(0xFFF5F9EE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE7D8)),
        boxShadow: [
          BoxShadow(
            color: _notifDarkGreen.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final info = Row(
            children: [
              const _IntroIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'الإشعارات' : 'Notifications',
                      style: const TextStyle(
                        color: _notifTextPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'ابقَ على اطلاع بالطلبات والتشخيصات والتذكيرات ونشاط المزرعة.'
                          : 'Stay updated with orders, diagnoses, reminders and farm activity.',
                      style: const TextStyle(
                        color: _notifTextSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _NotifStat(
                icon: Icons.notifications_outlined,
                label: isArabic ? '$total إجمالي' : '$total total',
                background: const Color(0xFFEAF3DF),
                foreground: _notifPrimaryGreen,
              ),
              _NotifStat(
                icon: Icons.mark_email_unread_outlined,
                label: isArabic ? '$unread غير مقروء' : '$unread unread',
                background: const Color(0xFFFFF0DE),
                foreground: const Color(0xFFB46A2C),
              ),
            ],
          );

          if (constraints.maxWidth < 650) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 18),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 18),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _IntroIcon extends StatelessWidget {
  const _IntroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Icon(
        Icons.notifications_active_outlined,
        color: _notifPrimaryGreen,
        size: 28,
      ),
    );
  }
}

class _NotifStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _NotifStat({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final bool isArabic;

  const _EmptyNotifications({
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 470),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFDDE6D8)),
            boxShadow: [
              BoxShadow(
                color: _notifDarkGreen.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 72,
                color: _notifPrimaryGreen,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'لا توجد إشعارات بعد' : 'No notifications yet',
                style: const TextStyle(
                  color: _notifTextPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'ستظهر آخر تحديثات FarmPilot هنا.'
                    : 'Your latest FarmPilot updates will appear here.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _notifTextSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsBackdrop extends StatelessWidget {
  const _NotificationsBackdrop();

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
                  Color(0xFFF4F8ED),
                ],
                stops: [0.0, 0.50, 1.0],
              ),
            ),
          ),
          PositionedDirectional(
            end: -190,
            top: 210,
            child: Container(
              width: 470,
              height: 470,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCFE6B4).withValues(alpha: 0.28),
                    const Color(0xFFCFE6B4).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE7DFAF).withValues(alpha: 0.22),
                    const Color(0xFFE7DFAF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard
    extends StatelessWidget {
  final bool isArabic;
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.isArabic,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final role =
        authProvider.userData?['role']
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    final isCustomer =
        role == 'CUSTOMER';

    final id =
        notification['id']?.toString() ?? '';

    final fallbackTitle =
        notification['title']?.toString() ??
            'Notification';

    final fallbackMessage =
        notification['message']?.toString() ??
            '';

    final localizedTitle =
        (isArabic
                ? notification['titleAr']
                : notification['titleEn'])
            ?.toString()
            .trim();

    final localizedMessage =
        (isArabic
                ? notification['messageAr']
                : notification['messageEn'])
            ?.toString()
            .trim();

    final customerFallbackTitle =
        isArabic && isCustomer
            ? _legacyCustomerTitleArabic(
                fallbackTitle,
              )
            : fallbackTitle;

    final customerFallbackMessage =
        isArabic && isCustomer
            ? _legacyCustomerMessageArabic(
                fallbackMessage,
              )
            : fallbackMessage;

    final title =
        localizedTitle != null &&
                localizedTitle.isNotEmpty
            ? localizedTitle
            : customerFallbackTitle;

    final message =
        localizedMessage != null &&
                localizedMessage.isNotEmpty
            ? localizedMessage
            : customerFallbackMessage;

    final type =
        notification['type']?.toString() ?? '';

    final diagnosisId =
        notification['diagnosisId']
            ?.toString();

    final isRead =
        notification['isRead'] == true;

    final createdAt = DateTime.tryParse(
      notification['createdAt']
              ?.toString() ??
          '',
    );

    final hasDiagnosis =
        diagnosisId != null &&
            diagnosisId.trim().isNotEmpty;

    final normalizedType =
        type.trim().toUpperCase();

    final isOrderNotification =
        normalizedType.contains('ORDER');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isRead ? Colors.white : const Color(0xFFF4F9ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isRead
              ? const Color(0xFFDDE6D8)
              : const Color(0xFFC7DDB8),
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(22),
        onTap: () async {
          final notificationProvider =
              Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          if (!isRead && id.isNotEmpty) {
            final success =
                await notificationProvider
                    .markAsRead(
              id,
            );

            if (!context.mounted) {
              return;
            }

            if (!success) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      notificationProvider
                              .errorMessage ??
                          (isArabic
                              ? 'تعذر تحديد الإشعار كمقروء'
                              : 'Failed to mark notification as read'),
                    ),
                    backgroundColor:
                        Colors.red,
                  ),
                );

              return;
            }
          }

          if (!context.mounted) {
            return;
          }

          // Diagnosis notification
          if (hasDiagnosis) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NotificationDiagnosisScreen(
                  diagnosisId:
                      diagnosisId.trim(),
                ),
              ),
            );

            return;
          }

          // Order notification
          if (isOrderNotification) {
            final authProvider =
                Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            final role = authProvider
                    .userData?['role']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                '';

            if (!context.mounted) {
              return;
            }

            if (role == 'FARMER') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FarmerOrdersScreen(),
                ),
              );

              return;
            }

            if (role == 'CUSTOMER') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CustomerOrdersScreen(),
                ),
              );

              return;
            }
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isRead
                    ? const Color(0xFFF0F2EF)
                    : const Color(0xFFE0EECF),
                child: Icon(
                  _getNotificationIcon(
                    type,
                  ),
                  color: isRead
                      ? _notifTextSecondary
                      : _notifPrimaryGreen,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration:
                                const BoxDecoration(
                              color: _notifPrimaryGreen,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Tooltip(
                          message:
                              isArabic ? 'حذف' : 'Delete',
                          child: InkWell(
                            onTap: onDelete,
                            borderRadius:
                                BorderRadius.circular(10),
                            child: const Padding(
                              padding:
                                  EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (message.isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              _notifTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],

                    if (hasDiagnosis) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.open_in_new_outlined,
                            size: 16,
                            color:
                                _notifPrimaryGreen,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            isArabic ? 'اضغط لعرض التشخيص' : 'Tap to view diagnosis',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _notifPrimaryGreen,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (isOrderNotification) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.open_in_new_outlined,
                            size: 16,
                            color:
                                _notifPrimaryGreen,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            isArabic ? 'اضغط لعرض الطلبات' : 'Tap to view orders',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _notifPrimaryGreen,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        if (type.isNotEmpty)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .green.shade100,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),
                            child: Text(
                              _localizedNotificationType(
                                type,
                                isArabic,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors
                                    .green.shade800,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (createdAt != null)
                          Text(
                            _formatDate(
                              createdAt,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  _notifTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              if (hasDiagnosis ||
                  isOrderNotification)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    left: 8,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _legacyCustomerTitleArabic(
    String title,
  ) {
    final normalized =
        title.trim().toLowerCase();

    const translations =
        <String, String>{
      'new order': 'طلب جديد',
      'order confirmed': 'تم تأكيد الطلب',
      'order completed': 'تم إكمال الطلب',
      'order cancelled': 'تم إلغاء الطلب',
      'order canceled': 'تم إلغاء الطلب',
      'order pending': 'الطلب قيد الانتظار',
      'new review': 'تقييم جديد',
      'irrigation reminder': 'تذكير بالري',
      'fertilization reminder': 'تذكير بالتسميد',
      'reminder': 'تذكير',
      'notification': 'إشعار',
    };

    return translations[normalized] ??
        title;
  }

  String _legacyCustomerMessageArabic(
    String message,
  ) {
    final normalized =
        message.trim().toLowerCase();

    const exactTranslations =
        <String, String>{
      'you have received a new order.':
          'لقد استلمت طلبًا جديدًا.',
      'you have received a new order':
          'لقد استلمت طلبًا جديدًا.',
      'your order has been confirmed by the farmer.':
          'تم تأكيد طلبك من قبل المزارع.',
      'your order has been confirmed by the farmer':
          'تم تأكيد طلبك من قبل المزارع.',
      'your order has been completed successfully.':
          'تم إكمال طلبك بنجاح.',
      'your order has been completed successfully':
          'تم إكمال طلبك بنجاح.',
      'your order has been cancelled.':
          'تم إلغاء طلبك.',
      'your order has been cancelled':
          'تم إلغاء طلبك.',
      'your order has been canceled.':
          'تم إلغاء طلبك.',
      'your order has been canceled':
          'تم إلغاء طلبك.',
    };

    final exact =
        exactTranslations[normalized];

    if (exact != null) {
      return exact;
    }

    return message;
  }

  IconData _getNotificationIcon(
    String type,
  ) {
    final normalizedType =
        type.toUpperCase();

    if (normalizedType.contains(
      'DIAGNOSIS_HIGH_RISK',
    )) {
      return Icons.warning_amber_rounded;
    }

    if (normalizedType.contains(
      'DIAGNOSIS',
    )) {
      return Icons
          .health_and_safety_outlined;
    }

    if (normalizedType.contains(
      'ORDER',
    )) {
      return Icons.shopping_bag_outlined;
    }

    if (normalizedType.contains(
      'REMINDER',
    )) {
      return Icons.alarm_outlined;
    }

    if (normalizedType.contains(
      'PRODUCT',
    )) {
      return Icons.storefront_outlined;
    }

    if (normalizedType.contains(
      'CROP',
    )) {
      return Icons.eco_outlined;
    }

    if (normalizedType.contains(
      'REVIEW',
    )) {
      return Icons.star_outline;
    }

    return Icons.notifications_outlined;
  }

  String _localizedNotificationType(
    String type,
    bool isArabic,
  ) {
    if (!isArabic) {
      return type;
    }

    final normalized =
        type.toUpperCase();

    if (normalized.contains('ORDER')) {
      return 'طلب';
    }

    if (normalized.contains('DIAGNOSIS_HIGH_RISK')) {
      return 'تشخيص عالي الخطورة';
    }

    if (normalized.contains('DIAGNOSIS_MODERATE_RISK')) {
      return 'تشخيص متوسط الخطورة';
    }

    if (normalized.contains('DIAGNOSIS_HEALTHY')) {
      return 'تشخيص سليم';
    }

    if (normalized.contains('DIAGNOSIS_EXPERT_REVIEW')) {
      return 'مراجعة مختص';
    }

    if (normalized.contains('DIAGNOSIS')) {
      return 'تشخيص';
    }

    if (normalized.contains('REMINDER')) {
      return 'تذكير';
    }

    if (normalized.contains('PRODUCT')) {
      return 'منتج';
    }

    if (normalized.contains('CROP')) {
      return 'محصول';
    }

    if (normalized.contains('REVIEW')) {
      return 'تقييم';
    }

    return type;
  }

  String _formatDate(
    DateTime date,
  ) {
    final localDate =
        date.toLocal();

    final day =
        localDate.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        localDate.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final year =
        localDate.year;

    final hour =
        localDate.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final minute =
        localDate.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/$year  $hour:$minute';
  }
}