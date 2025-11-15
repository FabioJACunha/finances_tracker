import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../data/db/tables.dart';
import 'package:intl/intl.dart';
import 'transaction_form_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  int? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text("No accounts yet"));
          }

          _selectedAccountId ??= accounts.first.id;

          // Find the selected account
          final selectedAccount = accounts.firstWhere(
            (a) => a.id == _selectedAccountId,
          );

          return Column(
            children: [
              // Dropdown + total balance
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<int>(
                      value: _selectedAccountId,
                      items: accounts
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedAccountId = val),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Balance: €${selectedAccount.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions list
              Expanded(
                child: _selectedAccountId == null
                    ? const SizedBox.shrink()
                    : Consumer(
                        builder: (context, ref, _) {
                          final txnStream = ref.watch(
                            transactionsWithCategoryProvider(_selectedAccountId!),
                          );
                          return txnStream.when(
                            data: (transactions) {
                              if (transactions.isEmpty) {
                                return const Center(
                                  child: Text("No transactions"),
                                );
                              }
                              return ListView.separated(
                                itemCount: transactions.length,
                                separatorBuilder: (_, _) => const Divider(),
                                itemBuilder: (context, index) {
                                  final data = transactions[index];
                                  final tx = data.transaction;
                                  final categoryName = data.categoryName ?? 'Uncategorized';
                                  final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(tx.date);

                                  return ListTile(
                                    leading: Icon(
                                      tx.type == TransactionType.income
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                                    ),
                                    title: Text(tx.description ?? 'No description'),
                                    subtitle: Text('$categoryName • $formattedDate'),
                                    trailing: Text(
                                      '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                      style: TextStyle(
                                        color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, st) => Center(child: Text("Error: $e")),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading accounts: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final accountsAsync = ref.read(accountsListProvider);
          final accounts = accountsAsync.asData?.value;
          if (accounts == null || accounts.isEmpty) return;

          final firstAccountId = accounts.first.id;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TransactionFormScreen(initialAccountId: firstAccountId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
