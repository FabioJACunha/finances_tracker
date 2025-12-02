import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @accountAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddTitle;

  /// No description provided for @accountEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get accountEditTitle;

  /// No description provided for @accountFieldTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get accountFieldTitleError;

  /// No description provided for @accountInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get accountInitialBalance;

  /// No description provided for @accountInitialBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get accountInitialBalanceError;

  /// No description provided for @accountInitialBalanceHelper.
  ///
  /// In en, this message translates to:
  /// **'Balance can only be changed through transactions after creation'**
  String get accountInitialBalanceHelper;

  /// No description provided for @accountCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get accountCurrentBalance;

  /// No description provided for @accountChangeBalanceInfo.
  ///
  /// In en, this message translates to:
  /// **'Use transactions to change balance'**
  String get accountChangeBalanceInfo;

  /// No description provided for @accountExcludeFromTotal.
  ///
  /// In en, this message translates to:
  /// **'Exclude from total balance'**
  String get accountExcludeFromTotal;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance: {amount} €'**
  String totalBalance(Object amount);

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount} €'**
  String balanceLabel(Object amount);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(Object error);

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @loadingBudget.
  ///
  /// In en, this message translates to:
  /// **'Loading budget...'**
  String get loadingBudget;

  /// No description provided for @errorLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String errorLoadCategories(Object error);

  /// No description provided for @errorSaveBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to save budget: {error}'**
  String errorSaveBudget(Object error);

  /// No description provided for @errorDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete budget: {error}'**
  String errorDeleteBudget(Object error);

  /// No description provided for @errorLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts: {error}'**
  String errorLoadAccounts(Object error);

  /// No description provided for @budgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created'**
  String get budgetCreated;

  /// No description provided for @budgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated'**
  String get budgetUpdated;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget? This action cannot be undone.'**
  String get deleteBudgetConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get actionSaveChanges;

  /// No description provided for @actionCreateBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get actionCreateBudget;

  /// No description provided for @validationEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get validationEnterTitle;

  /// No description provided for @budgetLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit Amount'**
  String get budgetLimitLabel;

  /// No description provided for @validationEnterLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter a limit'**
  String get validationEnterLimit;

  /// No description provided for @validationValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validationValidNumber;

  /// No description provided for @validationLimitMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Limit must be greater than 0'**
  String get validationLimitMustBePositive;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @infoNoAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No accounts available. Create an account first.'**
  String get infoNoAccountsAvailable;

  /// No description provided for @budgetPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get budgetPeriodLabel;

  /// No description provided for @budgetPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get budgetPeriodWeekly;

  /// No description provided for @budgetPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get budgetPeriodMonthly;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @categoryGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get categoryGlobal;

  /// No description provided for @infoNoCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available. Create a category first.'**
  String get infoNoCategoriesAvailable;

  /// No description provided for @validationSelectOneCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category'**
  String get validationSelectOneCategory;

  /// No description provided for @infoGlobalBudgetApplies.
  ///
  /// In en, this message translates to:
  /// **'Global budget applies to all categories'**
  String get infoGlobalBudgetApplies;

  /// No description provided for @infoCategoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 category selected} other{{count} categories selected}}'**
  String infoCategoriesSelected(int count);

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetsEmptyTitle;

  /// No description provided for @budgetsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first budget'**
  String get budgetsEmptySubtitle;

  /// No description provided for @budgetSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpentLabel;

  /// No description provided for @errorLoadingBudgets.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLoadingBudgets(Object error);

  /// No description provided for @errorLoadingBudgetData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingBudgetData(Object error);

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount}€ over budget'**
  String budgetOver(Object amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount}€ remaining'**
  String budgetRemaining(Object amount);

  /// No description provided for @createCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitle;

  /// No description provided for @categoryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccess;

  /// No description provided for @categoryCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryCreatedSuccess;

  /// No description provided for @categoryDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category \"{categoryName}\" deleted successfully'**
  String categoryDeletedSuccess(Object categoryName);

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneral(Object error);

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{categoryName}\'? This action cannot be undone if the category has no transactions.'**
  String categoryDeleteConfirmation(Object categoryName);

  /// No description provided for @actionAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get actionAddCategory;

  /// No description provided for @actionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// No description provided for @categoryIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIconLabel;

  /// No description provided for @categoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColorLabel;

  /// No description provided for @selectIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIconTitle;

  /// No description provided for @selectColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColorTitle;

  /// No description provided for @categoryUsageTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Type'**
  String get categoryUsageTypeTitle;

  /// No description provided for @usageTypeExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses Only'**
  String get usageTypeExpenseLabel;

  /// No description provided for @usageTypeExpenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Can only be used for expense transactions'**
  String get usageTypeExpenseDesc;

  /// No description provided for @usageTypeIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income Only'**
  String get usageTypeIncomeLabel;

  /// No description provided for @usageTypeIncomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Can only be used for income transactions'**
  String get usageTypeIncomeDesc;

  /// No description provided for @usageTypeBothLabel.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get usageTypeBothLabel;

  /// No description provided for @usageTypeBothDesc.
  ///
  /// In en, this message translates to:
  /// **'Can be used for both income and expenses'**
  String get usageTypeBothDesc;

  /// No description provided for @categoryGroupEssentials.
  ///
  /// In en, this message translates to:
  /// **'Essentials & Household'**
  String get categoryGroupEssentials;

  /// No description provided for @categoryGroupFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get categoryGroupFood;

  /// No description provided for @categoryGroupTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryGroupTransport;

  /// No description provided for @categoryGroupUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities & Bills'**
  String get categoryGroupUtilities;

  /// No description provided for @categoryGroupHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & Personal'**
  String get categoryGroupHealth;

  /// No description provided for @categoryGroupFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance & Work'**
  String get categoryGroupFinance;

  /// No description provided for @categoryGroupEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment & Lifestyle'**
  String get categoryGroupEntertainment;

  /// No description provided for @categoryGroupShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping & Gifts'**
  String get categoryGroupShopping;

  /// No description provided for @categoryGroupTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & Experiences'**
  String get categoryGroupTravel;

  /// No description provided for @categoryGroupFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & Kids'**
  String get categoryGroupFamily;

  /// No description provided for @categoryGroupEducation.
  ///
  /// In en, this message translates to:
  /// **'Education & Learning'**
  String get categoryGroupEducation;

  /// No description provided for @categoryGroupTech.
  ///
  /// In en, this message translates to:
  /// **'Tech & Subscriptions'**
  String get categoryGroupTech;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first category'**
  String get categoriesEmptySubtitle;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories: {error}'**
  String errorLoadingCategories(Object error);

  /// No description provided for @chartBalanceEvolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance Evolution'**
  String get chartBalanceEvolutionTitle;

  /// No description provided for @chartNoTransactionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get chartNoTransactionsMessage;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @chartExpensesByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get chartExpensesByCategoryTitle;

  /// No description provided for @chartNoExpensesMessage.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get chartNoExpensesMessage;

  /// No description provided for @chartIncomeVsExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get chartIncomeVsExpenseTitle;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @cardNetBalanceChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Net Balance Change'**
  String get cardNetBalanceChangeTitle;

  /// No description provided for @surplusLabel.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get surplusLabel;

  /// No description provided for @deficitLabel.
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get deficitLabel;

  /// No description provided for @cardSavingsRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get cardSavingsRateTitle;

  /// No description provided for @savingsRatingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get savingsRatingExcellent;

  /// No description provided for @savingsRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get savingsRatingGood;

  /// No description provided for @savingsRatingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get savingsRatingFair;

  /// No description provided for @savingsRatingLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get savingsRatingLow;

  /// No description provided for @savingsRatingNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get savingsRatingNone;

  /// No description provided for @savingsDescriptionExcellent.
  ///
  /// In en, this message translates to:
  /// **'You\'re saving a great portion of your income!'**
  String get savingsDescriptionExcellent;

  /// No description provided for @savingsDescriptionGood.
  ///
  /// In en, this message translates to:
  /// **'Healthy savings rate, keep it up!'**
  String get savingsDescriptionGood;

  /// No description provided for @savingsDescriptionFair.
  ///
  /// In en, this message translates to:
  /// **'Consider increasing your savings goal.'**
  String get savingsDescriptionFair;

  /// No description provided for @savingsDescriptionLow.
  ///
  /// In en, this message translates to:
  /// **'Try to save more of your income.'**
  String get savingsDescriptionLow;

  /// No description provided for @savingsDescriptionNone.
  ///
  /// In en, this message translates to:
  /// **'No savings in this period. Income equals or is less than expenses.'**
  String get savingsDescriptionNone;

  /// No description provided for @chartSpendingTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get chartSpendingTrendTitle;

  /// No description provided for @allCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get allCategoriesLabel;

  /// No description provided for @filterByCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategoryLabel;

  /// No description provided for @periodPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get periodPrevious;

  /// No description provided for @periodCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get periodCurrent;

  /// No description provided for @errorLoadingPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Error loading previous period: {error}'**
  String errorLoadingPreviousPeriod(Object error);

  /// No description provided for @errorLoadingCurrentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Error loading current period: {error}'**
  String errorLoadingCurrentPeriod(Object error);

  /// No description provided for @cardTopExpenseCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Expense Categories'**
  String get cardTopExpenseCategoriesTitle;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesInPeriod;

  /// No description provided for @errorLoadingCategoryIcons.
  ///
  /// In en, this message translates to:
  /// **'Error loading category icons: {error}'**
  String errorLoadingCategoryIcons(Object error);

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsYet;

  /// No description provided for @periodTabWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodTabWeek;

  /// No description provided for @periodTabMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodTabMonth;

  /// No description provided for @periodTabYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodTabYear;

  /// No description provided for @periodTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodTabCustom;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetailsTitle;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get deleteTransactionConfirmation;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @transactionDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccess;

  /// No description provided for @errorDeletingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error deleting transaction: {error}'**
  String errorDeletingTransaction(Object error);

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get fieldAccount;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validationInvalidNumber;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get buttonSaveChanges;

  /// No description provided for @buttonAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get buttonAddTransaction;

  /// No description provided for @transactionUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdatedSuccess;

  /// No description provided for @transactionAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAddedSuccess;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts: {error}'**
  String errorLoadingAccounts(Object error);

  /// No description provided for @screenTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get screenTransactionsTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get noTransactions;

  /// No description provided for @errorNoAccountForTransaction.
  ///
  /// In en, this message translates to:
  /// **'Please add an account before creating a transaction.'**
  String get errorNoAccountForTransaction;

  /// No description provided for @buttonAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get buttonAddNew;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsAccounts;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @fieldEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter the {field}'**
  String fieldEnter(Object field);

  /// No description provided for @paletteSoftBlue.
  ///
  /// In en, this message translates to:
  /// **'Soft Blue'**
  String get paletteSoftBlue;

  /// No description provided for @paletteGentlePurple.
  ///
  /// In en, this message translates to:
  /// **'Gentle Purple'**
  String get paletteGentlePurple;

  /// No description provided for @paletteGentleBrown.
  ///
  /// In en, this message translates to:
  /// **'Gentle Brown'**
  String get paletteGentleBrown;

  /// No description provided for @paletteMushroomIvory.
  ///
  /// In en, this message translates to:
  /// **'Mushroom Ivory'**
  String get paletteMushroomIvory;

  /// No description provided for @paletteGentlePeach.
  ///
  /// In en, this message translates to:
  /// **'Gentle Peach'**
  String get paletteGentlePeach;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
