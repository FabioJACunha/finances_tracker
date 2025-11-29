import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/services_provider.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';

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
    final palette = currentPalette;
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0;
    final isEditing = widget.initialAccount != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: palette.bgPrimary,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: palette.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: palette.textDark),
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
                    style: TextStyle(color: palette.textDark),
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
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_balance.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: palette.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use transactions to change balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.secondary,
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
                    Expanded(
                      child: Text(
                        'Exclude from total balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _excludeFromTotal,
                      activeThumbColor: palette.textDark,
                      activeTrackColor: palette.primary,
                      inactiveThumbColor: palette.bgTerciary,
                      inactiveTrackColor: palette.terciary,
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
                              return palette.terciary;
                            }),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: palette.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              return palette.primary;
                            }),
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Save',
                        style: TextStyle(color: palette.textDark),
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
