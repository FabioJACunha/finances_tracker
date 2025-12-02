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
import '../../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
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
              loc.errorLoadCategories(e.toString()),

              style: TextStyle(color: palette.red),
            ),
            backgroundColor: palette.bgRed,
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
    final loc = AppLocalizations.of(context)!;
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
              _isEditing ? loc.budgetUpdated : loc.budgetCreated,
              style: TextStyle(color: palette.green),
            ),
            backgroundColor: palette.bgGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.errorSaveBudget(e.toString()),
              style: TextStyle(color: palette.red),
            ),
            backgroundColor: palette.bgRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delete() async {
    final loc = AppLocalizations.of(context)!;
    if (!mounted || widget.initialBudget == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteBudgetTitle),
        content: Text(loc.deleteBudgetConfirmation),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.textDark,
              backgroundColor: palette.primary,
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.red,
              backgroundColor: palette.bgRed,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.delete),
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
                loc.budgetDeleted,
                style: TextStyle(color: palette.green),
              ),
              backgroundColor: palette.bgGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.errorDeleteBudget(e.toString()),

                style: TextStyle(color: palette.red),
              ),
              backgroundColor: palette.bgRed,
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
    final loc = AppLocalizations.of(context)!; // GET LOCALIZATIONS
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    // Keep showing a loading screen while initializing (same behavior you had)
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: palette.bgPrimary,
        appBar: CustomAppBar(
          title: _isEditing ? loc.editBudget : loc.createBudget,
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
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(loc.loadingBudget),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.bgPrimary,
      appBar: CustomAppBar(
        title: _isEditing ? loc.editBudget : loc.createBudget,
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
                  label: loc.fieldTitle,
                  enabled: !_isLoading,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? loc.validationEnterTitle
                      : null,
                ),
                const SizedBox(height: 16),

                // Limit
                CustomTextFormField(
                  controller: _limitController,
                  label: loc.budgetLimitLabel,

                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.validationEnterLimit;
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return loc.validationValidNumber;
                    }
                    if (parsed <= 0) {
                      return loc.validationLimitMustBePositive;
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
                      return Text(
                        loc.infoNoAccountsAvailable,
                        style: const TextStyle(color: Colors.red),
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
                      label: loc.accountLabel,

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
                    loc.errorLoadAccounts(e.toString()),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 18),

                // Period Selector
                ChipSelector<BudgetPeriod>(
                  label: loc.budgetPeriodLabel,

                  items: BudgetPeriod.values,
                  initialValue: _selectedPeriod,
                  labelBuilder: (period) => period == BudgetPeriod.weekly
                      ? loc.budgetPeriodWeekly
                      : loc.budgetPeriodMonthly,
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
                      name: loc.categoryGlobal,

                      iconCodePoint: Icons.all_inclusive.codePoint,
                      colorValue: Colors.black.toARGB32(),
                      usageType: CategoryUsageType.expense,
                    );

                    final selectableCategories = allCategories;

                    if (selectableCategories.isEmpty) {
                      return Text(
                        loc.infoNoCategoriesAvailable,
                        style: const TextStyle(color: Colors.red),
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
                          label: loc.categoriesLabel,

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
                                : loc.validationSelectOneCategory;
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
                                ? loc.infoGlobalBudgetApplies
                                : loc.infoCategoriesSelected(
                                    _selectedCategoryIds.length,
                                  ),
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
                    loc.errorLoadCategories(e.toString()),
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
                        : Text(
                            _isEditing
                                ? loc.actionSaveChanges
                                : loc.actionCreateBudget,
                          ),
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
