import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../categories/category_form_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:intl/intl.dart';

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
  int? _categoryId; // Null means 'No Category' / Global
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
            style: TextStyle(color: AppColors.green),
          ),
          backgroundColor: AppColors.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: TextStyle(color: AppColors.red)),
          backgroundColor: AppColors.bgRed,
        ),
      );
    }
  }

  Future<void> _navigateToAddCategory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
    );

    // If a category was added, the stream will update automatically
    if (result == true && mounted) {
      // The categoriesAsync provider will automatically refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    // Provider watches the current type (_type) for relevant categories
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
            // Set default account if not set (for new transactions)
            if (_accountId == 0 && accounts.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _accountId = accounts.first.id);
                }
              });
            }

            return categoriesAsync.when(
              data: (categories) {
                // Determine the initial selected Category object
                final initialCategory = _categoryId == null
                    ? categories.first
                    : categories.where((c) => c.id == _categoryId).firstOrNull;

                // Determine the initial selected Account object
                final initialAccount = accounts
                    .where((a) => a.id == _accountId)
                    .firstOrNull;

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
                        CustomTextFormField(
                          initialValue: _title,
                          maxLength: 20,
                          label: "Title",
                          onSaved: (val) => _title = val?.trim(),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'This field is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Account selector
                        ChipSelector<Account>(
                          label: "Account",
                          items: accounts,
                          initialValue: initialAccount,
                          labelBuilder: (a) => a.name,
                          // a is Account?, but guaranteed non-null since no globalItem is set
                          onChanged: (a) => setState(() => _accountId = a!.id),
                        ),
                        const SizedBox(height: 18),

                        // Type selector
                        ChipSelector<TransactionType>(
                          label: "Type",
                          items: TransactionType.values,
                          initialValue: _type,
                          labelBuilder: (t) => t.name.capitalize(),
                          onChanged: (t) => setState(() {
                            _type = t!; // Guaranteed non-null
                            _categoryId =
                                null; // Reset category when type changes
                          }),
                        ),
                        const SizedBox(height: 18),

                        // Category selector (uses 'globalItem' logic)
                        ChipSelector<Category>(
                          label: "Category",
                          items: categories,
                          // Pass the 'No Category' item
                          initialValue: initialCategory,
                          // Selected category object or null
                          allowAddNew: true,
                          onAddNew: _navigateToAddCategory,
                          onChanged: (cat) {
                            // cat is Category?
                            // null is returned when 'No Category' is selected
                            setState(() => _categoryId = cat?.id);
                          },
                          labelBuilder: (cat) => cat.name,
                          getItemColor: (cat) => Color(cat.colorValue),
                          getItemIcon: (cat) {
                            if (cat.id == -1) {
                              return Icons.all_inclusive;
                            }
                            return IconData(
                              cat.iconCodePoint,
                              fontFamily: 'MaterialIcons',
                            );
                          },
                          // Removed validator: null is a valid state for a transaction category
                        ),
                        const SizedBox(height: 18),

                        // Description field
                        CustomTextFormField(
                          initialValue: _description,
                          label: "Description",
                          onSaved: (val) => _description = val?.trim(),
                        ),
                        const SizedBox(height: 22),

                        // Date picker
                        Material(
                          color: Colors.transparent,
                          clipBehavior: Clip.none,
                          child: InkWell(
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final horizontalPadding = 16.0;

                              // Open the calendar_date_picker2 dialog
                              final pickedDates =
                                  await showCalendarDatePicker2Dialog(
                                    dialogSize: Size(
                                      screenWidth - (horizontalPadding * 2),
                                      450,
                                    ),
                                    context: context,
                                    config:
                                        CalendarDatePicker2WithActionButtonsConfig(
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                          currentDate: _date,
                                          calendarType:
                                              CalendarDatePicker2Type.single,
                                          selectedDayHighlightColor:
                                              palette.secondary,
                                          weekdayLabelTextStyle: TextStyle(
                                            color: palette.textDark,
                                          ),
                                          dayTextStyle: TextStyle(
                                            color: palette.textDark,
                                          ),
                                          yearTextStyle: TextStyle(
                                            color: palette.textDark,
                                          ),
                                          buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          okButton: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: palette.primary,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: palette.textDark,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          cancelButton: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: palette.terciary,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: palette.textDark,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          controlsTextStyle: TextStyle(
                                            color: palette.textDark,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    dialogBackgroundColor: palette.bgPrimary,
                                    value: [_date],
                                    borderRadius: BorderRadius.circular(8),
                                  );

                              if (pickedDates == null ||
                                  pickedDates.isEmpty ||
                                  pickedDates.first == null) {
                                return;
                              }
                              if (!mounted) return;

                              final pickedDate = pickedDates.first!;

                              // Use day_night_time_picker for time selection
                              Time initialTime = Time(
                                hour: _date.hour,
                                minute: _date.minute,
                              );

                              Navigator.of(navigator.context).push(
                                showPicker(
                                  context: navigator.context,
                                  value: initialTime,
                                  onChange: (Time newTime) {
                                    if (!mounted) return;

                                    setState(() {
                                      _date = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        newTime.hour,
                                        newTime.minute,
                                      );
                                    });
                                  },
                                  is24HrFormat: true,
                                  accentColor: palette.textDark,
                                  unselectedColor: palette.textMuted,
                                  cancelText: "Cancel",
                                  okText: "Confirm",
                                  cancelStyle: TextStyle(
                                    color: palette.textDark,
                                  ),
                                  buttonsSpacing: 8,
                                  okStyle: TextStyle(color: palette.textDark),
                                  cancelButtonStyle: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      palette.terciary,
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
                                      palette.textDark,
                                    ),
                                  ),
                                  buttonStyle: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      palette.primary,
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
                                      palette.textDark,
                                    ),
                                  ),
                                  dialogInsetPadding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                  borderRadius: 12,
                                ),
                              );
                            },

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    color: palette.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: palette.terciary,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat(
                                            'd MMM y HH:mm',
                                          ).format(_date),
                                          style: TextStyle(
                                            color: palette.textDark,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: palette.textDark,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Amount field
                        CustomTextFormField(
                          initialValue: _amount?.toString(),
                          label: "Amount",
                          decoration: const InputDecoration(hintText: "0.00"),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onSaved: (val) => _amount = double.tryParse(val!),
                          validator: (val) =>
                              val == null || double.tryParse(val) == null
                              ? "Enter a valid number"
                              : null,
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

extension CategoryListExtensions on List<Category> {
  Category? firstWhereOrNull(bool Function(Category) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension AccountListExtensions on List<Account> {
  Account? firstWhereOrNull(bool Function(Account) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
