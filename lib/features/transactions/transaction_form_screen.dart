import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/tables.dart';
import '../../data/db/database.dart';
import '../../helpers/app_colors.dart';
import 'package:drift/drift.dart' hide Column;
import '../../components/select_form_field.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int initialAccountId;

  const TransactionFormScreen({required this.initialAccountId, super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
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

  @override
  void dispose() {
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await ref
        .read(transactionsDaoProvider)
        .insertTransactionAndUpdateBalance(
          accountId: _accountId,
          amount: _amount!,
          type: _type,
          description: _description,
          categoryName: _category ?? "Uncategorized",
          date: _date,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _addNewCategory() async {
    final newCategoryName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Add New Category",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(labelText: "Category Name"),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.darkGreen),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, _newCategoryController.text),
            child: const Text(
              "Add",
              style: TextStyle(color: AppColors.darkGreen),
            ),
          ),
        ],
      ),
    );

    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      final dao = ref.read(categoriesDaoProvider);
      await dao.insertCategory(
        CategoriesCompanion(name: Value(newCategoryName)),
      );
      setState(() {
        _category = newCategoryName;
        _newCategoryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0;

    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: screenWidth - 2 * horizontalPadding,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: accountsAsync.when(
          data: (accounts) {
            return categoriesAsync.when(
              data: (categories) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Transaction",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectFormField<int>(
                          label: "Account",
                          value: _accountId,
                          items: accounts.map((a) => a.id).toList(),
                          itemAsString: (id) =>
                              accounts.firstWhere((a) => a.id == id).name,
                          onChanged: (val) => setState(() => _accountId = val!),
                        ),
                        const SizedBox(height: 12),
                        SelectFormField<TransactionType>(
                          label: "Type",
                          value: _type,
                          items: TransactionType.values,
                          itemAsString: (t) => t.name.capitalize(),
                          onChanged: (val) => setState(() => _type = val!),
                        ),
                        const SizedBox(height: 12),
                        SelectFormField<String>(
                          label: "Category",
                          value: _category,
                          items: [
                            "__add_new__",
                            ...categories.map((c) => c.name),
                          ],
                          itemAsString: (val) =>
                              val == "__add_new__" ? "Add new category" : val,
                          onChanged: (val) {
                            if (val == "__add_new__") {
                              _addNewCategory();
                            } else {
                              setState(() => _category = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Description",
                          ),
                          onSaved: (val) => _description = val,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Amount",
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) =>
                              val == null || double.tryParse(val) == null
                              ? "Enter a valid number"
                              : null,
                          onSaved: (val) => _amount = double.tryParse(val!),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                          child: ListTile(
                            title: Text(
                              "Date: ${_date.day.toString().padLeft(2, '0')}/"
                              "${_date.month.toString().padLeft(2, '0')}/"
                              "${_date.year} "
                              "${_date.hour.toString().padLeft(2, '0')}:"
                              "${_date.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(color: AppColors.green),
                            ),
                            trailing: const Icon(
                              Icons.calendar_today,
                              color: AppColors.green,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final theme = Theme.of(context);

                              // show date picker first
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2025),
                                lastDate: DateTime.now(),
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                builder: (context, child) => Theme(
                                  data: theme.copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.green,
                                      onPrimary: Colors.white,
                                      onSurface: AppColors.darkGreen,
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: AppColors.lightGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.green,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );

                              if (pickedDate == null) return;
                              if (!mounted) return;

                              // show time picker - DON'T use context here
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
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: AppColors.darkGreen),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _submit,
                              child: const Text(
                                "Add Transaction",
                                style: TextStyle(color: AppColors.darkGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text("Error loading categories: $e")),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Error loading accounts: $e")),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
