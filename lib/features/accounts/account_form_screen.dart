import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'package:drift/drift.dart' hide Column;
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

    final dao = ref.read(accountsDaoProvider);

    final accountCompanion = AccountsCompanion(
      id: widget.initialAccount != null
          ? Value(widget.initialAccount!.id)
          : const Value.absent(),
      name: Value(_name),
      balance: Value(_balance),
      excludeFromTotal: Value(_excludeFromTotal),
    );

    if (widget.initialAccount != null) {
      await dao.updateAccountData(accountCompanion);
    } else {
      await dao.insertAccount(accountCompanion);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
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
                  widget.initialAccount != null
                      ? 'Edit Account'
                      : 'Add Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: AppColors.green),
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: TextStyle(color: AppColors.green),
                  initialValue: _balance.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Balance'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) =>
                      val == null || double.tryParse(val) == null
                      ? 'Enter a valid number'
                      : null,
                  onSaved: (val) => _balance = double.parse(val!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Exclude from total balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _excludeFromTotal,
                      activeThumbColor: AppColors.green,
                      activeTrackColor: AppColors.lightGreen,
                      inactiveThumbColor: Colors.grey,
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.darkGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: AppColors.darkGreen),
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
