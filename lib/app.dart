import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/budgets/budgets_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'theme/app_colors.dart'; // Import AppPalette and currentPaletteNotifier
import 'theme/app_theme.dart'; // Import AppTheme
import 'l10n/app_localizations.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const TransactionHistoryScreen(),
      const BudgetsScreen(),
    ];

    // 1. Wrap the MaterialApp with ValueListenableBuilder.
    return ValueListenableBuilder<AppPalette>(
      valueListenable: currentPaletteNotifier,
      builder: (context, palette, child) {

        // 2. Use the new static method AppTheme.getTheme(palette)
        // which returns the fully customized ThemeData based on the current palette.
        final dynamicTheme = AppTheme.getTheme(palette);

        return MaterialApp(
          // Apply the dynamic theme data
          theme: dynamicTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;

              return Scaffold(
                body: screens[_currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  // Use the dynamic palette colors directly for the BottomNavigationBar
                  backgroundColor: palette.bgPrimary,
                  selectedItemColor: palette.secondary, // Highlight color
                  unselectedItemColor: palette.textMuted, // Muted color for unselected items
                  currentIndex: _currentIndex,
                  items: [
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.home_outlined),
                        label: localizations.navHome),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.history),
                        label: localizations.navTransactions),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.pie_chart_outline),
                        label: "Budgets"),
                  ],
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              );
            },
          ),
        );
      },
    );
  }
}