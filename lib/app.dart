import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/accounts/accounts_screen.dart';
import 'features/transactions/transaction_history_screen.dart';

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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: Builder(
        // Builder gives a context that is under the Navigator
        builder: (context) => Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "Transactions",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: "Accounts",
              ),
            ],
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
