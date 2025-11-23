import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/tables.dart';
import '../../data/db/database.dart';
import '../../helpers/app_colors.dart';
import '../../components/select_form_field.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int initialAccountId;
  final TransactionWithCategory? transactionToEdit;

  const TransactionFormScreen({
    required this.initialAccountId,
    this.transactionToEdit,
    super.key,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _accountId;
  late TransactionType _type;
  String? _category;
  String? _title;
  String? _description;
  double? _amount;
  late DateTime _date;
  final TextEditingController _newCategoryController = TextEditingController();

  bool get isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final tx = widget.transactionToEdit!.transaction;
      _accountId = tx.accountId;
      _type = tx.type;
      _category = widget.transactionToEdit!.category?.name;
      _title = tx.title;
      _description = tx.description;
      _amount = tx.amount;
      _date = tx.date;
    } else {
      _accountId = widget.initialAccountId;
      _type = TransactionType.expense;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final transactionService = ref.read(transactionServiceProvider);

      if (isEditing) {
        // Update existing transaction
        await transactionService.updateTransaction(
          transactionId: widget.transactionToEdit!.transaction.id,
          accountId: _accountId,
          amount: _amount!,
          type: _type,
          title: _title,
          description: _description,
          categoryName: _category,
          date: _date,
        );
      } else {
        // Create new transaction
        await transactionService.createTransaction(
          accountId: _accountId,
          amount: _amount!,
          type: _type,
          title: _title,
          description: _description,
          categoryName: _category,
          date: _date,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Transaction updated successfully'
                : 'Transaction added successfully',
            style: TextStyle(color: AppColors.green),
          ),

          backgroundColor: AppColors.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addNewCategory() async {
    final newCategoryName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.all(16),
        contentPadding: const EdgeInsets.all(16),
        actionsPadding: const EdgeInsets.all(16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(
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
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
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
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                return AppColors.primary;
              }),
            ),
            onPressed: () =>
                Navigator.pop(context, _newCategoryController.text.trim()),
            child: const Text(
              "Add",
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );

    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      try {
        final categoryService = ref.read(categoryServiceProvider);
        await categoryService.createCategory(newCategoryName);

        setState(() {
          _category = newCategoryName;
          _newCategoryController.clear();
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Transaction" : "Add Transaction",
          style: const TextStyle(color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            return categoriesAsync.when(
              data: (categories) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ToggleButtons(
                                isSelected: TransactionType.values
                                    .map((t) => t == _type)
                                    .toList(),
                                onPressed: (index) {
                                  setState(() {
                                    _type = TransactionType.values[index];
                                  });
                                },
                                renderBorder: false,
                                borderRadius: BorderRadius.circular(100),
                                fillColor: Colors.transparent,
                                children: TransactionType.values.mapIndexed((
                                  index,
                                  t,
                                ) {
                                  final bool selected = (t == _type);
                                  final bool isLast =
                                      index ==
                                      TransactionType.values.length - 1;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: isLast ? 0 : 8.0,
                                    ),
                                    // Add 8.0 spacing to the right of every button except the last one
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.terciary
                                            : AppColors.bgSecondary,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          t.name.capitalize(),
                                          style: TextStyle(
                                            color: selected
                                                ? AppColors.secondary
                                                : AppColors.textDark,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
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
                        TextFormField(
                          initialValue: _title,
                          decoration: const InputDecoration(labelText: "Title"),
                          onSaved: (val) => _title = val?.trim(),
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
                          initialValue: _description,
                          decoration: const InputDecoration(
                            labelText: "Description",
                          ),
                          onSaved: (val) => _description = val?.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _amount?.toString(),
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

                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                builder: (context, child) => Theme(
                                  data: theme.copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.secondary,
                                      onPrimary: AppColors.bgPrimary,
                                      onSurface: AppColors.textDark,
                                      surface: AppColors.bgPrimary,
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
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    12,
                                    16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${_date.day.toString().padLeft(2, '0')}/"
                                          "${_date.month.toString().padLeft(2, '0')}/"
                                          "${_date.year} "
                                          "${_date.hour.toString().padLeft(2, '0')}:"
                                          "${_date.minute.toString().padLeft(2, '0')}",
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Icon(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    color: Colors.transparent,
                                    child: const Text(
                                      "Date",
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.add),
                              label: Text(
                                isEditing ? "Save Changes" : "Add Transaction",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textDark,
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
