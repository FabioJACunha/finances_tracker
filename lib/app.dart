import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/accounts/accounts_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'helpers/app_colors.dart';
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
      title: "Budget App (€)",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first; // Fallback to 'en'
        }
        // 1. Check for an exact match (e.g., pt_BR, en_US)
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale == locale) {
            return supportedLocale;
          }
        }
        // 2. Check for a language code match (e.g., device is 'pt_AO', use generic 'pt')
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            // If the language code matches, use the most specific supported locale for that language
            // e.g., if device is 'pt_AO', and we support 'pt_BR' and 'pt', use 'pt' (if supported) or 'pt_BR'

            // We will simply return the language-only locale if supported (Locale('pt'))
            if (supportedLocale.countryCode == null) {
              return supportedLocale;
            }
          }
        }
        // 3. Final Fallback: Use English
        return supportedLocales.first;
      },
      theme: ThemeData(
        useMaterial3: true,
        // colorSchemeSeed: Color.fromRGBO(68, 38, 32, 1.0),
        scaffoldBackgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(
          color: AppColors.textDark, // default color for most icons
        ),
        // Cursor, selection, and highlight color
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.textDark,
          selectionColor: AppColors.bgPrimary,
          selectionHandleColor: AppColors.textDark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: AppColors.secondary),
          floatingLabelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppColors.bgSecondary, // background color
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          insetPadding: EdgeInsets.all(16),
          // margin: const EdgeInsets.only(
          //   bottom: 16,
          //   left: 16,
          //   right: 16,
          // ),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        )
      ),
      home: Builder(
        // Builder gives a context that is under the Navigator
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;

          return Scaffold(
            body: screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: AppColors.bgPrimary,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.textDark,
              currentIndex: _currentIndex,
              // These now correctly use the localizations variable defined above
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home), label: localizations.navHome),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history),
                  label: localizations.navTransactions,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_balance),
                  label: localizations.navAccounts,
                ),
              ],
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }
}
