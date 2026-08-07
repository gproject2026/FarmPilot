import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
  });

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends State<AdminUsersScreen> {
  String? _updatingUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadUsers();
      },
    );
  }

  Future<void> _loadUsers() async {
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).loadAllUsers();
  }

  Future<void> _changeUserStatus({
    required UserModel user,
  }) async {
    final newStatus = !user.isActive;

    final confirmed =
        await _showConfirmationDialog(
      user: user,
      newStatus: newStatus,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _updatingUserId = user.id;
    });

    final userProvider =
        Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final success =
        await userProvider.updateUserStatus(
      userId: user.id,
      isActive: newStatus,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _updatingUserId = null;
    });

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '${user.fullName} account has been unblocked'
                  : '${user.fullName} account has been blocked',
            ),
            backgroundColor:
                newStatus
                    ? Colors.green
                    : Colors.orange,
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              userProvider.errorMessage ??
                  'Failed to update user status',
            ),
            backgroundColor:
                Colors.red,
          ),
        );
    }
  }

  Future<bool> _showConfirmationDialog({
    required UserModel user,
    required bool newStatus,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            newStatus
                ? 'Unblock User'
                : 'Block User',
          ),
          content: Text(
            newStatus
                ? 'Are you sure you want to unblock ${user.fullName}? They will be able to log in again.'
                : 'Are you sure you want to block ${user.fullName}? They will not be able to log in while the account is blocked.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    newStatus
                        ? Colors.green
                        : Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child: Text(
                newStatus
                    ? 'Unblock'
                    : 'Block',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider =
        Provider.of<UserProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Manage Users',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                userProvider.isLoading
                    ? null
                    : _loadUsers,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(
        userProvider,
      ),
    );
  }

  Widget _buildBody(
    UserProvider userProvider,
  ) {
    if (userProvider.isLoading &&
        userProvider.users.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (userProvider.errorMessage != null &&
        userProvider.users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height: 150,
            ),
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              userProvider.errorMessage!,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child:
                  ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (userProvider.users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: const [
            SizedBox(
              height: 150,
            ),
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(
              height: 18,
            ),
            Center(
              child: Text(
                'No users found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadUsers,
          child: ListView.builder(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.all(
              16,
            ),
            itemCount:
                userProvider.users.length,
            itemBuilder: (
              context,
              index,
            ) {
              final user =
                  userProvider.users[index];

              return _userCard(
                user,
              );
            },
          ),
        ),
        if (userProvider.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child:
                LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _userCard(
    UserModel user,
  ) {
    final roleColor =
        _roleColor(
      user.role,
    );

    final statusColor =
        user.isActive
            ? Colors.green
            : Colors.red;

    final isUpdating =
        _updatingUserId == user.id;

    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      roleColor.withValues(
                    alpha: 0.15,
                  ),
                  backgroundImage:
                      user.profileImage !=
                                  null &&
                              user.profileImage!
                                  .isNotEmpty
                          ? NetworkImage(
                              user.profileImage!,
                            )
                          : null,
                  child:
                      user.profileImage ==
                                  null ||
                              user.profileImage!
                                  .isEmpty
                          ? Icon(
                              _roleIcon(
                                user.role,
                              ),
                              color:
                                  roleColor,
                              size: 28,
                            )
                          : null,
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isEmpty
                            ? 'Unnamed User'
                            : user.fullName,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        user.email,
                        style:
                            TextStyle(
                          fontSize: 14,
                          color: Colors
                              .grey.shade700,
                        ),
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(
                            text:
                                user.role,
                            color:
                                roleColor,
                            icon:
                                _roleIcon(
                              user.role,
                            ),
                          ),
                          _buildBadge(
                            text:
                                user.isActive
                                    ? 'ACTIVE'
                                    : 'BLOCKED',
                            color:
                                statusColor,
                            icon:
                                user.isActive
                                    ? Icons
                                        .check_circle_outline
                                    : Icons
                                        .block,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (user.phone != null &&
                user.phone!.isNotEmpty)
              _infoRow(
                icon:
                    Icons.phone_outlined,
                text: user.phone!,
              ),
            if (user.address != null &&
                user.address!.isNotEmpty)
              _infoRow(
                icon: Icons
                    .location_on_outlined,
                text: user.address!,
              ),
            if (user.createdAt != null)
              _infoRow(
                icon: Icons
                    .calendar_today_outlined,
                text:
                    'Joined: ${_formatDate(user.createdAt!)}',
              ),
            const SizedBox(
              height: 14,
            ),
            const Divider(),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Status',
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        user.isActive
                            ? 'This account can access FarmPilot'
                            : 'This account cannot log in',
                        style:
                            TextStyle(
                          fontSize: 12,
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      _changeUserStatus(
                        user: user,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          user.isActive
                              ? Colors.red
                              : Colors.green,
                      foregroundColor:
                          Colors.white,
                    ),
                    icon: Icon(
                      user.isActive
                          ? Icons.block
                          : Icons
                              .lock_open_outlined,
                    ),
                    label: Text(
                      user.isActive
                          ? 'Block User'
                          : 'Unblock User',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color:
                Colors.grey.shade700,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color:
                    Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(
    String role,
  ) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'FARMER':
        return Colors.green;
      case 'CUSTOMER':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(
    String role,
  ) {
    switch (role) {
      case 'ADMIN':
        return Icons
            .admin_panel_settings;
      case 'FARMER':
        return Icons.agriculture;
      case 'CUSTOMER':
        return Icons.person_outline;
      default:
        return Icons.person;
    }
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}