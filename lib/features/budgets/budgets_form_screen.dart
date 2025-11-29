import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budgets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chip_selector.dart';

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

  int? _selectedAccountId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  List<int> _selectedCategoryIds = [];

  bool _isLoading = false;
  bool _isInitialized = false; // Track if we've loaded initial data
  bool get _isEditing => widget.initialBudget != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialBudget?.label);
    _limitController =
        TextEditingController(text: widget.initialBudget?.limit.toString());
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
          SnackBar(content: Text('Failed to load categories: $e')),
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
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    // Validation: At least one category must be selected (Global or specific)
    // This is now always true since Global is selected by default when list is empty

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await ref.read(budgetServiceProvider).updateBudget(
          id: widget.initialBudget!.id,
          label: _labelController.text.trim(),
          limit: double.parse(_limitController.text),
          accountId: _selectedAccountId!,
          period: _selectedPeriod,
          categoryIds: _selectedCategoryIds, // Empty list = Global
        );
      } else {
        await ref.read(budgetServiceProvider).createBudget(
          label: _labelController.text.trim(),
          limit: double.parse(_limitController.text),
          accountId: _selectedAccountId!,
          period: _selectedPeriod,
          categoryIds: _selectedCategoryIds, // Empty list = Global
        );
      }

      // Invalidate providers to force refresh
      ref.invalidate(budgetsListProvider);
      ref.invalidate(budgetSpentProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Budget updated' : 'Budget created'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save budget: $e'),
            backgroundColor: Colors.red,
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
            'Are you sure you want to delete this budget? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

        // Invalidate providers to force refresh
        ref.invalidate(budgetsListProvider);
        ref.invalidate(budgetSpentProvider);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget deleted'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete budget: $e'),
              backgroundColor: Colors.red,
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
    final palette = currentPalette;


    // Show loading while initializing edit mode
    if (!_isInitialized) {
      return Dialog(
        backgroundColor: palette.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading budget...'),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: palette.bgPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Budget' : 'New Budget',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: palette.textDark,
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: _isLoading ? null : _delete,
                      )
                  ],
                ),
                const SizedBox(height: 20),

                // Label
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Label',
                    hintText: 'e.g., Groceries Budget',
                  ),
                  enabled: !_isLoading,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a label'
                      : null,
                ),
                const SizedBox(height: 16),

                // Limit
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(
                    labelText: 'Limit Amount (€)',
                    hintText: '0.00',
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

                    // Set default if not set
                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _selectedAccountId = accounts.first.id);
                        }
                      });
                    }

                    return ChipSelector<Account>(
                      label: 'Account',
                      items: accounts,
                      selectedValue: accounts
                          .where((a) => a.id == _selectedAccountId)
                          .firstOrNull,
                      labelBuilder: (acc) => acc.name,
                      onChanged: (acc) {
                        if (!_isLoading) {
                          setState(() => _selectedAccountId = acc.id);
                        }
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text(
                    'Error loading accounts: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),

                // Period Selector
                ChipSelector<BudgetPeriod>(
                  label: 'Period',
                  items: BudgetPeriod.values,
                  selectedValue: _selectedPeriod,
                  labelBuilder: (period) =>
                  period == BudgetPeriod.weekly ? 'Weekly' : 'Monthly',
                  onChanged: (period) {
                    if (!_isLoading) {
                      setState(() => _selectedPeriod = period);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Category Selector
                categoriesAsync.when(
                  data: (allCategories) {
                    // Create a synthetic "Global" category
                    final globalCategory = Category(
                      id: -1, // Special ID for global
                      name: 'Global',
                      iconCodePoint: Icons.all_inclusive.codePoint,
                      colorValue: palette.secondary.toARGB32(),
                      usageType: CategoryUsageType.expense,
                    );

                    // Add global category at the beginning
                    final selectableCategories = [globalCategory, ...allCategories];

                    if (selectableCategories.length == 1) {
                      // Only global available, need real categories
                      return const Text(
                        'No categories available. Create a category first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    // Determine selected categories
                    // If empty list, select global; otherwise select the specific categories
                    final selectedCats = _selectedCategoryIds.isEmpty
                        ? [globalCategory]
                        : selectableCategories
                        .where((c) => _selectedCategoryIds.contains(c.id))
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChipSelector<Category>(
                          label: 'Categories',
                          items: selectableCategories,
                          multiSelect: true,
                          selectedValues: selectedCats,
                          labelBuilder: (cat) => cat.name,
                          // Show icons for all categories
                          getItemIcon: (cat) {
                            if (cat.id == -1) {
                              return Icons.all_inclusive;
                            }
                            return IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');
                          },
                          // Global gets secondary color, others get their category color
                          getItemColor: (cat) => Color(cat.colorValue),
                          onMultiChanged: (cats) {
                            if (!_isLoading) {
                              // Check if Global is in the selection
                              final hasGlobal = cats.any((c) => c.id == -1);
                              final hasNonGlobal = cats.any((c) => c.id != -1);

                              if (hasGlobal && hasNonGlobal) {
                                // Both Global and specific categories selected
                                // Determine which was just added
                                final wasGlobalSelected = _selectedCategoryIds.isEmpty;

                                if (wasGlobalSelected) {
                                  // Global was selected, user is now picking specific categories
                                  // Remove Global, keep only the non-Global categories
                                  setState(() {
                                    _selectedCategoryIds = cats
                                        .where((c) => c.id != -1)
                                        .map((c) => c.id)
                                        .toList();
                                  });
                                } else {
                                  // Specific categories were selected, user just picked Global
                                  // Clear everything (Global = empty list)
                                  setState(() {
                                    _selectedCategoryIds = [];
                                  });
                                }
                              } else if (hasGlobal && !hasNonGlobal) {
                                // Only Global selected
                                setState(() {
                                  _selectedCategoryIds = [];
                                });
                              } else {
                                // Only non-Global categories selected
                                setState(() {
                                  _selectedCategoryIds = cats
                                      .where((c) => c.id != -1)
                                      .map((c) => c.id)
                                      .toList();
                                });
                              }
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
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
                  loading: () => const Center(child: CircularProgressIndicator()),
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