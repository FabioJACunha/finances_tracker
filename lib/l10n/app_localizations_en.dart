// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get language => 'Language';

  @override
  String get preferences => 'Preferences';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get accountAddTitle => 'Add Account';

  @override
  String get accountEditTitle => 'Edit Account';

  @override
  String get accountFieldTitleError => 'Enter a title';

  @override
  String get accountInitialBalance => 'Initial Balance';

  @override
  String get accountInitialBalanceError => 'Enter a valid number';

  @override
  String get accountInitialBalanceHelper => 'Balance can only be changed through transactions after creation';

  @override
  String get accountCurrentBalance => 'Current Balance';

  @override
  String get accountChangeBalanceInfo => 'Use transactions to change balance';

  @override
  String get accountExcludeFromTotal => 'Exclude from total balance';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String totalBalance(Object amount) {
    return 'Total Balance: $amount €';
  }

  @override
  String balanceLabel(Object amount) {
    return 'Balance: $amount €';
  }

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get createBudget => 'Create Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get loadingBudget => 'Loading budget...';

  @override
  String errorLoadCategories(Object error) {
    return 'Failed to load categories: $error';
  }

  @override
  String errorSaveBudget(Object error) {
    return 'Failed to save budget: $error';
  }

  @override
  String errorDeleteBudget(Object error) {
    return 'Failed to delete budget: $error';
  }

  @override
  String errorLoadAccounts(Object error) {
    return 'Error loading accounts: $error';
  }

  @override
  String get budgetCreated => 'Budget created';

  @override
  String get budgetUpdated => 'Budget updated';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get deleteBudgetTitle => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation => 'Are you sure you want to delete this budget? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get actionSaveChanges => 'Save Changes';

  @override
  String get actionCreateBudget => 'Create Budget';

  @override
  String get validationEnterTitle => 'Enter a title';

  @override
  String get budgetLimitLabel => 'Limit Amount';

  @override
  String get validationEnterLimit => 'Enter a limit';

  @override
  String get validationValidNumber => 'Enter a valid number';

  @override
  String get validationLimitMustBePositive => 'Limit must be greater than 0';

  @override
  String get accountLabel => 'Account';

  @override
  String get infoNoAccountsAvailable => 'No accounts available. Create an account first.';

  @override
  String get budgetPeriodLabel => 'Period';

  @override
  String get budgetPeriodWeekly => 'Weekly';

  @override
  String get budgetPeriodMonthly => 'Monthly';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get categoryGlobal => 'Global';

  @override
  String get infoNoCategoriesAvailable => 'No categories available. Create a category first.';

  @override
  String get validationSelectOneCategory => 'Please select at least one category';

  @override
  String get infoGlobalBudgetApplies => 'Global budget applies to all categories';

  @override
  String infoCategoriesSelected(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString categories selected',
      one: '1 category selected',
    );
    return '$_temp0';
  }

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsEmptyTitle => 'No budgets yet';

  @override
  String get budgetsEmptySubtitle => 'Tap + to create your first budget';

  @override
  String get budgetSpentLabel => 'Spent';

  @override
  String errorLoadingBudgets(Object error) {
    return 'Error: $error';
  }

  @override
  String errorLoadingBudgetData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String budgetOver(Object amount) {
    return '$amount€ over budget';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount€ remaining';
  }

  @override
  String get createCategoryTitle => 'Create Category';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get categoryUpdatedSuccess => 'Category updated successfully';

  @override
  String get categoryCreatedSuccess => 'Category added successfully';

  @override
  String categoryDeletedSuccess(Object categoryName) {
    return 'Category \"$categoryName\" deleted successfully';
  }

  @override
  String errorGeneral(Object error) {
    return 'Error: $error';
  }

  @override
  String get categoryDeleteTitle => 'Delete Category';

  @override
  String categoryDeleteConfirmation(Object categoryName) {
    return 'Are you sure you want to delete \'$categoryName\'? This action cannot be undone if the category has no transactions.';
  }

  @override
  String get actionAddCategory => 'Add Category';

  @override
  String get actionChange => 'Change';

  @override
  String get categoryIconLabel => 'Icon';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get selectIconTitle => 'Select Icon';

  @override
  String get selectColorTitle => 'Select Color';

  @override
  String get categoryUsageTypeTitle => 'Usage Type';

  @override
  String get usageTypeExpenseLabel => 'Expenses Only';

  @override
  String get usageTypeExpenseDesc => 'Can only be used for expense transactions';

  @override
  String get usageTypeIncomeLabel => 'Income Only';

  @override
  String get usageTypeIncomeDesc => 'Can only be used for income transactions';

  @override
  String get usageTypeBothLabel => 'Both';

  @override
  String get usageTypeBothDesc => 'Can be used for both income and expenses';

  @override
  String get categoryGroupEssentials => 'Essentials & Household';

  @override
  String get categoryGroupFood => 'Food & Drinks';

  @override
  String get categoryGroupTransport => 'Transport';

  @override
  String get categoryGroupUtilities => 'Utilities & Bills';

  @override
  String get categoryGroupHealth => 'Health & Personal';

  @override
  String get categoryGroupFinance => 'Finance & Work';

  @override
  String get categoryGroupEntertainment => 'Entertainment & Lifestyle';

  @override
  String get categoryGroupShopping => 'Shopping & Gifts';

  @override
  String get categoryGroupTravel => 'Travel & Experiences';

  @override
  String get categoryGroupFamily => 'Family & Kids';

  @override
  String get categoryGroupEducation => 'Education & Learning';

  @override
  String get categoryGroupTech => 'Tech & Subscriptions';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesEmptySubtitle => 'Tap + to add your first category';

  @override
  String errorLoadingCategories(Object error) {
    return 'Error loading categories: $error';
  }

  @override
  String get chartBalanceEvolutionTitle => 'Balance Evolution';

  @override
  String get chartNoTransactionsMessage => 'No transactions in this period';

  @override
  String errorLoadingData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String get chartExpensesByCategoryTitle => 'Expenses by category';

  @override
  String get chartNoExpensesMessage => 'No expenses in this period';

  @override
  String get chartIncomeVsExpenseTitle => 'Income vs Expense';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get netLabel => 'Net';

  @override
  String get cardNetBalanceChangeTitle => 'Net Balance Change';

  @override
  String get surplusLabel => 'Surplus';

  @override
  String get deficitLabel => 'Deficit';

  @override
  String get cardSavingsRateTitle => 'Savings Rate';

  @override
  String get savingsRatingExcellent => 'Excellent';

  @override
  String get savingsRatingGood => 'Good';

  @override
  String get savingsRatingFair => 'Fair';

  @override
  String get savingsRatingLow => 'Low';

  @override
  String get savingsRatingNone => 'None';

  @override
  String get savingsDescriptionExcellent => 'You\'re saving a great portion of your income!';

  @override
  String get savingsDescriptionGood => 'Healthy savings rate, keep it up!';

  @override
  String get savingsDescriptionFair => 'Consider increasing your savings goal.';

  @override
  String get savingsDescriptionLow => 'Try to save more of your income.';

  @override
  String get savingsDescriptionNone => 'No savings in this period. Income equals or is less than expenses.';

  @override
  String get chartSpendingTrendTitle => 'Spending Trend';

  @override
  String get allCategoriesLabel => 'Global';

  @override
  String get filterByCategoryLabel => 'Filter by Category';

  @override
  String get periodPrevious => 'Previous';

  @override
  String get periodCurrent => 'Current';

  @override
  String errorLoadingPreviousPeriod(Object error) {
    return 'Error loading previous period: $error';
  }

  @override
  String errorLoadingCurrentPeriod(Object error) {
    return 'Error loading current period: $error';
  }

  @override
  String get cardTopExpenseCategoriesTitle => 'Top Expense Categories';

  @override
  String get noExpensesInPeriod => 'No expenses in this period';

  @override
  String errorLoadingCategoryIcons(Object error) {
    return 'Error loading category icons: $error';
  }

  @override
  String get noAccountsYet => 'No accounts yet';

  @override
  String get periodTabWeek => 'Week';

  @override
  String get periodTabMonth => 'Month';

  @override
  String get periodTabYear => 'Year';

  @override
  String get periodTabCustom => 'Period';

  @override
  String get transactionDetailsTitle => 'Transaction Details';

  @override
  String get noTitle => 'No title';

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String get deleteTransactionConfirmation => 'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get transactionDeletedSuccess => 'Transaction deleted successfully';

  @override
  String errorDeletingTransaction(Object error) {
    return 'Error deleting transaction: $error';
  }

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldAccount => 'Account';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get validationInvalidNumber => 'Enter a valid number';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonSaveChanges => 'Save Changes';

  @override
  String get buttonAddTransaction => 'Add Transaction';

  @override
  String get transactionUpdatedSuccess => 'Transaction updated successfully';

  @override
  String get transactionAddedSuccess => 'Transaction added successfully';

  @override
  String errorLoadingAccounts(Object error) {
    return 'Error loading accounts: $error';
  }

  @override
  String get screenTransactionsTitle => 'Transactions';

  @override
  String get filterAll => 'All';

  @override
  String get noTransactions => 'No transactions in this period';

  @override
  String get errorNoAccountForTransaction => 'Please add an account before creating a transaction.';

  @override
  String get buttonAddNew => 'Add New';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAbout => 'About';

  @override
  String fieldEnter(Object field) {
    return 'Enter the $field';
  }

  @override
  String get paletteSoftBlue => 'Soft Blue';

  @override
  String get paletteGentlePurple => 'Gentle Purple';

  @override
  String get paletteGentleBrown => 'Gentle Brown';

  @override
  String get paletteMushroomIvory => 'Mushroom Ivory';

  @override
  String get paletteGentlePeach => 'Gentle Peach';
}
