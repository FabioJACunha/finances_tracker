import 'package:flutter/material.dart';

class AppColors {
//   // Beige
//   static const primary = Color.fromRGBO(243, 212, 155, 1.0);
//   static const secondary = Color.fromRGBO(173, 95, 38, 1.0);
//   static const terciary = Color.fromRGBO(227, 206, 187, 1.0);
//   static const textDark = Color.fromRGBO(101, 56, 47, 1.0);
//   static const textMuted = Color.fromRGBO(133, 130, 129, 1.0);
//   static const bgPrimary = Color.fromRGBO(241, 229, 204, 1.0);
//   static const bgTerciary = Color.fromRGBO(241, 233, 231, 1.0);
  static const bgGreen = Color.fromRGBO(214, 234, 215, 1.0);
  static const bgRed = Color.fromRGBO(246, 225, 229, 1.0);
  static const green = Color.fromRGBO(50, 121, 53, 1.0);
  static const red = Color.fromRGBO(248, 95, 81, 1.0);
}
class AppPalette {
  final String name;
  final Color bgPrimary;
  final Color bgTerciary;
  final Color primary;
  final Color terciary;
  final Color textDark;
  final Color secondary;
  final Color textMuted;
  final Color bgGreen;
  final Color bgRed;
  final Color green;
  final Color red;

  const AppPalette({
    required this.name,
    required this.bgPrimary,
    required this.bgTerciary,
    required this.primary,
    required this.terciary,
    required this.textDark,
    required this.secondary,
    required this.textMuted,
    required this.bgGreen,
    required this.bgRed,
    required this.green,
    required this.red
  });
}

// --- Defined Palettes ---

// Soft blue
const AppPalette softBlue = AppPalette(
  name: "Soft Blue",
  bgPrimary: Color.fromRGBO(249, 251, 253, 1.0),
  bgTerciary: Color.fromRGBO(238, 243, 247, 1.0),
  primary: Color.fromRGBO(194, 211, 230, 1.0),
  terciary: Color.fromRGBO(215, 227, 238, 1.0),
  textDark: Color.fromRGBO(44, 62, 90, 1.0),
  secondary: Color.fromRGBO(98, 116, 140, 1.0),
  textMuted: Color.fromRGBO(145, 155, 170, 1.0),
  bgGreen: Color.fromRGBO(214, 234, 215, 1.0),
  bgRed: Color.fromRGBO(246, 225, 229, 1.0),
  green: Color.fromRGBO(50, 121, 53, 1.0),
  red: Color.fromRGBO(248, 95, 81, 1.0),
);
// Purple
const AppPalette purple = AppPalette(
  name: "Gentle Purple",
  bgPrimary: Color.fromRGBO(248, 247, 250, 1.0),
  bgTerciary: Color.fromRGBO(238, 237, 243, 1.0),
  primary: Color.fromRGBO(198, 194, 216, 1.0),
  terciary: Color.fromRGBO(217, 214, 229, 1.0),
  textDark: Color.fromRGBO(59, 53, 84, 1.0),
  secondary: Color.fromRGBO(104, 99, 132, 1.0),
  textMuted: Color.fromRGBO(150, 146, 168, 1.0),
  bgGreen: Color.fromRGBO(214, 234, 215, 1.0),
  bgRed: Color.fromRGBO(246, 225, 229, 1.0),
  green: Color.fromRGBO(50, 121, 53, 1.0),
  red: Color.fromRGBO(248, 95, 81, 1.0),
);
// Brown
const AppPalette brownish = AppPalette(
  name: "Gentle Brown",
  bgPrimary: Color.fromRGBO(252, 249, 247, 1.0),
  bgTerciary: Color.fromRGBO(244, 239, 236, 1.0),
  primary: Color.fromRGBO(223, 203, 193, 1.0),
  terciary: Color.fromRGBO(234, 219, 211, 1.0),
  textDark: Color.fromRGBO(99, 79, 72, 1.0),
  secondary: Color.fromRGBO(142, 122, 115, 1.0),
  textMuted: Color.fromRGBO(172, 162, 157, 1.0),
  bgGreen: Color.fromRGBO(214, 234, 215, 1.0),
  bgRed: Color.fromRGBO(246, 225, 229, 1.0),
  green: Color.fromRGBO(50, 121, 53, 1.0),
  red: Color.fromRGBO(248, 95, 81, 1.0),
);

// Mushroom Ivory
const AppPalette mushroomIvory = AppPalette(
  name: "Mushroom Ivory",
  bgPrimary: Color.fromRGBO(251, 250, 248, 1.0),
  bgTerciary: Color.fromRGBO(237, 236, 234, 1.0),
  primary: Color.fromRGBO(214, 210, 207, 1.0),
  terciary: Color.fromRGBO(227, 224, 222, 1.0),
  textDark: Color.fromRGBO(80, 74, 72, 1.0),
  secondary: Color.fromRGBO(120, 115, 113, 1.0),
  textMuted: Color.fromRGBO(160, 156, 154, 1.0),
  bgGreen: Color.fromRGBO(214, 234, 215, 1.0),
  bgRed: Color.fromRGBO(246, 225, 229, 1.0),
  green: Color.fromRGBO(50, 121, 53, 1.0),
  red: Color.fromRGBO(248, 95, 81, 1.0),
);

// Gentle Peach
const AppPalette gentlePeach = AppPalette(
  name: "Gentle Peach",
  bgPrimary: Color.fromRGBO(255, 249, 246, 1.0),
  bgTerciary: Color.fromRGBO(250, 240, 236, 1.0),
  primary: Color.fromRGBO(240, 205, 190, 1.0),
  terciary: Color.fromRGBO(250, 220, 207, 1.0),
  textDark: Color.fromRGBO(114, 74, 64, 1.0),
  secondary: Color.fromRGBO(160, 112, 99, 1.0),
  textMuted: Color.fromRGBO(180, 155, 147, 1.0),
  bgGreen: Color.fromRGBO(214, 234, 215, 1.0),
  bgRed: Color.fromRGBO(246, 225, 229, 1.0),
  green: Color.fromRGBO(50, 121, 53, 1.0),
  red: Color.fromRGBO(248, 95, 81, 1.0),
);


// --- Global Theme State Management ---

/// A list of all available color palettes for the user to select from.
final List<AppPalette> availablePalettes = [
  softBlue,
  purple,
  brownish,
  mushroomIvory,
  gentlePeach,
];

/// The currently selected color palette.
/// We use ValueNotifier to rebuild widgets that depend on it (like AppBars/Scaffolds).
final ValueNotifier<AppPalette> currentPaletteNotifier = ValueNotifier(softBlue);

/// Getter for the current palette value, useful for simple access.
AppPalette get currentPalette => currentPaletteNotifier.value;

/// Setter function to change the application's color palette.
void setAppPalette(AppPalette newPalette) {
  if (currentPaletteNotifier.value != newPalette) {
    currentPaletteNotifier.value = newPalette;
  }
}
