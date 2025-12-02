import '../../theme/app_colors.dart';
import '../../models/date_range_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../transactions/transaction_form_screen.dart';
import 'home_stats_widgets/home_stats_widgets.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/date_range_selector.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedAccountId;
  late final TabController _tabController;

  DateRangeSelection _selectedRange = DateRangeSelection.week();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed to 4 tabs

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedRange = DateRangeSelection.week();
              break;
            case 1:
              _selectedRange = DateRangeSelection.month();
              break;
            case 2:
              _selectedRange = DateRangeSelection.year();
              break;
            case 3:
              // Keep current custom range or default to last month
              if (_selectedRange.type != DateRangeType.custom) {
                _selectedRange = DateRangeSelection.month();
              }
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDateRangeChanged(DateRangeSelection newRange) {
    setState(() {
      _selectedRange = newRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsListProvider);
    final palette = currentPalette;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return Scaffold(body: Center(child: Text(loc.noAccountsYet)));
        }

        _selectedAccountId ??= accounts.first.id;

        return Scaffold(
          appBar: CustomAppBar(
            title: loc.navHome,
            leading: Icon(Icons.home_outlined, color: palette.textDark),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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

              const SizedBox(height: 8),

              /// Tabs: Week / Month / Year / Period ----------------------------------------
              TabBar(
                controller: _tabController,
                labelColor: palette.secondary,
                unselectedLabelColor: palette.textDark,
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: palette.secondary, width: 2),
                  ),
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  Tab(text: loc.periodTabWeek),
                  Tab(text: loc.periodTabMonth),
                  Tab(text: loc.periodTabYear),
                  Tab(text: loc.periodTabCustom),
                ],
              ),

              const SizedBox(height: 8),

              /// Custom date range picker (shown when Period tab is selected)
              if (_tabController.index == 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DateRangeSelector(
                    currentRange: _selectedRange,
                    onRangeChanged: _onDateRangeChanged,
                  ),
                ),

              if (_tabController.index == 3) const SizedBox(height: 8),

              /// Charts ------------------------------------------------------------
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    key: ValueKey(
                      '${_selectedRange.start}_${_selectedRange.end}',
                    ),
                    child: Column(
                      // Using a SizedBox instead of a specific widget like Column to provide spacing
                      children: [
                        ExpensesByCategoryPie(
                          accountId: _selectedAccountId!,
                          start: _selectedRange.start,
                          end: _selectedRange.end,
                        ),
                        const SizedBox(height: 10),
                        if (_selectedRange.type != DateRangeType.week)
                          IncomeVsExpenseBar(
                            accountId: _selectedAccountId!,
                            start: _selectedRange.start,
                            end: _selectedRange.end,
                          ),
                        const SizedBox(height: 10),
                        if (_selectedRange.type == DateRangeType.week)
                          NetBalanceChangeCard(
                            accountId: _selectedAccountId!,
                            start: _selectedRange.start,
                            end: _selectedRange.end,
                          ),
                        const SizedBox(height: 10),
                        if (_selectedRange.type != DateRangeType.week &&
                            _tabController.index != 3)
                          SavingsRateCard(
                            accountId: _selectedAccountId!,
                            start: _selectedRange.start,
                            end: _selectedRange.end,
                          ),
                        const SizedBox(height: 10),
                        TopExpenseCategories(
                          accountId: _selectedAccountId!,
                          start: _selectedRange.start,
                          end: _selectedRange.end,
                        ),
                        const SizedBox(height: 10),
                        if (_tabController.index != 3)
                          SpendingTrendChart(
                            accountId: _selectedAccountId!,
                            start: _selectedRange.start,
                            end: _selectedRange.end,
                          ),
                        const SizedBox(height: 10),
                        if (_selectedRange.type == DateRangeType.year)
                          BalanceEvolutionChart(
                            accountId: _selectedAccountId!,
                            start: _selectedRange.start,
                            end: _selectedRange.end,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: palette.primary,
            foregroundColor: palette.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionFormScreen(
                    initialAccountId: _selectedAccountId!,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: palette.secondary),
        ),
      ),
      error: (err, st) =>
          Scaffold(body: Center(child: Text(loc.errorGeneral(err.toString())))),
    );
  }
}
