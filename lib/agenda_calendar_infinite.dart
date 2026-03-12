import 'package:flutter/material.dart' show Locale, LocalizationsDelegate;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';
export 'generated/app_localizations.dart';
export 'src/calendar_event.dart';
export 'src/vertical_calendar.dart';
export 'src/horizontal_calendar.dart';

/// 日历库的本地化代理列表，使用者可以直接加到 MaterialApp 的 localizationsDelegates 里
const List<LocalizationsDelegate<dynamic>>
agendaCalendarLocalizationsDelegates = AppLocalizations.localizationsDelegates;

/// 日历库支持的语言列表，使用者可以直接加到 MaterialApp 的 supportedLocales 里
const List<Locale> agendaCalendarSupportedLocales =
    AppLocalizations.supportedLocales;
