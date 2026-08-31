import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/customer_dashboard_screen.dart';
import '../farmer/farmer_dashboard_screen.dart';
import '../supplier/supplier_dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  final FocusNode _passwordFocusNode =
      FocusNode();

  bool _obscurePassword = true;

  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _primaryGreen =
      Color(0xFF2F6B3D);

  static const Color _background =
      Color(0xFFF8FAF4);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final l10n =
        AppLocalizations.of(context)!;

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n
                  .pleaseEnterEmailPassword,
            ),
          ),
        );

      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      await authProvider.login(
        email,
        password,
      );

      if (!mounted) {
        return;
      }

      final role =
          authProvider.userRole
              ?.toUpperCase();

      if (role == 'FARMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FarmerDashboardScreen(),
          ),
        );

        return;
      }

      if (role == 'CUSTOMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CustomerDashboardScreen(),
          ),
        );

        return;
      }

      if (role == 'SUPPLIER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SupplierDashboardScreen(),
          ),
        );

        return;
      }

      if (role == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AdminDashboardScreen(),
          ),
        );

        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.unsupportedRole,
            ),
          ),
        );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          authProvider.errorMessage ??
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
            ),
          ),
        );
    }
  }

  void _changeLanguage(
    String languageCode,
  ) {
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(
      Locale(languageCode),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final localeProvider =
        Provider.of<LocaleProvider>(
      context,
    );

    final isArabic =
        localeProvider
                .locale.languageCode ==
            'ar';

    final authProvider =
        Provider.of<AuthProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          _background,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _LoginBackdrop(),
          ),
          SafeArea(
            child: Center(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .all(
                  20,
                ),
                child:
                    ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child:
                      LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final isWide =
                          constraints
                                  .maxWidth >=
                              850;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 620,
                                child: _buildBrandPanel(
                                  l10n,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 620,
                                child: _buildLoginCard(
                                  l10n: l10n,
                                  isArabic: isArabic,
                                  authProvider:
                                      authProvider,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildMobileBrand(
                            l10n,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _buildLoginCard(
                            l10n: l10n,
                            isArabic:
                                isArabic,
                            authProvider:
                                authProvider,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPanel(
    AppLocalizations l10n,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 620,
      ),
      padding:
          const EdgeInsets.all(
        44,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          32,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withValues(
              alpha: 0.18,
            ),
            blurRadius: 30,
            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFDDECB8,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    17,
                  ),
                ),
                child:
                    const Icon(
                  Icons.eco_rounded,
                  color:
                      _darkGreen,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Text(
                l10n.appName,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 110,
          ),
          Text(
            l10n.loginBrandTitle,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 48,
              height: 1.05,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            l10n
                .loginBrandDescription,
            style:
                TextStyle(
              color:
                  Colors.white
                      .withValues(
                alpha: 0.82,
              ),
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(
            height: 34,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BrandChip(
                icon:
                    Icons.eco_outlined,
                label:
                    l10n.smartCrops,
              ),
              _BrandChip(
                icon:
                    Icons
                        .health_and_safety_outlined,
                label:
                    l10n.aiDiagnosis,
              ),
              _BrandChip(
                icon:
                    Icons.storefront_outlined,
                label:
                    l10n.marketplace,
              ),
            ],
          ),
          const SizedBox(
            height: 80,
          ),
          Row(
            children: [
              const Icon(
                Icons
                    .verified_user_outlined,
                color:
                    Color(
                  0xFFDDECB8,
                ),
                size: 21,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  l10n
                      .secureAccessMessage,
                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBrand(
    AppLocalizations l10n,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF173F24),
            Color(0xFF2F6B3D),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFDDECB8,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child:
                const Icon(
              Icons.eco_rounded,
              color:
                  _darkGreen,
              size: 32,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            l10n.appName,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 25,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            l10n
                .mobileBrandDescription,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white
                      .withValues(
                alpha: 0.78,
              ),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard({
    required AppLocalizations l10n,
    required bool isArabic,
    required AuthProvider
        authProvider,
  }) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 620,
      ),
      padding:
          const EdgeInsets.all(
        34,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          32,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDDE6D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withValues(
              alpha: 0.07,
            ),
            blurRadius: 30,
            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      l10n.login,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF1D2C21,
                        ),
                        fontSize: 32,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      l10n
                          .welcomeToFarmPilot,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF68756B,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip:
                    l10n.changeLanguage,
                position:
                    PopupMenuPosition
                        .under,
                onSelected:
                    _changeLanguage,
                itemBuilder:
                    (context) => [
                  PopupMenuItem<
                      String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          color: !isArabic
                              ? _primaryGreen
                              : Colors
                                  .transparent,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          l10n.english,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<
                      String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          color: isArabic
                              ? _primaryGreen
                              : Colors
                                  .transparent,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          l10n.arabic,
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 46,
                  height: 46,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF1F5ED,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons.language_rounded,
                    color:
                        _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 34,
          ),
          _buildTextField(
            controller:
                _emailController,
            label:
                l10n.email,
            icon:
                Icons.email_outlined,
            keyboardType:
                TextInputType
                    .emailAddress,
            textInputAction:
                TextInputAction.next,
            onSubmitted: (_) {
              _passwordFocusNode
                  .requestFocus();
            },
          ),
          const SizedBox(
            height: 18,
          ),
          _buildTextField(
            controller:
                _passwordController,
            focusNode:
                _passwordFocusNode,
            label:
                l10n.password,
            icon:
                Icons.lock_outline_rounded,
            obscureText:
                _obscurePassword,
            textInputAction:
                TextInputAction.done,
            suffixIcon:
                IconButton(
              tooltip:
                  _obscurePassword
                      ? l10n
                          .showPassword
                      : l10n
                          .hidePassword,
              onPressed: () {
                setState(
                  () {
                    _obscurePassword =
                        !_obscurePassword;
                  },
                );
              },
              icon: Icon(
                _obscurePassword
                    ? Icons
                        .visibility_outlined
                    : Icons
                        .visibility_off_outlined,
              ),
            ),
            onSubmitted: (_) {
              if (!authProvider
                  .isLoading) {
                _login();
              }
            },
          ),
          const SizedBox(
            height: 12,
          ),
          Align(
            alignment:
                AlignmentDirectional
                    .centerEnd,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                l10n.forgotPassword,
                style:
                    const TextStyle(
                  color:
                      _primaryGreen,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width:
                double.infinity,
            height: 54,
            child:
                ElevatedButton(
              onPressed:
                  authProvider.isLoading
                      ? null
                      : _login,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _primaryGreen,
                foregroundColor:
                    Colors.white,
                disabledBackgroundColor:
                    _primaryGreen
                        .withValues(
                  alpha: 0.55,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
              ),
              child:
                  authProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.4,
                            color:
                                Colors
                                    .white,
                          ),
                        )
                      : Text(
                          l10n.login,
                          style:
                              const TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: Color(0xFF68756B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.registerNow,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: _primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>?
        onSubmitted,
  }) {
    return TextField(
      controller:
          controller,
      focusNode:
          focusNode,
      keyboardType:
          keyboardType,
      textInputAction:
          textInputAction,
      obscureText:
          obscureText,
      onSubmitted:
          onSubmitted,
      decoration:
          InputDecoration(
        labelText:
            label,
        prefixIcon:
            Icon(
          icon,
          color:
              _primaryGreen,
        ),
        suffixIcon:
            suffixIcon,
        filled: true,
        fillColor:
            const Color(
          0xFFF7F9F4,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(
              0xFFDDE6D8,
            ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              const BorderSide(
            color:
                _primaryGreen,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _BrandChip
    extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BrandChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          30,
        ),
        border:
            Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.13,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xFFDDECB8,
            ),
            size: 18,
          ),
          const SizedBox(
            width: 7,
          ),
          Text(
            label,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackdrop
    extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Stack(
        fit:
            StackFit.expand,
        children: [
          const DecoratedBox(
            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                begin:
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF4F8ED,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -170,
            top: -120,
            child: Container(
              width: 440,
              height: 440,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha: 0.35,
                    ),
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -180,
            child: Container(
              width: 500,
              height: 500,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha: 0.25,
                    ),
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha: 0.0,
                    ),
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