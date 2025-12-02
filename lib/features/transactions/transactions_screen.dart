import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../data/db/tables.dart';
import '../../models/period_args.dart';
import '../../models/date_range_selection.dart';
import 'package:intl/intl.dart';
import 'transaction_form_screen.dart';
import 'transaction_details_dialog.dart';
import '../../theme/app_colors.dart';
import '../../models/transaction_type_filter.dart';
import 'package:collection/collection.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/date_range_selector.dart';
import '../../providers/categories_provider.dart';
import '../../l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedAccountId;
  late TabController _tabController;
  TransactionTypeFilter _currentFilter = TransactionTypeFilter.all;

  // Default to last 2 months
  late DateRangeSelection _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dateRange = DateRangeSelection.lastNMonths(2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDateRangeChanged(DateRangeSelection newRange) {
    setState(() {
      _dateRange = newRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsListProvider);
    final palette = currentPalette;

    return Scaffold(
      appBar: CustomAppBar(
        title: loc.screenTransactionsTitle,
        leading: Icon(Icons.history, color: palette.textDark),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(child: Text(loc.noAccountsYet));
          }
          _selectedAccountId ??= accounts.first.id;

          return Column(
            children: [
              // Horizontal scrollable account pills
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
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
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? palette.terciary
                                    : palette.bgTerciary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  account.name,
                                  style: TextStyle(
                                    color: selected
                                        ? palette.secondary
                                        : palette.textDark,
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
                  ),
                  // Date range picker
                  DateRangeSelector(
                    currentRange: _dateRange,
                    onRangeChanged: _onDateRangeChanged,
                    isIconOnly: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: palette.secondary,
                unselectedLabelColor: palette.textDark,
                dividerHeight: 0,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: palette.secondary, width: 2),
                  ),
                ),
                indicatorColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(text: loc.filterAll),
                  Tab(text: loc.expenseLabel),
                  Tab(text: loc.incomeLabel),
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
                    if (_selectedAccountId == null) {
                      return const SizedBox.shrink();
                    }

                    // Use the new provider with date range filtering
                    final txnStream = ref.watch(
                      transactionsWithCategoryInRangeProvider(
                        TransactionRangeArgs(
                          accountId: _selectedAccountId!,
                          start: _dateRange.start,
                          end: _dateRange.end,
                        ),
                      ),
                    );

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Builder(
                        key: ValueKey(
                          '${_currentFilter}_${_dateRange.start}_${_dateRange.end}',
                        ),
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
                                return Center(child: Text(loc.noTransactions));
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
                                key: ValueKey<String>(
                                  '${_currentFilter}_${_dateRange.start}',
                                ),
                                itemCount: listItems.length,
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 8,
                                  bottom: 80,
                                ),
                                itemBuilder: (context, index) {
                                  final item = listItems[index];

                                  // Check if the item is a DateTime (our date header)
                                  if (item is DateTime) {
                                    final date = item;
                                    // Use local specific date formatting
                                    final formattedDate = DateFormat.yMMMd(
                                      loc.localeName,
                                    ).format(date);

                                    return Container(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      margin: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: palette.textMuted,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: palette.textMuted,
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
                                  final categoryAsync = tx.categoryId == null
                                      ? null // Assign null if there's no ID, instead of 'Global'
                                      : ref.watch(
                                          categoryByIdProvider(tx.categoryId!),
                                        );
                                  String category = loc.categoryGlobal;
                                  if (categoryAsync != null &&
                                      categoryAsync.hasValue) {
                                    // Safely access the Category object's name property
                                    category = categoryAsync.value!.name;
                                  }
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
                                            ? palette.bgGreen
                                            : palette.bgRed,
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isIncome
                                                    ? Icons.south_west
                                                    : Icons.north_east,
                                                color: isIncome
                                                    ? palette.green
                                                    : palette.red,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tx.title ?? loc.noTitle,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: palette.textDark,
                                                      ),
                                                    ),
                                                    Text(
                                                      category,
                                                      style: TextStyle(
                                                        color:
                                                            palette.secondary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${tx.amount.toStringAsFixed(2)} €',
                                                    style: TextStyle(
                                                      color: isIncome
                                                          ? palette.green
                                                          : palette.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${tx.resultantBalance.toStringAsFixed(2)} €',
                                                    style: TextStyle(
                                                      color: palette.textMuted,
                                                      fontSize: 12,
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
                            error: (e, st) => Center(
                              child: Text(loc.errorGeneral(e.toString())),
                            ),
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
        error: (e, st) =>
            Center(child: Text(loc.errorLoadingAccounts(e.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: palette.primary,
        foregroundColor: palette.textDark,
        onPressed: () {
          final accountsAsync = ref.read(accountsListProvider);
          final accounts = accountsAsync.asData?.value;
          if (accounts == null || accounts.isEmpty) {
            // Show a snackbar/message if no accounts exist
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  loc.errorNoAccountForTransaction,
                  style: TextStyle(color: palette.red),
                ),
                backgroundColor: palette.bgRed,
              ),
            );
            return;
          }
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
