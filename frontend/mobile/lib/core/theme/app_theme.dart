import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // FarmPilot brand colors
  static const Color primaryGreen =
      Color(0xFF2E7D32);

  static const Color darkGreen =
      Color(0xFF1B5E20);

  static const Color lightGreen =
      Color(0xFFE8F5E9);

  static const Color accentGreen =
      Color(0xFF66BB6A);

  static const Color background =
      Color(0xFFF7F9F6);

  static const Color surface =
      Colors.white;

  static const Color textPrimary =
      Color(0xFF1C1C1C);

  static const Color textSecondary =
      Color(0xFF6B756B);

  static const Color border =
      Color(0xFFE1E7DF);

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          background,

      primaryColor: primaryGreen,

      // =========================
      // APP BAR
      // =========================
      appBarTheme:
          const AppBarTheme(
        backgroundColor: surface,
        foregroundColor:
            textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle:
            TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight:
              FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
        ),
      ),

      // =========================
      // CARDS
      // =========================
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin:
            EdgeInsets.zero,
        surfaceTintColor:
            Colors.transparent,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          side: const BorderSide(
            color: border,
          ),
        ),
      ),

      // =========================
      // ELEVATED BUTTON
      // =========================
      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              primaryGreen,
          foregroundColor:
              Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      // =========================
      // OUTLINED BUTTON
      // =========================
      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              primaryGreen,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          side: const BorderSide(
            color: primaryGreen,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      // =========================
      // TEXT BUTTON
      // =========================
      textButtonTheme:
          TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              primaryGreen,
          textStyle:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      // =========================
      // INPUTS
      // =========================
      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle:
            const TextStyle(
          color: textSecondary,
        ),
        labelStyle:
            const TextStyle(
          color: textSecondary,
        ),
        prefixIconColor:
            primaryGreen,
        suffixIconColor:
            textSecondary,

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),

      // =========================
      // FLOATING ACTION BUTTON
      // =========================
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor:
            primaryGreen,
        foregroundColor:
            Colors.white,
        elevation: 2,
      ),

      // =========================
      // CHIPS
      // =========================
      chipTheme: ChipThemeData(
        backgroundColor:
            lightGreen,
        selectedColor:
            primaryGreen,
        disabledColor:
            Colors.grey.shade200,
        labelStyle:
            const TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w500,
        ),
        secondaryLabelStyle:
            const TextStyle(
          color: Colors.white,
        ),
        side:
            const BorderSide(
          color: border,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
      ),

      // =========================
      // DIVIDER
      // =========================
      dividerTheme:
          const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // =========================
      // SNACK BAR
      // =========================
      snackBarTheme:
          SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            const Color(
          0xFF263328,
        ),
        contentTextStyle:
            const TextStyle(
          color: Colors.white,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      // =========================
      // DIALOG
      // =========================
      dialogTheme:
          DialogThemeData(
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.transparent,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
      ),

      // =========================
      // TEXT
      // =========================
      textTheme:
          const TextTheme(
        headlineLarge:
            TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w700,
        ),
        headlineMedium:
            TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w700,
        ),
        headlineSmall:
            TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w700,
        ),
        titleLarge:
            TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w700,
        ),
        titleMedium:
            TextStyle(
          color: textPrimary,
          fontWeight:
              FontWeight.w600,
        ),
        bodyLarge:
            TextStyle(
          color: textPrimary,
        ),
        bodyMedium:
            TextStyle(
          color: textPrimary,
        ),
        bodySmall:
            TextStyle(
          color: textSecondary,
        ),
      ),
    );
  }
}