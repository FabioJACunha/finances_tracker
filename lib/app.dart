import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/accounts/accounts_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
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
      const AccountsScreen(),
    ];

    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;

          return Scaffold(
            body: screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: AppColors.bgPrimary,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.textDark,
              currentIndex: _currentIndex,
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    label: localizations.navHome),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.history),
                    label: localizations.navTransactions),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: localizations.navAccounts),
              ],
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }
}
