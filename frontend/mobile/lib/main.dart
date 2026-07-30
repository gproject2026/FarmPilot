import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/user_provider.dart';

import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    const FarmPilotApp(),
  );
}

class FarmPilotApp extends StatelessWidget {
  const FarmPilotApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CropProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FarmPilot',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}