import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/customer_dashboard_screen.dart';
import '../farmer/farmer_dashboard_screen.dart';
import 'forgot_password_screen.dart';

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
            l10n
                .pleaseEnterEmailPassword,
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
      appBar: AppBar(
        title: Text(
          '${l10n.appName} - ${l10n.login}',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip:
                l10n.changeLanguage,
            icon: const Icon(
              Icons.language,
            ),
            onSelected:
                _changeLanguage,
            itemBuilder:
                (context) {
              return [
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: !isArabic
                            ? Colors.green
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
                        color: isArabic
                            ? Colors.green
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
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Icon(
                    Icons.eco,
                    size: 80,
                    color:
                        Colors.green,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    l10n
                        .welcomeToFarmPilot,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller:
                        emailController,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    textInputAction:
                        TextInputAction
                            .next,
                    autofillHints:
                        const [
                      AutofillHints.email,
                    ],
                    decoration:
                        InputDecoration(
                      labelText:
                          l10n.email,
                      prefixIcon:
                          const Icon(
                        Icons
                            .email_outlined,
                      ),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller:
                        passwordController,
                    obscureText:
                        obscurePassword,
                    textInputAction:
                        TextInputAction
                            .done,
                    autofillHints:
                        const [
                      AutofillHints
                          .password,
                    ],
                    onSubmitted:
                        (_) {
                      if (!authProvider
                          .isLoading) {
                        _login();
                      }
                    },
                    decoration:
                        InputDecoration(
                      labelText:
                          l10n.password,
                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        tooltip:
                            obscurePassword
                                ? l10n
                                    .showPassword
                                : l10n
                                    .hidePassword,
                        onPressed:
                            () {
                          setState(
                            () {
                              obscurePassword =
                                  !obscurePassword;
                            },
                          );
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                  Align(
                    alignment:
                        AlignmentDirectional
                            .centerEnd,
                    child:
                        TextButton(
                      onPressed:
                          authProvider
                                  .isLoading
                              ? null
                              : () {
                                  Navigator
                                      .push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                      child: Text(
                        l10n
                            .forgotPassword,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed:
                          authProvider
                                  .isLoading
                              ? null
                              : _login,
                      child:
                          authProvider
                                  .isLoading
                              ? const SizedBox(
                                  width:
                                      24,
                                  height:
                                      24,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : Text(
                                  l10n.login,
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}