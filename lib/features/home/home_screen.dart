import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../transactions/transaction_form_screen.dart';
import 'home_stats_widgets/home_stats_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _selectedAccountId;
  String _selectedPeriod = 'Month';

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);

    DateTime start, end;
    end = DateTime.now();
    if (_selectedPeriod == 'Week') {
      start = end.subtract(const Duration(days: 7));
    }
    else if (_selectedPeriod == 'Month') {
      start = DateTime(end.year, end.month, 1);
    }
    else {
      start = DateTime(end.year, 1, 1);
    }

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) return const Center(child: Text("No accounts yet"));
        _selectedAccountId ??= accounts.first.id;

        return Scaffold(
          appBar: AppBar(title: const Text("Home")),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedAccountId,
                        items: accounts
                            .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedAccountId = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      items: ['Week','Month','Year'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _selectedPeriod = val!),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpensesByCategoryPie(accountId: _selectedAccountId!, start: start, end: end),
                      IncomeVsExpenseBar(accountId: _selectedAccountId!, start: start, end: end),
                      NetBalanceChangeCard(accountId: _selectedAccountId!, start: start, end: end),
                      SavingsRateCard(accountId: _selectedAccountId!, start: start, end: end),
                      TopExpenseCategories(accountId: _selectedAccountId!, start: start, end: end),
                      SpendingTrendChart(accountId: _selectedAccountId!, start: start, end: end),
                      BalanceEvolutionChart(accountId: _selectedAccountId!, start: start, end: end),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TransactionFormScreen(initialAccountId: _selectedAccountId!),
              ));
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e")),
    );
  }
}
