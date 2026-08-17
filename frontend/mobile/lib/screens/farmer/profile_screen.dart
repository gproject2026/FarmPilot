import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final roleController =
      TextEditingController();

  bool fieldsInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        context
            .read<ProfileProvider>()
            .loadProfile();
      },
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    roleController.dispose();

    super.dispose();
  }

  void initializeFields(
    ProfileProvider provider,
  ) {
    if (
      fieldsInitialized ||
      provider.user == null
    ) {
      return;
    }

    final user =
        provider.user!;

    fullNameController.text =
        user.fullName;

    phoneController.text =
        user.phone ?? '';

    addressController.text =
        user.address ?? '';

    emailController.text =
        user.email;

    roleController.text =
        user.role;

    fieldsInitialized = true;
  }

  Future<void> saveProfile() async {
    final fullName =
        fullNameController.text
            .trim();

    final phone =
        phoneController.text
            .trim();

    final address =
        addressController.text
            .trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your full name',
          ),
        ),
      );

      return;
    }

    final profileProvider =
        context.read<ProfileProvider>();

    try {
      await profileProvider
          .updateProfile(
        fullName:
            fullName,
        phone:
            phone,
        address:
            address,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully',
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2F6B3D),
              ),
            );
          }

          if (provider.errorMessage != null && provider.user == null) {
            return _ProfileErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadProfile,
            );
          }

          if (provider.user == null) {
            return const Center(
              child: Text('Profile data not found'),
            );
          }

          initializeFields(provider);
          final user = provider.user!;

          return Stack(
            children: [
              const Positioned.fill(child: _ProfileBackdrop()),
              Column(
                children: [
                  _ProfileTopBar(
                    onBack: () => Navigator.pop(context),
                    onRefresh: provider.isLoading
                        ? null
                        : () async {
                            fieldsInitialized = false;
                            await provider.loadProfile();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 42),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Column(
                            children: [
                              _ProfileHero(
                                fullName: user.fullName,
                                email: user.email,
                                role: user.role,
                                profileImage: user.profileImage,
                              ),
                              const SizedBox(height: 22),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final form = _ProfileFormCard(
                                    fullNameController: fullNameController,
                                    emailController: emailController,
                                    phoneController: phoneController,
                                    addressController: addressController,
                                    roleController: roleController,
                                    isSaving: provider.isSaving,
                                    onSave: saveProfile,
                                  );

                                  final side = _ProfileSideCard(
                                    fullName: user.fullName,
                                    email: user.email,
                                    role: user.role,
                                  );

                                  if (constraints.maxWidth < 820) {
                                    return Column(
                                      children: [
                                        form,
                                        const SizedBox(height: 18),
                                        side,
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 7, child: form),
                                      const SizedBox(width: 20),
                                      Expanded(flex: 3, child: side),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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

const _profileDarkGreen = Color(0xFF173F24);
const _profilePrimaryGreen = Color(0xFF2F6B3D);
const _profileLightGreen = Color(0xFFDDECB8);
const _profileText = Color(0xFF1D2C21);
const _profileMuted = Color(0xFF6C786E);

class _ProfileTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const _ProfileTopBar({
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
            _TopButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _profileLightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _profileDarkGreen,
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
                  SizedBox(height: 1),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _TopButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh profile',
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _TopButton({
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

class _ProfileHero extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;
  final String? profileImage;

  const _ProfileHero({
    required this.fullName,
    required this.email,
    required this.role,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            Colors.white,
            Color(0xFFFFFEFA),
            Color(0xFFF4F8EC),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDCE6D7)),
        boxShadow: [
          BoxShadow(
            color: _profileDarkGreen.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatar = _ProfileAvatar(
            profileImage: profileImage,
            fullName: fullName,
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _profileText,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _RoleChip(role: role),
            ],
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 16),
                details,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 20),
              Expanded(child: details),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  color: _profilePrimaryGreen,
                  size: 29,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? profileImage;
  final String fullName;

  const _ProfileAvatar({
    required this.profileImage,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = profileImage != null && profileImage!.isNotEmpty;
    final trimmed = fullName.trim();
    final initial = trimmed.isEmpty ? 'U' : trimmed[0].toUpperCase();

    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE4EFCF),
      ),
      child: CircleAvatar(
        backgroundColor: _profilePrimaryGreen,
        backgroundImage: hasImage ? NetworkImage(profileImage!) : null,
        child: hasImage
            ? null
            : Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: _profilePrimaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            role,
            style: const TextStyle(
              color: _profilePrimaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController roleController;
  final bool isSaving;
  final Future<void> Function() onSave;

  const _ProfileFormCard({
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.roleController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.edit_note_rounded,
            title: 'Personal Information',
            subtitle: 'Update the information associated with your account.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 620) {
                return Column(
                  children: [
                    _ProfileField(
                      controller: fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 15),
                    _ProfileField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 15),
                    _ProfileField(
                      controller: phoneController,
                      label: 'Phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    _ProfileField(
                      controller: roleController,
                      label: 'Role',
                      icon: Icons.badge_outlined,
                      readOnly: true,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                          controller: fullNameController,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _ProfileField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                          controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _ProfileField(
                          controller: roleController,
                          label: 'Role',
                          icon: Icons.badge_outlined,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 15),
          _ProfileField(
            controller: addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profilePrimaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _profilePrimaryGreen.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 20),
              label: Text(
                isSaving ? 'Saving...' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _profileText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _profileMuted),
        prefixIcon: Icon(icon, color: _profilePrimaryGreen, size: 21),
        filled: true,
        fillColor:
            readOnly ? const Color(0xFFF3F5F1) : const Color(0xFFFCFDFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD8E2D4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD8E2D4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _profilePrimaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ProfileSideCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;

  const _ProfileSideCard({
    required this.fullName,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.shield_outlined,
            title: 'Account',
            subtitle: 'Your FarmPilot account information.',
          ),
          const SizedBox(height: 20),
          _AccountInfoRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: fullName,
          ),
          const Divider(height: 28, color: Color(0xFFE2E8DE)),
          _AccountInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          const Divider(height: 28, color: Color(0xFFE2E8DE)),
          _AccountInfoRow(
            icon: Icons.badge_outlined,
            label: 'Account type',
            value: role,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: _profilePrimaryGreen,
                  size: 19,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Email and account role are protected and cannot be changed here.',
                    style: TextStyle(
                      color: _profileMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
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

class _AccountInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _profilePrimaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: _profileText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _profilePrimaryGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _profileText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProfileErrorState({
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
        decoration: _cardDecoration(),
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
                color: _profileText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profilePrimaryGreen,
                foregroundColor: Colors.white,
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

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

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
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 160,
            child: _Glow(
              size: 470,
              color: Color(0xFFCFE6B4),
            ),
          ),
          PositionedDirectional(
            start: -200,
            bottom: -230,
            child: _Glow(
              size: 520,
              color: Color(0xFFE7DFAF),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFDCE5D8)),
    boxShadow: [
      BoxShadow(
        color: _profileDarkGreen.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
