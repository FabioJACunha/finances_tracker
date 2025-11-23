import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../data/db/tables.dart';
import 'package:intl/intl.dart';
import 'transaction_form_screen.dart';
import 'transaction_details_dialog.dart';
import '../../helpers/app_colors.dart';
import '../../models/transaction_type_filter.dart';
import 'package:collection/collection.dart'; // Add this if not present

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
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.terciary
                              : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            account.name,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.textDark,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                        builder: (context) {
                          return txnStream.when(
                            data: (transactions) {
                              final filteredTxns = transactions.where((data) {
                                switch (_currentFilter) {
                                  case TransactionTypeFilter.all:
                                    return true;
                                  case TransactionTypeFilter.expense:
                                    return data.transaction.type ==
                                        TransactionType.expense;
                                  case TransactionTypeFilter.income:
                                    return data.transaction.type ==
                                        TransactionType.income;
                                }
                              }).toList();

                              if (filteredTxns.isEmpty) {
                                return const Center(
                                  child: Text("No transactions"),
                                );
                              }

                              final groupedByDate = filteredTxns.groupListsBy(
                                (tx) => DateTime(
                                  tx.transaction.date.year,
                                  tx.transaction.date.month,
                                  tx.transaction.date.day,
                                ),
                              );

                              // Flatten the grouped map into a single list of items
                              // where each date is followed by its transactions.
                              final List<dynamic> listItems = [];
                              groupedByDate.keys
                                  .toList()
                                  .sorted(
                                    (a, b) =>
                                        b.compareTo(a), // Sort dates descending
                                  )
                                  .forEach((date) {
                                    listItems.add(
                                      date,
                                    ); // Add the date as a header item
                                    listItems.addAll(
                                      groupedByDate[date]!,
                                    ); // Add the transactions for that date
                                  });

                              return ListView.builder(
                                key: ValueKey<String>(filter),
                                itemCount: listItems.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final item = listItems[index];

                                  // Check if the item is a DateTime (our date header)
                                  if (item is DateTime) {
                                    final date = item;
                                    final formattedDate = DateFormat.yMMMd()
                                        .format(date);

                                    return Container(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      margin: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.textMuted,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }

                                  // Otherwise, the item is a transaction
                                  final tx = item.transaction;
                                  final isIncome =
                                      tx.type == TransactionType.income;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              TransactionDetailsDialog(
                                                data: item,
                                              ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        color: isIncome
                                            ? AppColors.bgGreen
                                            : AppColors.bgRed,
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
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
                                                child: Text(
                                                  tx.title ?? 'No title',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    '${tx.amount.toStringAsFixed(2)} €',
                                                    style: TextStyle(
                                                      color: isIncome
                                                          ? AppColors.green
                                                          : AppColors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${tx.resultantBalance.toStringAsFixed(2)} €',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.textMuted,
                                                      fontSize: 12
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
        foregroundColor: AppColors.textDark,
        onPressed: () {
          final accountsAsync = ref.read(accountsListProvider);
          final accounts = accountsAsync.asData?.value;
          if (accounts == null || accounts.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionFormScreen(initialAccountId: _selectedAccountId!),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
