# Changelog

All notable changes to `agenda_calendar_infinite` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
