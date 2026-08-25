import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _fullNameController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _phoneController =
      TextEditingController();
  final _addressController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _selectedRole = 'CUSTOMER';

  static const Color _green =
      Color(0xFF1F6B45);
  static const Color _darkGreen =
      Color(0xFF164D34);

  static const Color _background =
      Color(0xFFF7F8F5);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  AppLocalizations get l10n =>
      AppLocalizations.of(context)!;

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    try {
      await authProvider.register(
        fullName:
            _fullNameController.text.trim(),
        email:
            _emailController.text.trim(),
        password:
            _passwordController.text,
        phone:
            _phoneController.text.trim(),
        role: _selectedRole,
        address:
            _addressController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.accountCreatedSuccessfully,
          ),
          backgroundColor: _green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              Colors.red.shade700,
        ),
      );
    }
  }

  String? _requiredValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return l10n.pleaseFillAllFields;
    }

    return null;
  }

  String? _emailValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return l10n.pleaseFillAllFields;
    }

    final email =
        value.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  String? _passwordValidator(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return l10n.pleaseFillAllFields;
    }

    if (value.length < 6) {
      return l10n.passwordTooShort;
    }

    return null;
  }

  String? _confirmPasswordValidator(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return l10n.pleaseFillAllFields;
    }

    if (value !=
        _passwordController.text) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }

  void _changeLanguage() {
    final localeProvider =
        context.read<LocaleProvider>();

    final currentLanguage =
        Localizations.localeOf(context)
            .languageCode;

    localeProvider.setLocale(
      currentLanguage == 'ar'
          ? const Locale('en')
          : const Locale('ar'),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider =
        context.watch<AuthProvider>();

    final isArabic =
        Localizations.localeOf(context)
                .languageCode ==
            'ar';

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isDesktop =
                constraints.maxWidth >=
                    900;

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildBrandPanel(
                      isArabic,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _buildFormArea(
                      authProvider,
                      isArabic,
                    ),
                  ),
                ],
              );
            }

            return _buildMobileLayout(
              authProvider,
              isArabic,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    AuthProvider authProvider,
    bool isArabic,
  ) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        32,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop();
                },
                icon: Icon(
                  isArabic
                      ? Icons
                          .arrow_forward_rounded
                      : Icons
                          .arrow_back_rounded,
                ),
              ),
              const Spacer(),
              _languageButton(
                isArabic,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _darkGreen,
              borderRadius:
                  BorderRadius.circular(
                28,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .agriculture_rounded,
                    color: _green,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.joinFarmPilot,
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n
                      .registerBrandDescription,
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(
                      alpha: 0.82,
                    ),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildRegisterCard(
            authProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPanel(
    bool isArabic,
  ) {
    return Container(
      color: _darkGreen,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 60,
        vertical: 44,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .agriculture_rounded,
                  color: _green,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                l10n.appName,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            l10n.joinFarmPilot,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 46,
              height: 1.05,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 520,
            ),
            child: Text(
              l10n
                  .registerBrandDescription,
              style: TextStyle(
                color: Colors.white
                    .withValues(
                  alpha: 0.82,
                ),
                fontSize: 17,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _featureRow(
            Icons.eco_outlined,
            l10n.smartCrops,
          ),
          const SizedBox(height: 14),
          _featureRow(
            Icons
                .psychology_alt_outlined,
            l10n.aiDiagnosis,
          ),
          const SizedBox(height: 14),
          _featureRow(
            Icons.storefront_outlined,
            l10n.marketplace,
          ),
          const Spacer(),
          _languageButton(
            isArabic,
            darkBackground: true,
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFormArea(
    AuthProvider authProvider,
    bool isArabic,
  ) {
    return Container(
      color: _background,
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 42,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 560,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      icon: Icon(
                        isArabic
                            ? Icons
                                .arrow_forward_rounded
                            : Icons
                                .arrow_back_rounded,
                      ),
                    ),
                    const Spacer(),
                    _languageButton(
                      isArabic,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                _buildRegisterCard(
                  authProvider,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(
    AuthProvider authProvider,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color: const Color(
            0xFFE5E9E5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.05,
            ),
            blurRadius: 28,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.createAccount,
              style: const TextStyle(
                color: Color(
                  0xFF17251D,
                ),
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createAccountSubtitle,
              style: const TextStyle(
                color: Color(
                  0xFF68746D,
                ),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            _field(
              controller:
                  _fullNameController,
              label: l10n.fullName,
              icon:
                  Icons.person_outline,
              validator:
                  _requiredValidator,
            ),

            const SizedBox(height: 16),

            _field(
              controller:
                  _emailController,
              label: l10n.email,
              icon:
                  Icons.email_outlined,
              keyboardType:
                  TextInputType
                      .emailAddress,
              validator:
                  _emailValidator,
            ),

            const SizedBox(height: 16),

            _field(
              controller:
                  _phoneController,
              label: l10n.phone,
              icon:
                  Icons.phone_outlined,
              keyboardType:
                  TextInputType.phone,
              validator:
                  _requiredValidator,
            ),

            const SizedBox(height: 16),

            _field(
              controller:
                  _addressController,
              label: l10n.address,
              icon:
                  Icons.location_on_outlined,
              validator:
                  _requiredValidator,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<
                String>(
              initialValue:
                  _selectedRole,
              decoration:
                  _inputDecoration(
                label:
                    l10n.accountType,
                icon:
                    Icons.badge_outlined,
              ),
              items: [
                DropdownMenuItem(
                  value: 'CUSTOMER',
                  child: Text(
                    l10n
                        .customerAccount,
                  ),
                ),
                DropdownMenuItem(
                  value: 'FARMER',
                  child: Text(
                    l10n.farmer,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _field(
              controller:
                  _passwordController,
              label: l10n.password,
              icon:
                  Icons.lock_outline,
              obscureText:
                  _obscurePassword,
              validator:
                  _passwordValidator,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _field(
              controller:
                  _confirmPasswordController,
              label:
                  l10n.confirmPassword,
              icon:
                  Icons.lock_reset_outlined,
              obscureText:
                  _obscureConfirmPassword,
              validator:
                  _confirmPasswordValidator,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : _register,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _green,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      _green.withValues(
                    alpha: 0.55,
                  ),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),
                ),
                child: authProvider
                        .isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : Text(
                        l10n
                            .createAccountButton,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    l10n
                        .alreadyHaveAccount,
                    style:
                        const TextStyle(
                      color: Color(
                        0xFF68746D,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  style:
                      TextButton.styleFrom(
                    foregroundColor:
                        _green,
                  ),
                  child: Text(
                    l10n.loginHere,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    required String? Function(String?)
        validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction:
          TextInputAction.next,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
          const Color(0xFFF8FAF8),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFDDE4DF),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFDDE4DF),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: _green,
          width: 1.6,
        ),
      ),
    );
  }

  Widget _languageButton(
    bool isArabic, {
    bool darkBackground = false,
  }) {
    return OutlinedButton.icon(
      onPressed: _changeLanguage,
      icon: const Icon(
        Icons.language_rounded,
        size: 19,
      ),
      label: Text(
        isArabic
            ? l10n.english
            : l10n.arabic,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            darkBackground
                ? Colors.white
                : _green,
        side: BorderSide(
          color: darkBackground
              ? Colors.white.withValues(
                  alpha: 0.35,
                )
              : _green.withValues(
                  alpha: 0.35,
                ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }
}