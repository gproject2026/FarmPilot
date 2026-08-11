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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
        ),
      ),
      body:
          Consumer<ProfileProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (
            provider.isLoading &&
            provider.user == null
          ) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (
            provider.errorMessage !=
                    null &&
            provider.user == null
          ) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Text(
                      provider
                          .errorMessage!,
                      textAlign:
                          TextAlign
                              .center,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed:
                          provider
                              .loadProfile,
                      child:
                          const Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (
            provider.user == null
          ) {
            return const Center(
              child: Text(
                'Profile data not found',
              ),
            );
          }

          initializeFields(
            provider,
          );

          final user =
              provider.user!;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
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
                          ? const Icon(
                              Icons.person,
                              size: 55,
                            )
                          : null,
                ),

                const SizedBox(
                  height: 20,
                ),

                TextField(
                  controller:
                      fullNameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Full Name',
                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      emailController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Email',
                    prefixIcon:
                        Icon(
                      Icons
                          .email_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      phoneController,
                  keyboardType:
                      TextInputType.phone,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Phone',
                    prefixIcon:
                        Icon(
                      Icons
                          .phone_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      addressController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Address',
                    prefixIcon:
                        Icon(
                      Icons
                          .location_on_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      roleController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Role',
                    prefixIcon:
                        Icon(
                      Icons
                          .badge_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      ElevatedButton(
                    onPressed:
                        provider.isSaving
                            ? null
                            : saveProfile,
                    child:
                        provider.isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}