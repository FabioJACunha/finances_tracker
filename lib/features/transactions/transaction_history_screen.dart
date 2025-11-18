import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../data/db/tables.dart';
import 'package:intl/intl.dart';
import 'transaction_form_screen.dart';
import '../../helpers/app_colors.dart';
import '../../models/transaction_type_filter.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedAccountId;
  late TabController _tabController;
  TransactionTypeFilter _currentFilter = TransactionTypeFilter.all;

  @override
  void initState() {
    super.initState();
    // Initialize TabController here
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        scrolledUnderElevation: 0.0,  // Prevents the color change when scrolled
        surfaceTintColor: Colors.transparent, // Prevents tinting on scroll
        title: const Text(
          "Transaction History",
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text("No accounts yet"));
          }
          _selectedAccountId ??= accounts.first.id;

          return Column(
            children: [
              // Horizontal scrollable account pills
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final selected = account.id == _selectedAccountId;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedAccountId = account.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.bgTerciary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            account.name,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.textDark,
                dividerHeight: 0,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
                indicatorColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                ],
                onTap: (index) {
                  setState(() {
                    _currentFilter = TransactionTypeFilter.values[index];
                  });
                },
              ),

              const SizedBox(height: 8, width: double.infinity),

              // Transactions list
              Expanded(
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    final filter = [
                      'All',
                      'Expense',
                      'Income',
                    ][_tabController.index];

                    if (_selectedAccountId == null) {
                      return const SizedBox.shrink();
                    }

                    final txnStream = ref.watch(
                      transactionsWithCategoryProvider(_selectedAccountId!),
                    );

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Builder(
                        key: ValueKey(_currentFilter),
                        // important for AnimatedSwitcher
                        builder: (context) {
                          return txnStream.when(
                            data: (transactions) {
                              final filteredTxns = transactions.where((t) {
                                switch (_currentFilter) {
                                  case TransactionTypeFilter.all:
                                    return true;
                                  case TransactionTypeFilter.expense:
                                    return t.transaction.type ==
                                        TransactionType.expense;
                                  case TransactionTypeFilter.income:
                                    return t.transaction.type ==
                                        TransactionType.income;
                                }
                              }).toList();

                              if (filteredTxns.isEmpty) {
                                return const Center(
                                  child: Text("No transactions"),
                                );
                              }

                              return ListView.builder(
                                key: ValueKey<String>(filter),
                                itemCount: filteredTxns.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final data = filteredTxns[index];
                                  final tx = data.transaction;
                                  final categoryName =
                                      data.categoryName ?? 'Uncategorized';
                                  final formattedDate = DateFormat(
                                    'dd-MM-yyyy HH:mm',
                                  ).format(tx.date);

                                  final isIncome =
                                      tx.type == TransactionType.income;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    // vertical spacing between pills
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? AppColors.bgGreen
                                            : AppColors.bgRed,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isIncome
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            color: isIncome
                                                ? AppColors.green
                                                : AppColors.red,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tx.description ??
                                                      'No description',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.secondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '$categoryName • $formattedDate',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                            style: TextStyle(
                                              color: isIncome
                                                  ? AppColors.green
                                                  : AppColors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, st) => Center(child: Text("Error: $e")),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading accounts: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          final accountsAsync = ref.read(accountsListProvider);
          final accounts = accountsAsync.asData?.value;
          if (accounts == null || accounts.isEmpty) return;
          showDialog(
            context: context,
            builder: (_) =>
                TransactionFormScreen(initialAccountId: accounts.first.id),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
