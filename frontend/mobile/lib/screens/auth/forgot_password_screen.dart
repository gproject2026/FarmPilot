import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _requestResetToken() async {
    final email =
        emailController.text.trim();

    if (email.isEmpty ||
        !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email',
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
      final response =
          await authProvider.forgotPassword(
        email: email,
      );

      if (!mounted) {
        return;
      }

      final resetToken =
          response['resetToken']?.toString();

      final message =
          response['message']?.toString() ??
              'Password reset request completed';

      if (resetToken == null ||
          resetToken.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );

        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResetPasswordScreen(
            email: email,
            resetToken: resetToken,
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 82,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'Reset your password',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Enter the email linked to your FarmPilot account.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          Colors.grey.shade700,
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
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!authProvider
                          .isLoading) {
                        _requestResetToken();
                      }
                    },
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
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
                        ElevatedButton.icon(
                      onPressed:
                          authProvider.isLoading
                              ? null
                              : _requestResetToken,
                      icon:
                          authProvider.isLoading
                              ? const SizedBox
                                  .shrink()
                              : const Icon(
                                  Icons
                                      .send_outlined,
                                ),
                      label:
                          authProvider.isLoading
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
                                  'Continue',
                                ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    label: const Text(
                      'Back to Login',
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.amber.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      border: Border.all(
                        color:
                            Colors.amber.shade200,
                      ),
                    ),
                    child: const Text(
                      'For the project demo, the reset token is generated by the backend and passed directly to the next screen. Later it can be sent by email.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
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