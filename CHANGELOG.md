# Changelog

All notable changes to `agenda_calendar_infinite` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-05

### Added

- ✨ **Incremental loading support for HorizontalCalendar**: Add `onLoadEvents` callback to load events on demand as user scrolls, significantly improving performance for large datasets
- 🎨 **HorizontalCalendar rendering engine rewrite**: Replace RenderObject layout with CustomPainter direct drawing, 50%+ performance improvement, lower memory usage
- ⚡ **Dynamic corner radius for events**: Events automatically use right-angle corners when truncated at viewport edges for more natural visual effect
- 📱 **Compact mode for HorizontalCalendar**: Add `compact` parameter to reduce text size for narrow screen scenarios
- 🔘 **Individual event tap callback**: Add `onTap` property to `CalendarEvent` class, supporting independent click processing for each event
- ⏰ **Local time optimization**: Unified local time calculation for date offsets to solve time zone issues
- 🚀 **Scrolling experience optimization**: Preload 10 days of events outside the visible range to eliminate blank areas during scrolling

### Changed

- 🔄 **VerticalCalendar layout class rename**: `CalendarEventLayout` → `VerticalCalendarLayout`, `CalendarEventItem` → `VerticalCalendarItem` for better naming consistency
- 🗑️ **Remove deprecated code**: Delete obsolete `horizontal_calendar_event_layout.dart` file
- 🛠️ **Deprecated API fix**: Replace `withOpacity` with `withValues` to eliminate compilation warnings

## [0.0.5] - 2026-03-15

### Fixed

- Fixed horizontal calendar event date alignment bug

## [0.0.4] - 2026-03-12

### Added

- New `HorizontalCalendar` widget, a horizontal infinite scrollable timeline calendar for project management and scheduling
- Support automatic overlapping event layout (no overlapping events)
- Support event tap callback, fully customizable style parameters (day width, event height, row height, etc.)
- Optimized event text display with auto center alignment in visible area, solving edge occlusion problem
- Unified `CalendarEvent` class used by both VerticalCalendar and HorizontalCalendar
- Complete horizontal calendar documentation, API references and usage examples in README
- Internationalization support with built-in English and Simplified Chinese locales
- Exposed `agendaCalendarLocalizationsDelegates` and `agendaCalendarSupportedLocales` for easy integration
- All built-in text now supports automatic system language switching

## [0.0.3] - 2026-03-11

### Changed

- Optimized image format from APNG to WebP for better compatibility and smaller file size

## [0.0.2] - 2026-03-11

### Fixed

- Fixed image links in README for pub.dev compatibility
- Updated pubspec.yaml repository and homepage URLs

## [0.0.1] - 2026-03-11

### Added

- Initial release
- Infinite scrollable vertical calendar
- Event display with customizable colors
- Multi-day and cross-week event support
- Customizable date range (minDate/maxDate)
- Day selection callback
- Material Design 3 support
- Example application
