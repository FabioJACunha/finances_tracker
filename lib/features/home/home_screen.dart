import '../../helpers/app_colors.dart';
import '../../models/date_period_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../transactions/transaction_form_screen.dart';
import 'home_stats_widgets/home_stats_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedAccountId;
  late final TabController _tabController;

  DatePeriodFilter _currentFilter = DatePeriodFilter.week;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentFilter = DatePeriodFilter.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTimeRange _getSelectedDateRange() {
    final now = DateTime.now();

    switch (_currentFilter) {
      case DatePeriodFilter.week:
        final weekday = now.weekday;
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekday - 1));
        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return DateTimeRange(start: start, end: end);

      case DatePeriodFilter.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case DatePeriodFilter.year:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return const Scaffold(body: Center(child: Text("No accounts yet")));
        }

        _selectedAccountId ??= accounts.first.id;
        final range = _getSelectedDateRange();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bgPrimary,
            scrolledUnderElevation: 0.0,
            // Prevents the color change when scrolled
            surfaceTintColor: Colors.transparent,
            // Prevents tinting on scroll
            title: const Text(
              "Home",
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
          body: Column(
            children: [
              /// Account pills ------------------------------------------------------
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
                      onTap: () => setState(() {
                        _selectedAccountId = account.id;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.terciary
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

              /// Tabs: Week / Month / Year ----------------------------------------
              TabBar(
                controller: _tabController,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.textDark,
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(text: "Week"),
                  Tab(text: "Month"),
                  Tab(text: "Year"),
                ],
              ),

              const SizedBox(height: 8),

              /// Charts ------------------------------------------------------------
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: SingleChildScrollView(
                    key: ValueKey(_currentFilter),
                    // <- important for switching!
                    child: Column(
                      spacing: 20,
                      children: [
                        ExpensesByCategoryPie(
                          accountId: _selectedAccountId!,
                          start: range.start,
                          end: range.end,
                        ),
                        if (_currentFilter != DatePeriodFilter.week)
                          IncomeVsExpenseBar(
                            accountId: _selectedAccountId!,
                            start: range.start,
                            end: range.end,
                          ),
                        if (_currentFilter == DatePeriodFilter.week)
                          NetBalanceChangeCard(
                            accountId: _selectedAccountId!,
                            start: range.start,
                            end: range.end,
                          ),
                        if (_currentFilter != DatePeriodFilter.week)
                          SavingsRateCard(
                            accountId: _selectedAccountId!,
                            start: range.start,
                            end: range.end,
                          ),
                        TopExpenseCategories(
                          accountId: _selectedAccountId!,
                          start: range.start,
                          end: range.end,
                        ),
                        SpendingTrendChart(
                          accountId: _selectedAccountId!,
                          start: range.start,
                          end: range.end,
                        ),
                        if (_currentFilter == DatePeriodFilter.year)
                          BalanceEvolutionChart(
                            accountId: _selectedAccountId!,
                            start: range.start,
                            end: range.end,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TransactionFormScreen(
                  initialAccountId: _selectedAccountId!,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
    );
  }
}
