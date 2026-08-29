import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

import 'l10n/generated/app_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/review_provider.dart';
import 'providers/supplier_cart_provider.dart';
import 'providers/supplier_category_provider.dart';
import 'providers/supplier_order_provider.dart';
import 'providers/supplier_product_provider.dart';
import 'providers/user_provider.dart';

import 'screens/auth/login_screen.dart';

import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const FarmPilotApp(),
  );

  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
      PushNotificationService.instance.initialize();
    },
  );
}

class FarmPilotApp extends StatefulWidget {
  const FarmPilotApp({
    super.key,
  });

  @override
  State<FarmPilotApp> createState() =>
      _FarmPilotAppState();
}

class _FarmPilotAppState
    extends State<FarmPilotApp> {
  final GlobalKey<ScaffoldMessengerState>
      _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<RemoteMessage>?
      _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();

    _foregroundMessageSubscription =
        PushNotificationService.instance.foregroundMessages.listen(
      _showForegroundNotification,
    );
  }

  Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    final notification =
        message.notification;

    final title =
        notification?.title ??
            'FarmPilot Reminder';

    final body =
        notification?.body ??
            'You have a new reminder.';

    final messenger =
        _scaffoldMessengerKey.currentState;

    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 6,
          ),
          behavior:
              SnackBarBehavior.floating,
          content: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 2,
                ),
                child: Icon(
                  Icons
                      .notifications_active_outlined,
                  color:
                      Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        body,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );

    try {
      await Provider.of<
          NotificationProvider>(
        messenger.context,
        listen: false,
      ).loadNotifications();
    } catch (_) {}
  }

  @override
  void dispose() {
    _foregroundMessageSubscription
        ?.cancel();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SupplierCategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SupplierProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SupplierOrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CropProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DiagnosisProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ReminderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SupplierCartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ReviewProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocaleProvider(),
        ),
      ],
      child:
          Consumer<LocaleProvider>(
        builder: (
          context,
          localeProvider,
          child,
        ) {
          return MaterialApp(
            scaffoldMessengerKey:
                _scaffoldMessengerKey,
            debugShowCheckedModeBanner:
                false,
            title:
                'FarmPilot',
            locale:
                localeProvider.locale,
            supportedLocales:
                AppLocalizations
                    .supportedLocales,
            localizationsDelegates:
                const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations
                  .delegate,
              GlobalWidgetsLocalizations
                  .delegate,
              GlobalCupertinoLocalizations
                  .delegate,
            ],
            theme:
                AppTheme.lightTheme,
            scrollBehavior:
                const FarmPilotScrollBehavior(),
            builder: (
              context,
              child,
            ) {
              return FarmPilotKeyboardScroll(
                child:
                    child!,
              );
            },
            home:
                const LoginScreen(),
          );
        },
      ),
    );
  }
}

class FarmPilotKeyboardScroll
    extends StatefulWidget {
  final Widget child;

  const FarmPilotKeyboardScroll({
    super.key,
    required this.child,
  });

  @override
  State<FarmPilotKeyboardScroll>
      createState() =>
          _FarmPilotKeyboardScrollState();
}

class _FarmPilotKeyboardScrollState
    extends State<
        FarmPilotKeyboardScroll> {
  final FocusNode _focusNode =
      FocusNode();

  static const double
      _arrowDistance =
      80;

  static const double
      _pageDistance =
      500;

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  bool _isTyping() {
    final primaryFocus =
        FocusManager
            .instance.primaryFocus;

    final focusContext =
        primaryFocus?.context;

    if (focusContext ==
        null) {
      return false;
    }

    if (focusContext
            .findAncestorWidgetOfExactType<
                EditableText>() !=
        null) {
      return true;
    }

    return focusContext.widget
        is EditableText;
  }

  ScrollController?
      _getController() {
    final controller =
        PrimaryScrollController
            .maybeOf(
      context,
    );

    if (controller ==
        null) {
      return null;
    }

    if (!controller
        .hasClients) {
      return null;
    }

    return controller;
  }

  Future<void> _scrollBy(
    double amount,
  ) async {
    final controller =
        _getController();

    if (controller ==
        null) {
      return;
    }

    final position =
        controller.position;

    if (!position
        .hasContentDimensions) {
      return;
    }

    final target =
        (position.pixels +
                amount)
            .clamp(
              position
                  .minScrollExtent,
              position
                  .maxScrollExtent,
            )
            .toDouble();

    if ((target -
                position.pixels)
            .abs() <
        1) {
      return;
    }

    await controller.animateTo(
      target,
      duration:
          const Duration(
        milliseconds:
            140,
      ),
      curve:
          Curves.easeOut,
    );
  }

  Future<void>
      _scrollToStart() async {
    final controller =
        _getController();

    if (controller ==
        null) {
      return;
    }

    if (!controller.position
        .hasContentDimensions) {
      return;
    }

    await controller.animateTo(
      controller
          .position.minScrollExtent,
      duration:
          const Duration(
        milliseconds:
            220,
      ),
      curve:
          Curves.easeOut,
    );
  }

  Future<void>
      _scrollToEnd() async {
    final controller =
        _getController();

    if (controller ==
        null) {
      return;
    }

    if (!controller.position
        .hasContentDimensions) {
      return;
    }

    await controller.animateTo(
      controller
          .position.maxScrollExtent,
      duration:
          const Duration(
        milliseconds:
            220,
      ),
      curve:
          Curves.easeOut,
    );
  }

  KeyEventResult _handleKey(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event
            is! KeyDownEvent &&
        event
            is! KeyRepeatEvent) {
      return KeyEventResult
          .ignored;
    }

    if (_isTyping()) {
      return KeyEventResult
          .ignored;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .arrowDown) {
      _scrollBy(
        _arrowDistance,
      );

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .arrowUp) {
      _scrollBy(
        -_arrowDistance,
      );

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .pageDown) {
      _scrollBy(
        _pageDistance,
      );

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .pageUp) {
      _scrollBy(
        -_pageDistance,
      );

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .home) {
      _scrollToStart();

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .end) {
      _scrollToEnd();

      return KeyEventResult
          .handled;
    }

    return KeyEventResult
        .ignored;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Focus(
      focusNode:
          _focusNode,
      autofocus:
          true,
      onKeyEvent:
          _handleKey,
      child:
          widget.child,
    );
  }
}

class FarmPilotScrollBehavior
    extends MaterialScrollBehavior {
  const FarmPilotScrollBehavior();

  @override
  Set<PointerDeviceKind>
      get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}