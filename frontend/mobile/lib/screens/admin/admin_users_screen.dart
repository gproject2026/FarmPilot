import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String? _updatingUserId;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    await Provider.of<UserProvider>(context, listen: false).loadAllUsers();
  }

  Future<void> _changeUserStatus({required UserModel user}) async {
    final newStatus = !user.isActive;

    final confirmed = await _showConfirmationDialog(
      user: user,
      newStatus: newStatus,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _updatingUserId = user.id;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await userProvider.updateUserStatus(
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
                  ? (_isArabic
                        ? 'تم إلغاء حظر حساب ${user.fullName}'
                        : '${user.fullName} account has been unblocked')
                  : (_isArabic
                        ? 'تم حظر حساب ${user.fullName}'
                        : '${user.fullName} account has been blocked'),
            ),
            backgroundColor: const Color(0xFF2F743F),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              userProvider.errorMessage ??
                  (_isArabic
                      ? 'فشل تحديث حالة المستخدم'
                      : 'Failed to update user status'),
            ),
            backgroundColor: Colors.red,
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
                ? (_isArabic ? 'إلغاء حظر المستخدم' : 'Unblock User')
                : (_isArabic ? 'حظر المستخدم' : 'Block User'),
          ),
          content: Text(
            newStatus
                ? (_isArabic
                      ? 'هل أنت متأكد من إلغاء حظر ${user.fullName}؟ سيتمكن من تسجيل الدخول مرة أخرى.'
                      : 'Are you sure you want to unblock ${user.fullName}? They will be able to log in again.')
                : (_isArabic
                      ? 'هل أنت متأكد من حظر ${user.fullName}؟ لن يتمكن من تسجيل الدخول ما دام الحساب محظورًا.'
                      : 'Are you sure you want to block ${user.fullName}? They will not be able to log in while the account is blocked.'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(_isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                newStatus
                    ? (_isArabic ? 'إلغاء الحظر' : 'Unblock')
                    : (_isArabic ? 'حظر' : 'Block'),
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
    final userProvider = Provider.of<UserProvider>(context);

    final users = userProvider.users;
    final activeCount = users.where((user) => user.isActive).length;
    final blockedCount = users.length - activeCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(child: _AdminUsersBackdrop()),
          Column(
            children: [
              _AdminUsersTopBar(
                isArabic: _isArabic,
                onBack: () => Navigator.pop(context),
                onLanguage: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).toggleLanguage();
                },
                onRefresh: userProvider.isLoading ? null : _loadUsers,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadUsers,
                  color: _adminUsersPrimary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                26,
                                24,
                                18,
                              ),
                              child: _AdminUsersHero(
                                isArabic: _isArabic,
                                totalUsers: users.length,
                                activeUsers: activeCount,
                                blockedUsers: blockedCount,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (userProvider.isLoading && users.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _adminUsersPrimary,
                            ),
                          ),
                        )
                      else if (userProvider.errorMessage != null &&
                          users.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _AdminUsersErrorState(
                            isArabic: _isArabic,
                            message: userProvider.errorMessage!,
                            onRetry: _loadUsers,
                          ),
                        )
                      else if (users.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _AdminUsersEmptyState(isArabic: _isArabic),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 42),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.crossAxisExtent;

                              final crossAxisCount = width >= 1180
                                  ? 3
                                  : width >= 760
                                  ? 2
                                  : 1;

                              return SliverGrid(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final user = users[index];

                                  return _AdminUserCard(
                                    isArabic: _isArabic,
                                    user: user,
                                    roleColor: _roleColor(user.role),
                                    roleIcon: _roleIcon(user.role),
                                    isUpdating: _updatingUserId == user.id,
                                    formatDate: _formatDate,
                                    onChangeStatus: () {
                                      _changeUserStatus(user: user);
                                    },
                                  );
                                }, childCount: users.length),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 360,
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
      ),
    );
  }

  Color _roleColor(String role) {
  switch (role.trim().toUpperCase()) {
    case 'ADMIN':
      return Colors.red;

    case 'FARMER':
      return Colors.green;

    case 'CUSTOMER':
      return Colors.blue;

    case 'SUPPLIER':
      return Colors.orange;

    default:
      return Colors.grey;
  }
}

  IconData _roleIcon(String role) {
  switch (role.trim().toUpperCase()) {
    case 'ADMIN':
      return Icons.admin_panel_settings;

    case 'FARMER':
      return Icons.agriculture;

    case 'CUSTOMER':
      return Icons.person_outline;

    case 'SUPPLIER':
      return Icons.storefront_outlined;

    default:
      return Icons.person;
  }
}

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

