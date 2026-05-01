// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cute Pet';

  @override
  String get homeGreeting => 'Hello, cute pet!';

  @override
  String get homeCheer => 'Cheer';

  @override
  String get homeMeetThePet => 'Meet the pet';

  @override
  String get petTitle => 'Pet';

  @override
  String get petActionIdle => 'Idle';

  @override
  String get petActionEat => 'Eat';

  @override
  String get petActionDrink => 'Drink';

  @override
  String get petActionWalk => 'Walk';

  @override
  String get petActionRun => 'Run';

  @override
  String get petActionSleep => 'Sleep';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonEmpty => 'Nothing here';

  @override
  String get commonLoading => 'Loading';
}
