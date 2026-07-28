import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen
    extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
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
              e
                  .toString()
                  .replaceFirst(
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
          const SnackBar(
            content: Text(
              'All notifications are already read',
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
                'All notifications marked as read',
          ),
          backgroundColor:
              notificationProvider.errorMessage == null
                  ? Colors.green
                  : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (notificationProvider.unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed:
                  notificationProvider.isLoading
                      ? null
                      : _markAllAsRead,
              icon: const Icon(
                Icons.done_all,
              ),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                notificationProvider.isLoading
                    ? null
                    : _loadNotifications,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: notificationProvider.isLoading &&
              notificationProvider
                  .notifications.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : notificationProvider
                  .notifications.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 180,
                      ),
                      Icon(
                        Icons
                            .notifications_none_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Text(
                          'Your notifications will appear here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        notificationProvider
                            .notifications.length,
                    separatorBuilder: (
                      context,
                      index,
                    ) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final notification =
                          Map<String, dynamic>.from(
                        notificationProvider
                            .notifications[index],
                      );

                      return _NotificationCard(
                        notification:
                            notification,
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationCard
    extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final id =
        notification['id']?.toString() ?? '';

    final title =
        notification['title']?.toString() ??
            'Notification';

    final message =
        notification['message']?.toString() ??
            '';

    final type =
        notification['type']?.toString() ?? '';

    final isRead =
        notification['isRead'] == true;

    final createdAt =
        DateTime.tryParse(
      notification['createdAt']
              ?.toString() ??
          '',
    );

    return Card(
      elevation: isRead ? 1 : 3,
      color: isRead
          ? Colors.white
          : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: isRead
              ? Colors.grey.shade200
              : Colors.green.shade200,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () async {
          if (isRead || id.isEmpty) {
            return;
          }

          final provider =
              Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          final success =
              await provider.markAsRead(id);

          if (!context.mounted) {
            return;
          }

          if (!success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    provider.errorMessage ??
                        'Failed to mark notification as read',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
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
                    ? Colors.grey.shade200
                    : Colors.green.shade100,
                child: Icon(
                  _getNotificationIcon(
                    type,
                  ),
                  color: isRead
                      ? Colors.grey.shade600
                      : Colors.green.shade700,
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
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration:
                                const BoxDecoration(
                              color: Colors.green,
                              shape:
                                  BoxShape.circle,
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
                              Colors.grey.shade700,
                          height: 1.4,
                        ),
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
                              type,
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
                                  Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(
    String type,
  ) {
    final normalizedType =
        type.toUpperCase();

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

  String _formatDate(
    DateTime date,
  ) {
    final localDate = date.toLocal();

    final day =
        localDate.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        localDate.month.toString().padLeft(
              2,
              '0',
            );

    final year = localDate.year;

    final hour =
        localDate.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        localDate.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year  $hour:$minute';
  }
}