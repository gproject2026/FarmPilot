import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../customer/customer_dashboard_screen.dart';
import '../farmer/farmer_dashboard_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

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

    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password',
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
            builder: (_) => const FarmerDashboardScreen(),
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unsupported role: ${authProvider.userRole ?? 'Unknown'}',
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
          'FarmPilot Login',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Welcome to FarmPilot',
                  style: TextStyle(
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
                      TextInputAction.next,
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
                  height: 20,
                ),
                TextField(
                  controller:
                      passwordController,
                  obscureText: true,
                  textInputAction:
                      TextInputAction.done,
                  onSubmitted: (_) {
                    if (!authProvider
                        .isLoading) {
                      _login();
                    }
                  },
                  decoration:
                      const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      ElevatedButton(
                    onPressed:
                        authProvider.isLoading
                            ? null
                            : _login,
                    child:
                        authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}