import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.bgPrimary,
      iconTheme: IconThemeData(color: palette.textDark),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.textDark,
        selectionColor: palette.bgPrimary,
        selectionHandleColor: palette.textDark,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: palette.bgPrimary,
        titleTextStyle: TextStyle(
          color: palette.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(color: palette.textDark),
      ),
    );
  }
}
