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
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt(): super('pt_PT');

  @override
  String get helloWorld => 'Olá Mundo!';

  @override
  String get navHome => 'Início';

  @override
  String get navTransactions => 'Transações';

  @override
  String get navAccounts => 'Contas';
}
