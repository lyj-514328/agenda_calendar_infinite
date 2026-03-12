import 'package:flutter/widgets.dart';

import '../generated/app_localizations.dart';
import '../generated/app_localizations_en.dart';

/// 默认英文本地化实例，作为没有配置多语言时的兜底
final _defaultLoc = AppLocalizationsEn();

/// 获取本地化实例，如果上下文不存在则返回默认英文
AppLocalizations getLoc(BuildContext context) {
  return AppLocalizations.of(context) ?? _defaultLoc;
}
