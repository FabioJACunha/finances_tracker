import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/tables.dart';
import '../../data/db/database.dart';
import 'package:drift/drift.dart';


class TransactionFormScreen extends ConsumerStatefulWidget {
  final int initialAccountId;
  const TransactionFormScreen({required this.initialAccountId, super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _accountId;
  TransactionType _type = TransactionType.expense;
  String? _category;
  String? _description;
  double? _amount;
  DateTime _date = DateTime.now();
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Insert transaction and update account balance
    await ref.read(transactionsDaoProvider).insertTransactionAndUpdateBalance(
      accountId: _accountId,
      amount: _amount!,
      type: _type,
      description: _description,
      categoryName: _category ?? "Uncategorized", // ← use categoryName
      date: _date,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _addNewCategory() async {
    final newCategoryName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _newCategoryController.text),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      final dao = ref.read(categoriesDaoProvider);
      await dao.insertCategory(CategoriesCompanion(name: Value(newCategoryName)));
      setState(() {
        _category = newCategoryName;
        _newCategoryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: accountsAsync.when(
        data: (accounts) {
          return categoriesAsync.when(
            data: (categories) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _accountId,
                        decoration: const InputDecoration(labelText: "Account"),
                        items: accounts
                            .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _accountId = val!),
                      ),
                      DropdownButtonFormField<TransactionType>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: "Type"),
                        items: TransactionType.values
                            .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.capitalize()),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: "Category"),
                        items: [
                          ...categories.map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          )),
                          const DropdownMenuItem(
                            value: '__add_new__',
                            child: Text("Add new category"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == '__add_new__') {
                            _addNewCategory();
                          } else {
                            setState(() => _category = val);
                          }
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Description"),
                        onSaved: (val) => _description = val,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Amount"),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) =>
                        val == null || double.tryParse(val) == null ? "Enter a valid number" : null,
                        onSaved: (val) => _amount = double.tryParse(val!),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text("Date: ${_date.toLocal()}".split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final pickedDate = await showDatePicker(
                            context: navigator.context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate == null || !mounted) return;
                          final pickedTime = await showTimePicker(
                            context: navigator.context,
                            initialTime: TimeOfDay.fromDateTime(_date),
                          );
                          if (!mounted) return;
                          setState(() {
                            _date = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime?.hour ?? _date.hour,
                              pickedTime?.minute ?? _date.minute,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: _submit, child: const Text("Add Transaction")),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error loading categories: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading accounts: $e")),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
