import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/consts/app_colors.dart';

class Styles {
  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    return ThemeData(
      scaffoldBackgroundColor:
          isDarkTheme
              ? AppColors.darkScaffoldColor
              : AppColors.lightScaffoldColor,
      cardColor:
          isDarkTheme
              ? const Color.fromARGB(255, 13, 6, 37)
              : AppColors.lightCardColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      fontFamily: 'Roboto',

      // Set different primary colors for light and dark themes
      primarySwatch: Colors.purple,
      primaryColor:
          isDarkTheme
              ? const Color(0xFF9C88FF) // Light purple for dark theme
              : AppColors.lightPrimary, // Dark purple for light theme
      // Disable default shadows
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color:
                isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        backgroundColor:
            isDarkTheme
                ? AppColors.darkScaffoldColor
                : AppColors.lightScaffoldColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.all(10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
