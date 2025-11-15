import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'account_form_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _openForm(BuildContext context, WidgetRef ref, [Account? account]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountFormScreen(initialAccount: account),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        data: (accounts) {
          final totalBalance = accounts
              .where((a) => !a.excludeFromTotal)
              .fold<double>(0.0, (sum, a) => sum + a.balance);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Balance: €${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return ListTile(
                      title: Text(acc.name),
                      subtitle: Text('Balance: €${acc.balance.toStringAsFixed(2)}'),
                      trailing: Icon(Icons.edit),
                      onTap: () => _openForm(context, ref, acc),
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
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
