import 'package:flutter/material.dart';

class AppTheme {
  // Кобальтовый цвет
  static const cobalt = Color(0xFF0047AB);
  static const cobaltLight = Color(0xFF4DA6FF);
  static const cobaltDark = Color(0xFF003080);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: cobalt,
          brightness: Brightness.light,
        ).copyWith(
          primary: cobalt,
          secondary: cobaltLight,
          tertiary: cobaltDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A6BB5),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: cobalt,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SF Pro Text',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: cobalt,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: cobalt.withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: cobalt);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'SF Pro Text',
                color: cobalt,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              fontFamily: 'SF Pro Text',
              color: Colors.grey,
              fontSize: 12,
            );
          }),
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cobalt, width: 2),
          ),
          filled: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'SF Pro Display'),
          displayMedium: TextStyle(fontFamily: 'SF Pro Display'),
          displaySmall: TextStyle(fontFamily: 'SF Pro Display'),
          headlineLarge: TextStyle(fontFamily: 'SF Pro Display'),
          headlineMedium: TextStyle(fontFamily: 'SF Pro Display'),
          headlineSmall: TextStyle(fontFamily: 'SF Pro Display'),
          titleLarge: TextStyle(
              fontFamily: 'SF Pro Display', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              fontFamily: 'SF Pro Text', fontWeight: FontWeight.w600),
          titleSmall: TextStyle(
              fontFamily: 'SF Pro Text', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'SF Pro Text'),
          bodyMedium: TextStyle(fontFamily: 'SF Pro Text'),
          bodySmall: TextStyle(fontFamily: 'SF Pro Text'),
          labelLarge: TextStyle(
              fontFamily: 'SF Pro Text', fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontFamily: 'SF Pro Text'),
          labelSmall: TextStyle(fontFamily: 'SF Pro Text'),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: cobalt,
          brightness: Brightness.dark,
        ).copyWith(
          primary: cobaltLight,
          secondary: cobalt,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0F),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: cobalt,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: cobalt,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1C1C1E),
          indicatorColor: cobalt.withOpacity(0.3),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: cobaltLight);
            }
            return const IconThemeData(color: Colors.white38);
          }),
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
        ),
      );
}