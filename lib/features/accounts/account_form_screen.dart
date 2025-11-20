import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/services_provider.dart';
import '../../data/db/database.dart';
import '../../helpers/app_colors.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  final Account? initialAccount;

  const AccountFormScreen({this.initialAccount, super.key});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _balance;
  bool _excludeFromTotal = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialAccount?.name ?? '';
    _balance = widget.initialAccount?.balance ?? 0.0;
    _excludeFromTotal = widget.initialAccount?.excludeFromTotal ?? false;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final accountService = ref.read(accountServiceProvider);

      if (widget.initialAccount != null) {
        // Update existing account
        await accountService.updateAccount(
          id: widget.initialAccount!.id,
          name: _name,
          excludeFromTotal: _excludeFromTotal,
        );

        // Note: Balance is not updated here - it should only change through transactions
        // If you want to allow manual balance adjustments, you need a separate method
      } else {
        // Create new account
        await accountService.createAccount(
          name: _name,
          initialBalance: _balance,
          excludeFromTotal: _excludeFromTotal,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0;
    final isEditing = widget.initialAccount != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        width: screenWidth - 2 * horizontalPadding,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Account' : 'Add Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: const TextStyle(color: AppColors.textDark),
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 12),
                // Only show balance field when creating new account
                if (!isEditing) ...[
                  TextFormField(
                    style: const TextStyle(color: AppColors.textDark),
                    initialValue: _balance.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Initial Balance',
                      helperText:
                          'Balance can only be changed through transactions after creation',
                      helperMaxLines: 2,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) =>
                        val == null || double.tryParse(val) == null
                        ? 'Enter a valid number'
                        : null,
                    onSaved: (val) => _balance = double.parse(val!),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // Show current balance as read-only when editing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_balance.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use transactions to change balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Exclude from total balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _excludeFromTotal,
                      activeThumbColor: AppColors.textDark,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: AppColors.bgSecondary,
                      inactiveTrackColor: AppColors.terciary,
                      trackOutlineColor:
                          WidgetStateProperty.resolveWith<Color?>((
                            Set<WidgetState> states,
                          ) {
                            return Colors.transparent;
                          }),
                      onChanged: (val) =>
                          setState(() => _excludeFromTotal = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              return AppColors.terciary;
                            }),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              return AppColors.primary;
                            }),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
