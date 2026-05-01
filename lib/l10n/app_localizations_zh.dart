// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Cute Pet';

  @override
  String get homeGreeting => '你好,可爱的小宠物!';

  @override
  String get homeCheer => '鼓励一下';

  @override
  String get homeMeetThePet => '去看宠物';

  @override
  String get petTitle => '宠物';

  @override
  String get petActionIdle => '发呆';

  @override
  String get petActionEat => '吃饭';

  @override
  String get petActionDrink => '喝水';

  @override
  String get petActionWalk => '散步';

  @override
  String get petActionRun => '奔跑';

  @override
  String get petActionSleep => '睡觉';

  @override
  String get commonRetry => '重试';

  @override
  String get commonEmpty => '什么都没有';

  @override
  String get commonLoading => '加载中';
}
