import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'account_form_screen.dart';
import '../../theme/app_colors.dart'; // Import to get the currentPalette getter
import '../../widgets/custom_app_bar.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _openForm(BuildContext context, WidgetRef ref, [Account? account]) {
    // Note: showDialog defaults to using the theme colors now set in MaterialApp
    showDialog(
      context: context,
      builder: (_) => AccountFormScreen(initialAccount: account),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the currently active color palette
    final palette = currentPalette;

    final accountsAsync = ref.watch(accountsListProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    // 2. The Scaffold color is already handled by the MaterialApp theme,
    // but setting it explicitly ensures it uses the correct dynamic color.
    return Scaffold(
      backgroundColor: palette.bgPrimary,
      appBar: CustomAppBar(
        title: 'Accounts',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark), // Use dynamic color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Total Balance: ${totalBalanceAsync.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: palette.textDark, // Use dynamic color
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 80,
                  ),
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return GestureDetector(
                      onTap: () => _openForm(context, ref, acc),
                      child: Card(
                        color: palette.bgTerciary, // Use dynamic color
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
                              // You might want a dynamic icon color here, or an icon reflecting the account type
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      style: TextStyle( // Use dynamic style
                                        fontWeight: FontWeight.bold,
                                        color: palette.textDark, // Use dynamic color
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Balance: ${acc.balance.toStringAsFixed(2)} €',
                                      style: TextStyle( // Use dynamic style
                                        color: palette.secondary, // Use dynamic accent color
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit, color: palette.textDark), // Use dynamic color
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
        backgroundColor: palette.primary, // Use dynamic color
        foregroundColor: palette.textDark, // Use dynamic color for icon
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}