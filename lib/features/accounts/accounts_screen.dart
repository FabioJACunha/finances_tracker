import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'account_form_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';

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
    final palette = currentPalette;

    final accountsAsync = ref.watch(accountsListProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: palette.bgPrimary,
      appBar: CustomAppBar(
        title: loc.accountsTitle,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark),
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
                  loc.totalBalance(totalBalanceAsync.toStringAsFixed(2)),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: palette.textDark,
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
                        color: palette.bgTerciary,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: palette.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      loc.balanceLabel(
                                        acc.balance.toStringAsFixed(2),
                                      ),
                                      style: TextStyle(
                                        color: palette.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit, color: palette.textDark),
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
        error: (e, st) => Center(child: Text(loc.errorMessage(e.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: palette.primary,
        foregroundColor: palette.textDark,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