const _adminUsersDark = Color(0xFF173F24);
const _adminUsersPrimary = Color(0xFF2F743F);
const _adminUsersLight = Color(0xFFEAF3DF);
const _adminUsersText = Color(0xFF1D2C21);
const _adminUsersMuted = Color(0xFF6C786E);

class _AdminUsersTopBar extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onBack;
  final VoidCallback onLanguage;
  final Future<void> Function()? onRefresh;

  const _AdminUsersTopBar({
    required this.isArabic,
    required this.onBack,
    required this.onLanguage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF123A22), Color(0xFF205A34), Color(0xFF2E6F40)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _AdminUsersHeaderButton(
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
              child: const Icon(Icons.eco_rounded, color: _adminUsersDark),
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
                    isArabic ? 'إدارة المستخدمين' : 'Manage Users',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _AdminUsersHeaderButton(
              icon: Icons.language_rounded,
              tooltip: isArabic
                  ? 'تغيير اللغة إلى الإنجليزية'
                  : 'Change language to Arabic',
              onTap: onLanguage,
            ),
            const SizedBox(width: 8),
            _AdminUsersHeaderButton(
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

class _AdminUsersHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AdminUsersHeaderButton({
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
              size: 21,
              color: onTap == null ? Colors.white54 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminUsersHero extends StatelessWidget {
  final bool isArabic;
  final int totalUsers;
  final int activeUsers;
  final int blockedUsers;

  const _AdminUsersHero({
    required this.isArabic,
    required this.totalUsers,
    required this.activeUsers,
    required this.blockedUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _adminUsersCardDecoration(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _adminUsersLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  color: _adminUsersPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'إدارة المستخدمين' : 'Manage Users',
                      style: const TextStyle(
                        color: _adminUsersText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'مراجعة حسابات المستخدمين والأدوار وحالة الوصول في FarmPilot.'
                          : 'Review user accounts, roles and access status across FarmPilot.',
                      style: const TextStyle(
                        color: _adminUsersMuted,
                        fontSize: 13,
                        height: 1.4,
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
              _AdminUsersStatChip(
                label: isArabic ? 'الإجمالي' : 'Total',
                value: totalUsers,
              ),
              _AdminUsersStatChip(
                label: isArabic ? 'نشط' : 'Active',
                value: activeUsers,
              ),
              _AdminUsersStatChip(
                label: isArabic ? 'محظور' : 'Blocked',
                value: blockedUsers,
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 18), stats],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 18),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _AdminUsersStatChip extends StatelessWidget {
  final String label;
  final int value;

  const _AdminUsersStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: _adminUsersPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  final bool isArabic;
  final UserModel user;
  final Color roleColor;
  final IconData roleIcon;
  final bool isUpdating;
  final String Function(DateTime) formatDate;
  final VoidCallback onChangeStatus;

  const _AdminUserCard({
    required this.isArabic,
    required this.user,
    required this.roleColor,
    required this.roleIcon,
    required this.isUpdating,
    required this.formatDate,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive
        ? const Color(0xFF3F8A50)
        : const Color(0xFFC65353);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _adminUsersCardDecoration(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: roleColor.withValues(alpha: 0.12),
                backgroundImage:
                    user.profileImage != null && user.profileImage!.isNotEmpty
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null || user.profileImage!.isEmpty
                    ? Icon(roleIcon, color: roleColor, size: 28)
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty
                          ? (isArabic ? 'مستخدم بدون اسم' : 'Unnamed User')
                          : user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _adminUsersText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _adminUsersMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AdminUserBadge(
                text: _localizedRole(user.role, isArabic),
                color: roleColor,
                icon: roleIcon,
              ),
              _AdminUserBadge(
                text: user.isActive
                    ? (isArabic ? 'نشط' : 'ACTIVE')
                    : (isArabic ? 'محظور' : 'BLOCKED'),
                color: statusColor,
                icon: user.isActive
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (user.phone != null && user.phone!.isNotEmpty)
            _AdminUserInfoRow(icon: Icons.phone_outlined, text: user.phone!),
          if (user.address != null && user.address!.isNotEmpty)
            _AdminUserInfoRow(
              icon: Icons.location_on_outlined,
              text: user.address!,
            ),
          if (user.createdAt != null)
            _AdminUserInfoRow(
              icon: Icons.calendar_today_outlined,
              text: isArabic
                  ? 'تاريخ الانضمام: ${formatDate(user.createdAt!)}'
                  : 'Joined: ${formatDate(user.createdAt!)}',
            ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCF9),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE3E9DF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'حالة الحساب' : 'Account Status',
                        style: const TextStyle(
                          color: _adminUsersText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.isActive
                            ? (isArabic
                                  ? 'يمكن لهذا الحساب الوصول إلى FarmPilot'
                                  : 'This account can access FarmPilot')
                            : (isArabic
                                  ? 'لا يمكن لهذا الحساب تسجيل الدخول'
                                  : 'This account cannot log in'),
                        style: const TextStyle(
                          color: _adminUsersMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isUpdating)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _adminUsersPrimary,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onChangeStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isActive
                          ? const Color(0xFFC65353)
                          : _adminUsersPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      user.isActive
                          ? Icons.block_rounded
                          : Icons.lock_open_outlined,
                      size: 17,
                    ),
                    label: Text(
                      user.isActive
                          ? (isArabic ? 'حظر' : 'Block')
                          : (isArabic ? 'إلغاء الحظر' : 'Unblock'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUserBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _AdminUserBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUserInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdminUserInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _adminUsersLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: _adminUsersPrimary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _adminUsersText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUsersEmptyState extends StatelessWidget {
  final bool isArabic;

  const _AdminUsersEmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: _adminUsersCardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: _adminUsersLight,
              child: Icon(
                Icons.people_outline_rounded,
                size: 38,
                color: _adminUsersPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'لم يتم العثور على مستخدمين' : 'No users found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _adminUsersText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUsersErrorState extends StatelessWidget {
  final bool isArabic;
  final String message;
  final Future<void> Function() onRetry;

  const _AdminUsersErrorState({
    required this.isArabic,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: _adminUsersCardDecoration(24),
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
              style: const TextStyle(color: _adminUsersText, fontSize: 14),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _adminUsersPrimary,
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

class _AdminUsersBackdrop extends StatelessWidget {
  const _AdminUsersBackdrop();

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
            child: _AdminUsersGlow(size: 450, color: const Color(0xFFCFE6B4)),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: _AdminUsersGlow(size: 520, color: const Color(0xFFE7DFAF)),
          ),
        ],
      ),
    );
  }
}

class _AdminUsersGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AdminUsersGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

String _localizedRole(
  String role,
  bool isArabic,
) {
  final normalizedRole =
      role.trim().toUpperCase();

  if (!isArabic) {
    return normalizedRole;
  }

  switch (normalizedRole) {
    case 'ADMIN':
      return 'مسؤول';

    case 'FARMER':
      return 'مزارع';

    case 'CUSTOMER':
      return 'عميل';

    case 'SUPPLIER':
      return 'مورد';

    default:
      return role;
  }
}

BoxDecoration _adminUsersCardDecoration(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFDCE5D8)),
    boxShadow: [
      BoxShadow(
        color: _adminUsersDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
