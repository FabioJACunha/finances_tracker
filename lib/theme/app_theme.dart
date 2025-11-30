import 'package:flutter/material.dart';
import 'app_colors.dart'; // Ensure this contains the AppPalette class

class AppTheme {
  // Removed the 'final palette = currentPalette;' instance field.

  // This static method now accepts the dynamically selected palette,
  // ensuring the theme is built with the current colors every time it's called.
  static ThemeData getTheme(AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      // Use the palette passed into the method
      scaffoldBackgroundColor: palette.bgPrimary,
      iconTheme: IconThemeData(color: palette.textDark),
      // Removed const
      textSelectionTheme: TextSelectionThemeData(
        // Removed const
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
        titleTextStyle: TextStyle(color: palette.textDark, fontSize: 22, fontWeight: FontWeight.w500),
        contentTextStyle: TextStyle(color: palette.textDark),
      ),
    );
  }
}
