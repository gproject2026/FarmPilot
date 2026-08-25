import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/customer_dashboard_screen.dart';
import '../farmer/farmer_dashboard_screen.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.pleaseEnterEmailPassword,
          ),
        ),
      );

      return;
    }

    try {
      await authProvider.login(
        email,
        password,
      );

      if (!mounted) {
        return;
      }

      if (authProvider.userRole ==
          'FARMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FarmerDashboardScreen(),
          ),
        );

        return;
      }

      if (authProvider.userRole ==
          'CUSTOMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CustomerDashboardScreen(),
          ),
        );

        return;
      }

      if (authProvider.userRole ==
          'ADMIN') {
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
          .showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.unsupportedRole}: '
            '${authProvider.userRole ?? l10n.unknown}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
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

  void _changeLanguage(
    String languageCode,
  ) {
    final localeProvider =
        Provider.of<LocaleProvider>(
      context,
      listen: false,
    );

    localeProvider.setLocale(
      Locale(languageCode),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
    );

    final localeProvider =
        Provider.of<LocaleProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        localeProvider
                .locale.languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isWide =
                constraints.maxWidth >=
                    900;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: _buildBrandPanel(
                      l10n,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: _buildLoginPanel(
                      context: context,
                      authProvider:
                          authProvider,
                      l10n: l10n,
                      isArabic:
                          isArabic,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildMobileBrandHeader(
                    l10n,
                  ),
                  _buildLoginPanel(
                    context: context,
                    authProvider:
                        authProvider,
                    l10n: l10n,
                    isArabic:
                        isArabic,
                    isMobile: true,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandPanel(
    AppLocalizations l10n,
  ) {
    return Container(
      height: double.infinity,
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF163D24),
            Color(0xFF295B35),
            Color(0xFF6D8F3E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
                shape:
                    BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -70,
            child: Container(
              width: 330,
              height: 330,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFCFE47A,
                ).withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(
              56,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildLogoBadge(
                  l10n,
                ),

                const Spacer(),

                Container(
                  width: 72,
                  height: 72,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons.agriculture,
                    color:
                        Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                Text(
                  l10n.loginBrandTitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 42,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing:
                        -1.2,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  l10n.loginBrandDescription,
                  style:
                      TextStyle(
                    color: Colors.white
                        .withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FeatureBadge(
                      icon:
                          Icons.eco_outlined,
                      label:
                          l10n.smartCrops,
                    ),
                    _FeatureBadge(
                      icon: Icons
                          .health_and_safety_outlined,
                      label:
                          l10n.aiDiagnosis,
                    ),
                    _FeatureBadge(
                      icon: Icons
                          .storefront_outlined,
                      label:
                          l10n.marketplace,
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  l10n.appName,
                  style:
                      TextStyle(
                    color: Colors.white
                        .withValues(
                      alpha: 0.62,
                    ),
                    fontSize: 13,
                    letterSpacing:
                        1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBrandHeader(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        36,
      ),
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF163D24),
            Color(0xFF295B35),
          ],
        ),
        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(32),
          bottomRight:
              Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildLogoBadge(
            l10n,
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            l10n.loginBrandTitle,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.05,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            l10n.mobileBrandDescription,
            style:
                TextStyle(
              color: Colors.white
                  .withValues(
                alpha: 0.78,
              ),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildLoginPanel({
  required BuildContext context,
  required AuthProvider authProvider,
  required AppLocalizations l10n,
  required bool isArabic,
  bool isMobile = false,
}) {
  return Container(
    color: const Color(0xFFF5F7F0),
    child: Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 56,
          vertical: isMobile ? 32 : 48,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.login,
                          style: const TextStyle(
                            color:
                                Color(0xFF183124),
                            fontSize: 34,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeToFarmPilot,
                          style: const TextStyle(
                            color:
                                Color(0xFF6D756E),
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildLanguageMenu(
                    isArabic: isArabic,
                    l10n: l10n,
                  ),
                ],
              ),

              const SizedBox(height: 34),

              _buildSectionLabel(
                l10n.email,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                autofillHints: const [
                  AutofillHints.email,
                ],
                decoration: InputDecoration(
                  hintText: l10n.email,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionLabel(
                l10n.password,
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    passwordController,
                obscureText:
                    obscurePassword,
                textInputAction:
                    TextInputAction.done,
                autofillHints: const [
                  AutofillHints.password,
                ],
                onSubmitted: (_) {
                  if (!authProvider
                      .isLoading) {
                    _login();
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.password,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword
                        ? l10n.showPassword
                        : l10n.hidePassword,
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment:
                    AlignmentDirectional
                        .centerEnd,
                child: TextButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : () {
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
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : _login,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2D663B,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: authProvider
                          .isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          l10n.login,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                ),
              ),

              // =========================
              // CREATE ACCOUNT
              // =========================
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      l10n.dontHaveAccount,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF6D756E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed:
                        authProvider.isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                    style:
                        TextButton.styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF2D663B,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 6,
                      ),
                    ),
                    child: Text(
                      l10n.registerNow,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE8EFE3,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color:
                          Color(0xFF537448),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n
                            .secureAccessMessage,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF5B665D),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLogoBadge(
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFD7EB86,
            ),
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color:
                Color(
              0xFF224B2C,
            ),
            size: 24,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Text(
          l10n.appName,
          style:
              const TextStyle(
            color:
                Colors.white,
            fontSize: 22,
            fontWeight:
                FontWeight.w800,
            letterSpacing:
                -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageMenu({
    required bool isArabic,
    required AppLocalizations l10n,
  }) {
    return PopupMenuButton<String>(
      tooltip:
          l10n.changeLanguage,
      onSelected:
          _changeLanguage,
      color:
          Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      itemBuilder:
          (context) {
        return [
          PopupMenuItem(
            value: 'en',
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 18,
                  color: !isArabic
                      ? const Color(
                          0xFF2D663B,
                        )
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
          PopupMenuItem(
            value: 'ar',
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 18,
                  color: isArabic
                      ? const Color(
                          0xFF2D663B,
                        )
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
        ];
      },
      child: Container(
        width: 46,
        height: 46,
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border:
              Border.all(
            color:
                const Color(
              0xFFDDE4D8,
            ),
          ),
        ),
        child: const Icon(
          Icons.language_rounded,
          color:
              Color(
            0xFF2D663B,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
    String text,
  ) {
    return Text(
      text,
      style:
          const TextStyle(
        color:
            Color(
          0xFF334238,
        ),
        fontSize: 14,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }
}

class _FeatureBadge
    extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({
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
        color: Colors.white
            .withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          30,
        ),
        border:
            Border.all(
          color: Colors.white
              .withValues(
            alpha: 0.12,
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
              0xFFD7EB86,
            ),
            size: 17,
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