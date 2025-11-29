import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/db/daos/transactions_dao.dart';
import '../../data/db/tables.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_colors.dart';
import 'transaction_form_screen.dart';

class TransactionDetailsDialog extends ConsumerWidget {
  final TransactionWithCategory data;
  final palette = currentPalette;

  TransactionDetailsDialog({required this.data, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: palette.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, ref),
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
                  isIncome ? Icons.south_west: Icons.north_east,
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
              value: transaction.title ?? 'No title',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.category_outlined,
              value: category?.name ?? 'Uncategorized',
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
                  onPressed: () => _editTransaction(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
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
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Transaction',
          style: TextStyle(color: palette.textDark),
        ),
        content: Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
          style: TextStyle(color: palette.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: palette.textDark),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
              'Transaction deleted successfully',
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
            content: Text('Error deleting transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTransaction(BuildContext context) {
    Navigator.pop(context); // Close details dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          initialAccountId: data.transaction.accountId,
          transactionToEdit: data,
        ),
      ),
    );
  }
}
