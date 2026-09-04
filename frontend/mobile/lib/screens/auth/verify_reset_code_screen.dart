import 'package:flutter/material.dart';

import 'reset_password_screen.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyResetCodeScreen> createState() =>
      _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState
    extends State<VerifyResetCodeScreen> {
  final codeController =
      TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _continue() {
    final code =
        codeController.text.trim();

    if (code.length != 6 ||
        int.tryParse(code) == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the 6-digit code',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResetPasswordScreen(
          email: widget.email,
          resetToken: code,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Code',
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
                    Icons.mark_email_read_outlined,
                    size: 82,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'Check your email',
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
                    'We sent a 6-digit password reset code to ${widget.email}.',
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
                        codeController,
                    keyboardType:
                        TextInputType.number,
                    textInputAction:
                        TextInputAction.done,
                    maxLength: 6,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight:
                          FontWeight.bold,
                    ),
                    onSubmitted: (_) =>
                        _continue(),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Verification Code',
                      hintText: '000000',
                      counterText: '',
                      prefixIcon: Icon(
                        Icons.pin_outlined,
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
                      onPressed: _continue,
                      icon: const Icon(
                        Icons
                            .arrow_forward,
                      ),
                      label: const Text(
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
                      'Back',
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