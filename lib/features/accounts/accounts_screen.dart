import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'account_form_screen.dart';
import '../../helpers/app_colors.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _openForm(BuildContext context, WidgetRef ref, [Account? account]) {
    showDialog(
      context: context,
      builder: (_) => AccountFormScreen(initialAccount: account),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        title: const Text("Accounts"),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final totalBalance = accounts
              .where((a) => !a.excludeFromTotal)
              .fold<double>(0.0, (sum, a) => sum + a.balance);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Balance: €${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return GestureDetector(
                      onTap: () => _openForm(context, ref, acc),
                      child: Card(
                        color: AppColors.lightGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Balance: €${acc.balance.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit, color: AppColors.darkGreen),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lightGreen,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
