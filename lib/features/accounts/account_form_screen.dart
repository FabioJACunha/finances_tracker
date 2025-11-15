import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../data/db/database.dart';
import 'package:drift/drift.dart';

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
      id: widget.initialAccount != null ? Value(widget.initialAccount!.id) : const Value.absent(),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialAccount != null ? 'Edit Account' : 'Add Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!,
              ),
              TextFormField(
                initialValue: _balance.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Balance'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter a valid number' : null,
                onSaved: (val) => _balance = double.parse(val!),
              ),
              SwitchListTile(
                value: _excludeFromTotal,
                title: const Text('Exclude from total balance'),
                onChanged: (val) => setState(() => _excludeFromTotal = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
