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
        titlePadding: EdgeInsets.all(16),
        contentPadding: EdgeInsets.all(16),
        actionsPadding: EdgeInsets.all(16),
        insetPadding: EdgeInsets.symmetric(horizontal: 32),
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          minWidth: double.infinity,
        ),
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Add New Category",
          style: TextStyle(
            color: AppColors.textDark,
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
              "Cancel",
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                  ) {
                return AppColors.primary;
              }),
            ),
            onPressed: () =>
                Navigator.pop(context, _newCategoryController.text),
            child: const Text(
              "Add",
              style: TextStyle(color: AppColors.textDark),
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
          color: AppColors.bgPrimary,
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
                            color: AppColors.textDark,
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
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.none,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final theme = Theme.of(context);

                              // show date picker first
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2025),
                                lastDate: DateTime.now(),
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                builder: (context, child) => Theme(
                                  data: theme.copyWith(
                                    colorScheme: ColorScheme.light(
                                        primary: AppColors.secondary,
                                        onPrimary: AppColors.bgPrimary,
                                        onSurface: AppColors.textDark,
                                        surface: AppColors.bgPrimary
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: AppColors.bgPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );

                              if (pickedDate == null) return;
                              if (!mounted) return;

                              // show time picker
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
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${_date.day.toString().padLeft(2, '0')}/"
                                              "${_date.month.toString().padLeft(2, '0')}/"
                                              "${_date.year} "
                                              "${_date.hour.toString().padLeft(2, '0')}:"
                                              "${_date.minute.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: AppColors.textDark,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal:8),
                                    color: Colors.transparent,
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                "Cancel",
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
                                "Add Transaction",
                                style: TextStyle(color: AppColors.textDark),
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
