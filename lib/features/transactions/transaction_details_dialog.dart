import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/db/daos/transactions_dao.dart';
import '../../data/db/tables.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_colors.dart';
import 'transaction_form_screen.dart';
import '../../l10n/app_localizations.dart';

class TransactionDetailsDialog extends ConsumerWidget {
  final TransactionWithCategory data;
  final palette = currentPalette;

  TransactionDetailsDialog({required this.data, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final palette = currentPalette;

    final transaction = data.transaction;
    final category = data.category;
    final isIncome = transaction.type == TransactionType.income;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        decoration: BoxDecoration(
          color: palette.bgPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.transactionDetailsTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: palette.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, ref, loc),
                  icon: const Icon(Icons.delete_outline),
                  color: palette.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncome ? Icons.south_west : Icons.north_east,
                  color: isIncome ? palette.green : palette.red,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  '${transaction.amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 32,
                    // fontWeight: FontWeight.bold,
                    color: isIncome ? palette.green : palette.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            _buildDetailRow(
              icon: Icons.label_outline,
              value: transaction.title ?? loc.noTitle,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.category_outlined,
              value: category?.name ?? loc.categoryGlobal,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              value:
                  '${DateFormat('HH:mm').format(transaction.date)}h ${DateFormat('EEEE, MMM d, yyyy').format(transaction.date)}',
            ),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.notes,
                value: transaction.description!,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _editTransaction(context, data),
                  icon: const Icon(Icons.edit),
                  label: Text(loc.buttonEdit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.textDark,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: palette.textDark),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 18, color: palette.textDark),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteTransactionTitle),
        content: Text(loc.deleteTransactionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: palette.textDark,
              backgroundColor: palette.primary,
            ),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: palette.red,
              backgroundColor: palette.bgRed,
            ),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final transactionService = ref.read(transactionServiceProvider);
      await transactionService.deleteTransaction(data.transaction.id);

      if (context.mounted) {
        Navigator.pop(context); // Close the details dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.transactionDeletedSuccess,
              style: TextStyle(color: palette.green),
            ),
            backgroundColor: palette.bgGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.errorDeletingTransaction(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTransaction(
    BuildContext context,
    TransactionWithCategory transactionData,
  ) {
    Navigator.pop(context); // Close details dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          initialAccountId: transactionData.transaction.accountId,
          transactionToEdit: transactionData,
        ),
      ),
    );
  }
}
