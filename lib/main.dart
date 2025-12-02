import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'theme/app_colors.dart';
import 'locale/app_locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeTheme();
  await initializeLocale();

  runApp(const ProviderScope(child: MyApp()));
}
