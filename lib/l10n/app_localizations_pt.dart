// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get helloWorld => 'Olá Mundo!';

  @override
  String get navHome => 'Início';

  @override
  String get navTransactions => 'Transações';

  @override
  String get navAccounts => 'Contas';

  @override
  String get navBudgets => 'Limites';

  @override
  String get language => 'Idioma';

  @override
  String get preferences => 'Preferências';

  @override
  String get colorTheme => 'Esquema de cores';

  @override
  String get accountAddTitle => 'Adicionar Conta';

  @override
  String get accountEditTitle => 'Editar Conta';

  @override
  String get accountFieldTitleError => 'Insira um título';

  @override
  String get accountInitialBalance => 'Saldo inicial';

  @override
  String get accountInitialBalanceError => 'Insira um número válido';

  @override
  String get accountInitialBalanceHelper => 'O saldo só pode ser alterado através de transações após a criação';

  @override
  String get accountCurrentBalance => 'Saldo atual';

  @override
  String get accountChangeBalanceInfo => 'Use transações para alterar o saldo';

  @override
  String get accountExcludeFromTotal => 'Excluir do saldo total';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get accountsTitle => 'Contas';

  @override
  String totalBalance(Object amount) {
    return 'Saldo total: $amount €';
  }

  @override
  String balanceLabel(Object amount) {
    return 'Saldo: $amount €';
  }

  @override
  String errorMessage(Object error) {
    return 'Erro: $error';
  }

  @override
  String get createBudget => 'Criar limite';

  @override
  String get editBudget => 'Editar limite';

  @override
  String get loadingBudget => 'A carregar limite...';

  @override
  String errorLoadCategories(Object error) {
    return 'Falha ao carregar categorias: $error';
  }

  @override
  String errorSaveBudget(Object error) {
    return 'Falha ao guardar limite: $error';
  }

  @override
  String errorDeleteBudget(Object error) {
    return 'Falha ao apagar limite: $error';
  }

  @override
  String errorLoadAccounts(Object error) {
    return 'Erro ao carregar contas: $error';
  }

  @override
  String get budgetCreated => 'Limite criado';

  @override
  String get budgetUpdated => 'Limite atualizado';

  @override
  String get budgetDeleted => 'Limite apagado';

  @override
  String get deleteBudgetTitle => 'Apagar limite';

  @override
  String get deleteBudgetConfirmation => 'Tem certeza de que deseja apagar este limite? Esta ação não pode ser desfeita.';

  @override
  String get delete => 'Eliminar';

  @override
  String get actionSaveChanges => 'Guardar Alterações';

  @override
  String get actionCreateBudget => 'Criar limite';

  @override
  String get validationEnterTitle => 'Introduza um título';

  @override
  String get budgetLimitLabel => 'Valor Limite';

  @override
  String get validationEnterLimit => 'Introduza um limite';

  @override
  String get validationValidNumber => 'Introduza um número válido';

  @override
  String get validationLimitMustBePositive => 'O limite deve ser maior que 0';

  @override
  String get accountLabel => 'Conta';

  @override
  String get infoNoAccountsAvailable => 'Nenhuma conta disponível. Crie uma conta primeiro.';

  @override
  String get budgetPeriodLabel => 'Período';

  @override
  String get budgetPeriodWeekly => 'Semanal';

  @override
  String get budgetPeriodMonthly => 'Mensal';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get categoryGlobal => 'Global';

  @override
  String get infoNoCategoriesAvailable => 'Nenhuma categoria disponível. Crie uma categoria primeiro.';

  @override
  String get validationSelectOneCategory => 'Selecione pelo menos uma categoria';

  @override
  String get infoGlobalBudgetApplies => 'O limite global aplica-se a todas as categorias';

  @override
  String infoCategoriesSelected(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString categorias selecionadas',
      one: '1 categoria selecionada',
    );
    return '$_temp0';
  }

  @override
  String get budgetsTitle => 'Limites';

  @override
  String get budgetsEmptyTitle => 'Ainda não há limites';

  @override
  String get budgetsEmptySubtitle => 'Toque em + para criar o seu primeiro limite';

  @override
  String get budgetSpentLabel => 'Gasto';

  @override
  String errorLoadingBudgets(Object error) {
    return 'Erro: $error';
  }

  @override
  String errorLoadingBudgetData(Object error) {
    return 'Erro ao carregar dados: $error';
  }

  @override
  String budgetOver(Object amount) {
    return '$amount€ acima do limite';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount€ restantes';
  }

  @override
  String get createCategoryTitle => 'Criar Categoria';

  @override
  String get editCategoryTitle => 'Editar Categoria';

  @override
  String get categoryUpdatedSuccess => 'Categoria atualizada com sucesso';

  @override
  String get categoryCreatedSuccess => 'Categoria adicionada com sucesso';

  @override
  String categoryDeletedSuccess(Object categoryName) {
    return 'Categoria \"$categoryName\" apagada com sucesso';
  }

  @override
  String errorGeneral(Object error) {
    return 'Erro: $error';
  }

  @override
  String get categoryDeleteTitle => 'Apagar Categoria';

  @override
  String categoryDeleteConfirmation(Object categoryName) {
    return 'Tem certeza de que deseja apagar \'$categoryName\'? Esta ação não pode ser desfeita se a categoria tiver transações.';
  }

  @override
  String get actionAddCategory => 'Adicionar Categoria';

  @override
  String get actionChange => 'Alterar';

  @override
  String get categoryIconLabel => 'Ícone';

  @override
  String get categoryColorLabel => 'Cor';

  @override
  String get selectIconTitle => 'Selecionar Ícone';

  @override
  String get selectColorTitle => 'Selecionar Cor';

  @override
  String get categoryUsageTypeTitle => 'Tipo de Uso';

  @override
  String get usageTypeExpenseLabel => 'Apenas Despesas';

  @override
  String get usageTypeExpenseDesc => 'Só pode ser usado para transações de despesa';

  @override
  String get usageTypeIncomeLabel => 'Apenas Rendimentos';

  @override
  String get usageTypeIncomeDesc => 'Só pode ser usado para transações de rendimento';

  @override
  String get usageTypeBothLabel => 'Ambos';

  @override
  String get usageTypeBothDesc => 'Pode ser usado tanto para rendimentos como para despesas';

  @override
  String get categoryGroupEssentials => 'Essenciais e Doméstico';

  @override
  String get categoryGroupFood => 'Comida e Bebidas';

  @override
  String get categoryGroupTransport => 'Transporte';

  @override
  String get categoryGroupUtilities => 'Serviços e Contas';

  @override
  String get categoryGroupHealth => 'Saúde e Pessoal';

  @override
  String get categoryGroupFinance => 'Finanças e Trabalho';

  @override
  String get categoryGroupEntertainment => 'Entretenimento e Estilo de Vida';

  @override
  String get categoryGroupShopping => 'Compras e Presentes';

  @override
  String get categoryGroupTravel => 'Viagens e Experiências';

  @override
  String get categoryGroupFamily => 'Família e Crianças';

  @override
  String get categoryGroupEducation => 'Educação e Aprendizagem';

  @override
  String get categoryGroupTech => 'Tecnologia e Subscrições';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get categoriesEmptyTitle => 'Ainda não há categorias';

  @override
  String get categoriesEmptySubtitle => 'Toque em + para adicionar a sua primeira categoria';

  @override
  String errorLoadingCategories(Object error) {
    return 'Erro ao carregar categorias: $error';
  }

  @override
  String get chartBalanceEvolutionTitle => 'Evolução do Saldo';

  @override
  String get chartNoTransactionsMessage => 'Sem transações neste período';

  @override
  String errorLoadingData(Object error) {
    return 'Erro ao carregar dados: $error';
  }

  @override
  String get chartExpensesByCategoryTitle => 'Despesas por categoria';

  @override
  String get chartNoExpensesMessage => 'Sem despesas neste período';

  @override
  String get chartIncomeVsExpenseTitle => 'Rendimentos vs Despesas';

  @override
  String get incomeLabel => 'Rendimento';

  @override
  String get expenseLabel => 'Despesa';

  @override
  String get netLabel => 'Líquido';

  @override
  String get cardNetBalanceChangeTitle => 'Variação do Saldo Líquido';

  @override
  String get surplusLabel => 'Excedente';

  @override
  String get deficitLabel => 'Défice';

  @override
  String get cardSavingsRateTitle => 'Taxa de Poupança';

  @override
  String get savingsRatingExcellent => 'Excelente';

  @override
  String get savingsRatingGood => 'Boa';

  @override
  String get savingsRatingFair => 'Razoável';

  @override
  String get savingsRatingLow => 'Baixa';

  @override
  String get savingsRatingNone => 'Nenhuma';

  @override
  String get savingsDescriptionExcellent => 'Está a poupar uma grande parte do seu rendimento!';

  @override
  String get savingsDescriptionGood => 'Taxa de poupança saudável, continue assim!';

  @override
  String get savingsDescriptionFair => 'Considere aumentar o seu objetivo de poupança.';

  @override
  String get savingsDescriptionLow => 'Tente poupar mais do seu rendimento.';

  @override
  String get savingsDescriptionNone => 'Sem poupança neste período. O rendimento é igual ou inferior às despesas.';

  @override
  String get chartSpendingTrendTitle => 'Tendência de Despesas';

  @override
  String get allCategoriesLabel => 'Global';

  @override
  String get filterByCategoryLabel => 'Filtrar por Categoria';

  @override
  String get periodPrevious => 'Anterior';

  @override
  String get periodCurrent => 'Atual';

  @override
  String errorLoadingPreviousPeriod(Object error) {
    return 'Erro ao carregar o período anterior: $error';
  }

  @override
  String errorLoadingCurrentPeriod(Object error) {
    return 'Erro ao carregar o período atual: $error';
  }

  @override
  String get cardTopExpenseCategoriesTitle => 'Principais Categorias de Despesas';

  @override
  String get noExpensesInPeriod => 'Nenhuma despesa neste período';

  @override
  String errorLoadingCategoryIcons(Object error) {
    return 'Erro ao carregar ícones de categoria: $error';
  }

  @override
  String get noAccountsYet => 'Ainda não tem contas';

  @override
  String get periodTabWeek => 'Semana';

  @override
  String get periodTabMonth => 'Mês';

  @override
  String get periodTabYear => 'Ano';

  @override
  String get periodTabCustom => 'Período';

  @override
  String get transactionDetailsTitle => 'Detalhes da Transação';

  @override
  String get noTitle => 'Sem título';

  @override
  String get deleteTransactionTitle => 'Eliminar Transação';

  @override
  String get deleteTransactionConfirmation => 'Tem certeza de que deseja eliminar esta transação? Esta ação não pode ser desfeita.';

  @override
  String get buttonEdit => 'Editar';

  @override
  String get transactionDeletedSuccess => 'Transação eliminada com sucesso';

  @override
  String errorDeletingTransaction(Object error) {
    return 'Erro ao eliminar transação: $error';
  }

  @override
  String get addTransactionTitle => 'Adicionar Transação';

  @override
  String get editTransactionTitle => 'Editar Transação';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldAccount => 'Conta';

  @override
  String get fieldType => 'Tipo';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get fieldDescription => 'Descrição';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldAmount => 'Valor';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get validationInvalidNumber => 'Insira um número válido';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonSaveChanges => 'Guardar Alterações';

  @override
  String get buttonAddTransaction => 'Adicionar Transação';

  @override
  String get transactionUpdatedSuccess => 'Transação atualizada com sucesso';

  @override
  String get transactionAddedSuccess => 'Transação adicionada com sucesso';

  @override
  String errorLoadingAccounts(Object error) {
    return 'Erro ao carregar contas: $error';
  }

  @override
  String get screenTransactionsTitle => 'Transações';

  @override
  String get filterAll => 'Todas';

  @override
  String get noTransactions => 'Nenhuma transação neste período';

  @override
  String get errorNoAccountForTransaction => 'Por favor, adicione uma conta antes de criar uma transação.';

  @override
  String get buttonAddNew => 'Criar nova';

  @override
  String get settingsCategories => 'Categorias';

  @override
  String get settingsAccounts => 'Contas';

  @override
  String get settingsPreferences => 'Preferências';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String fieldEnter(Object field) {
    return 'Insira o $field';
  }

  @override
  String get paletteSoftBlue => 'Azul Suave';

  @override
  String get paletteGentlePurple => 'Roxo Suave';

  @override
  String get paletteGentleBrown => 'Castanho Suave';

  @override
  String get paletteMushroomIvory => 'Marfim Cogumelo';

  @override
  String get paletteGentlePeach => 'Pêssego Suave';
}
