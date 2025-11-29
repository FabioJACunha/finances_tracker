import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/custom_app_bar.dart';
import '../categories/category_form_screen.dart';

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
  int? _categoryId;
  String? _title;
  String? _description;
  double? _amount;
  late DateTime _date;
  final palette = currentPalette;

  bool get isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final tx = widget.transactionToEdit!.transaction;
      _accountId = tx.accountId;
      _type = tx.type;
      _categoryId = tx.categoryId;
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
          categoryId: _categoryId,
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
          categoryId: _categoryId,
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
            style: const TextStyle(color: AppColors.green),
          ),
          backgroundColor: palette.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navigateToAddCategory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
    );

    // If a category was added, the stream will update automatically
    // We just need to wait a moment for the UI to refresh
    if (result == true && mounted) {
      // Optional: Show a message or handle the result
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));
    final title = isEditing ? "Edit Transaction" : "Add Transaction";
    final palette = currentPalette;

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark),
          onPressed: () => Navigator.pop(context),
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
                        const SizedBox(height: 16),
                        // Title field
                        TextFormField(
                          initialValue: _title,
                          decoration: const InputDecoration(labelText: "Title"),
                          onSaved: (val) => _title = val?.trim(),
                        ),
                        const SizedBox(height: 8),

                        // Account selector
                        ChipSelector<int>(
                          label: "Account",
                          items: accounts.map((a) => a.id).toList(),
                          selectedValue: _accountId,
                          labelBuilder: (id) =>
                              accounts.firstWhere((a) => a.id == id).name,
                          onChanged: (id) => setState(() => _accountId = id),
                        ),
                        const SizedBox(height: 8),

                        ChipSelector<TransactionType>(
                          label: "Type",
                          items: TransactionType.values,
                          selectedValue: _type,
                          labelBuilder: (t) => t.name.capitalize(),
                          onChanged: (t) => setState(() {
                            _type = t;
                            _categoryId = null;
                          }),
                        ),
                        const SizedBox(height: 6),

                        // Category selector with icons
                        ChipSelector<int>(
                          label: "Category",
                          items: categories.map((c) => c.id).toList(),
                          selectedValue: _categoryId,
                          allowAddNew: true,
                          onAddNew: _navigateToAddCategory,
                          labelBuilder: (id) =>
                              categories.firstWhere((c) => c.id == id).name,
                          onChanged: (id) => setState(() => _categoryId = id),
                          getItemColor: (id) => Color(
                            categories.firstWhere((c) => c.id == id).colorValue,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          initialValue: _description,
                          decoration: const InputDecoration(
                            labelText: "Description",
                          ),
                          onSaved: (val) => _description = val?.trim(),
                        ),
                        const SizedBox(height: 16),

                        // Date picker
                        Material(
                          color: palette.bgTerciary,
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
                                    colorScheme: ColorScheme.light(
                                      primary: palette.secondary,
                                      onPrimary: palette.bgPrimary,
                                      onSurface: palette.textDark,
                                      surface: palette.bgPrimary,
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: palette.bgPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: palette.textDark,
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
                                initialEntryMode: TimePickerEntryMode.dialOnly,
                                builder: (context, child) => MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: true),
                                  child: Theme(
                                    data: theme.copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: palette.secondary,
                                        onPrimary: palette.bgPrimary,
                                        onSurface: palette.textDark,
                                        surface: palette.bgPrimary,
                                      ),
                                      dialogTheme: DialogThemeData(
                                        backgroundColor: palette.bgPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: palette.textDark,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                ),
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
                                          style: TextStyle(
                                            color: palette.textDark,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: palette.textDark,
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
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                        color: palette.secondary,
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
                        const SizedBox(height: 16),

                        // Amount field
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
                        const SizedBox(height: 24),

                        // Submit button
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
