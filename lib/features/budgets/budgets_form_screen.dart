import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budgets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_app_bar.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  final Budget? initialBudget;

  const BudgetFormScreen({super.key, this.initialBudget});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _limitController;
  final palette = currentPalette;

  int? _selectedAccountId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  List<int> _selectedCategoryIds = []; // Empty list means Global budget

  bool _isLoading = false;
  bool _isInitialized = false; // Track if we've loaded initial data
  bool get _isEditing => widget.initialBudget != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialBudget?.label);
    _limitController = TextEditingController(
      text: widget.initialBudget?.limit.toString(),
    );
    _selectedAccountId = widget.initialBudget?.accountId;
    _selectedPeriod = widget.initialBudget?.period ?? BudgetPeriod.monthly;

    // Load initial categories if editing
    if (_isEditing) {
      _loadInitialCategories();
    } else {
      _isInitialized = true;
    }
  }

  Future<void> _loadInitialCategories() async {
    try {
      final ids = await ref
          .read(budgetsDaoProvider)
          .getCategoryIdsForBudget(widget.initialBudget!.id);

      if (mounted) {
        setState(() {
          _selectedCategoryIds = ids;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialized = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load categories: $e',
              style: TextStyle(color: AppColors.red),
            ),
            backgroundColor: AppColors.bgRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoryIdsToSave = _selectedCategoryIds.isEmpty
          ? <int>[]
          : _selectedCategoryIds;

      if (_isEditing) {
        await ref
            .read(budgetServiceProvider)
            .updateBudget(
              id: widget.initialBudget!.id,
              label: _labelController.text.trim(),
              limit: double.parse(_limitController.text),
              accountId: _selectedAccountId!,
              period: _selectedPeriod,
              categoryIds: categoryIdsToSave, // Empty list = Global
            );
      } else {
        await ref
            .read(budgetServiceProvider)
            .createBudget(
              label: _labelController.text.trim(),
              limit: double.parse(_limitController.text),
              accountId: _selectedAccountId!,
              period: _selectedPeriod,
              categoryIds: categoryIdsToSave, // Empty list = Global
            );
      }

      ref.invalidate(budgetsListProvider);
      ref.invalidate(budgetSpentProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Budget updated' : 'Budget created',
              style: TextStyle(color: AppColors.green),
            ),
            backgroundColor: AppColors.bgGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save budget: $e',
              style: TextStyle(color: AppColors.red),
            ),
            backgroundColor: AppColors.bgRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delete() async {
    if (!mounted || widget.initialBudget == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete this budget? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: palette.textDark, backgroundColor: palette.primary),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red, backgroundColor: AppColors.bgRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(budgetServiceProvider)
            .deleteBudget(widget.initialBudget!.id);

        ref.invalidate(budgetsListProvider);
        ref.invalidate(budgetSpentProvider);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Budget deleted',
                style: TextStyle(color: AppColors.green),
              ),
              backgroundColor: AppColors.bgGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete budget: $e',
                style: TextStyle(color: AppColors.red),
              ),
              backgroundColor: AppColors.bgRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    // Keep showing a loading screen while initializing (same behavior you had)
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: palette.bgPrimary,
        appBar: CustomAppBar(
          title: _isEditing ? 'Edit Budget' : 'Create Budget',
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: palette.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          extraActions: [
            if (_isEditing)
              IconButton(
                icon: Icon(Icons.delete_outline, color: palette.textMuted),
                onPressed: _isLoading ? null : _delete,
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading budget...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.bgPrimary,
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Budget' : 'Create Budget',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        extraActions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: palette.textMuted),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                CustomTextFormField(
                  controller: _labelController,
                  label: "Title",
                  enabled: !_isLoading,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a title'
                      : null,
                ),
                const SizedBox(height: 16),

                // Limit
                CustomTextFormField(
                  controller: _limitController,
                  label: "Limit Amount",
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a limit';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'Enter a valid number';
                    }
                    if (parsed <= 0) {
                      return 'Limit must be greater than 0';
                    }
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(hintText: "0.00"),
                ),
                const SizedBox(height: 20),

                // Account Selector
                accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return const Text(
                        'No accounts available. Create an account first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    // Preserve your original safe pattern: only call setState in a post frame callback
                    // to set the default when creating a new budget and no account is selected.
                    if (!_isEditing &&
                        _selectedAccountId == null &&
                        accounts.isNotEmpty) {
                      // *** FIX: Set the ID for the current build immediately ***
                      final defaultAccountId = accounts.first.id;
                      _selectedAccountId = defaultAccountId;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(
                            () => _selectedAccountId = accounts.first.id,
                          );
                        }
                      });
                    }

                    final initialAccount = accounts
                        .where((a) => a.id == _selectedAccountId)
                        .firstOrNull;

                    return ChipSelector<Account>(
                      label: 'Account',
                      items: accounts,
                      initialValue: initialAccount,
                      labelBuilder: (acc) => acc.name,
                      onChanged: (acc) {
                        if (!_isLoading) {
                          setState(() => _selectedAccountId = acc?.id);
                        }
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text(
                    'Error loading accounts: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 18),

                // Period Selector
                ChipSelector<BudgetPeriod>(
                  label: 'Period',
                  items: BudgetPeriod.values,
                  initialValue: _selectedPeriod,
                  labelBuilder: (period) =>
                      period == BudgetPeriod.weekly ? 'Weekly' : 'Monthly',
                  onChanged: (period) {
                    if (!_isLoading) {
                      setState(() => _selectedPeriod = period!);
                    }
                  },
                ),
                const SizedBox(height: 18),

                // Category Selector
                categoriesAsync.when(
                  data: (allCategories) {
                    // Create a synthetic "Global" category
                    final globalCategory = Category(
                      id: -1,
                      // Special ID for global
                      name: 'Global',
                      iconCodePoint: Icons.all_inclusive.codePoint,
                      colorValue: Colors.black.toARGB32(),
                      usageType: CategoryUsageType.expense,
                    );

                    final selectableCategories = allCategories;

                    if (selectableCategories.isEmpty) {
                      return const Text(
                        'No categories available. Create a category first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    final selectedCats = _selectedCategoryIds.isEmpty
                        ? null
                        : selectableCategories
                              .where((c) => _selectedCategoryIds.contains(c.id))
                              .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChipSelector<Category>.multi(
                          label: "Categories",
                          items: selectableCategories,
                          globalItem: globalCategory,
                          selectedValues: selectedCats,
                          onMultiChanged: (cats) {
                            if (!_isLoading) {
                              setState(() {
                                _selectedCategoryIds =
                                    cats?.map((c) => c.id).toList() ?? [];
                              });
                            }
                          },
                          labelBuilder: (cat) => cat.name,
                          validator: (cats) {
                            return cats == null || cats.isNotEmpty
                                ? null
                                : "Please select at least one category";
                          },
                          getItemIcon: (cat) {
                            if (cat.id == -1) {
                              return Icons.all_inclusive;
                            }
                            return IconData(
                              cat.iconCodePoint,
                              fontFamily: 'MaterialIcons',
                            );
                          },
                          getItemColor: (cat) => Color(cat.colorValue),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _selectedCategoryIds.isEmpty
                                ? 'Global budget applies to all categories'
                                : '${_selectedCategoryIds.length} ${_selectedCategoryIds.length == 1 ? 'category' : 'categories'} selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text(
                    'Error loading categories: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.textDark,
                            ),
                          )
                        : Text(_isEditing ? 'Save Changes' : 'Create Budget'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
