import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../providers/budgets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import 'budgets_form_screen.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _openForm(BuildContext context, [Budget? budget]) {
    showDialog(
      context: context,
      builder: (_) => BudgetFormScreen(initialBudget: budget),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsListProvider);
    final palette = currentPalette;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Budgets',
        leading: Icon(Icons.pie_chart_outline, color: palette.textDark),
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: palette.textDark,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No budgets yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: palette.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to create your first budget',
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.textDark,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: budgets.length,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 80,
            ),
            itemBuilder: (context, index) {
              return _BudgetListItem(budget: budgets[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: palette.primary,
        foregroundColor: palette.textDark,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetListItem extends ConsumerWidget {
  final Budget budget;

  const _BudgetListItem({required this.budget});

  void _openForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => BudgetFormScreen(initialBudget: budget),
    );
  }

  Color _getProgressColor(double progress, bool isOverBudget) {
    if (isOverBudget) return Colors.red;
    if (progress >= 0.9) return Colors.orange;
    if (progress >= 0.7) return Colors.yellow.shade700;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spentAsync = ref.watch(budgetSpentProvider(budget));
    final palette = currentPalette;

    // FIXED: Use budget.id instead of budget object
    final categoriesAsync = ref.watch(budgetCategoriesProvider(budget.id));

    return GestureDetector(
      onTap: () => _openForm(context, ref),
      child: Card(
        color: palette.bgTerciary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: spentAsync.when(
            data: (spent) {
              final limit = budget.limit;
              final remaining = limit - spent;
              final progress = (limit > 0) ? (spent / limit).clamp(0.0, 1.0) : 0.0;
              final isOverBudget = spent > limit;
              final progressColor = _getProgressColor(progress, isOverBudget);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Category Icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icons area
                      categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            // Case: "Global Budget" - All Categories
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: palette.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.all_inclusive,
                                color: palette.secondary,
                                size: 24,
                              ),
                            );
                          }

                          // Case: Specific Categories (use Wrap for multiple icons)
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: categories.map((category) {
                                final itemColor = Color(category.colorValue);
                                return Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: itemColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    IconData(
                                      category.iconCodePoint,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: itemColor,
                                    size: 18,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, _) => const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: palette.textDark,
                              ),
                            ),
                            Text(
                              budget.period == BudgetPeriod.weekly
                                  ? 'Weekly Budget'
                                  : 'Monthly Budget',
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Percentage indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: palette.bgTerciary,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Numbers Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spent',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${spent.toStringAsFixed(2)}€',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Limit',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${limit.toStringAsFixed(2)}€',
                            style: TextStyle(
                              color: palette.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Remaining/Over budget indicator
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isOverBudget ? Colors.red : palette.green),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverBudget ? Icons.warning_amber : Icons.check_circle,
                          size: 16,
                          color: isOverBudget ? Colors.red : palette.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOverBudget
                              ? '${(remaining.abs()).toStringAsFixed(2)}€ over budget'
                              : '${remaining.toStringAsFixed(2)}€ remaining',
                          style: TextStyle(
                            color: isOverBudget ? Colors.red : palette.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error loading data: $e',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}