// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get monday => '一';

  @override
  String get tuesday => '二';

  @override
  String get wednesday => '三';

  @override
  String get thursday => '四';

  @override
  String get friday => '五';

  @override
  String get saturday => '六';

  @override
  String get sunday => '日';

  @override
  String get monthYearFormat => 'yyyy年M月';
}
