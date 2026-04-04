# 📅 Agenda Calendar Infinite

A Flutter calendar widget library with infinite scroll support, including both vertical month calendar and horizontal Gantt chart components ✨

## 🚀 Features

### 📆 Vertical Calendar

- ✨ Infinite scrollable calendar (both forward and backward)
- 🎨 Event display support with customizable colors
- 🗓️ Multi-day event support (events spanning multiple days)
- 🔄 Cross-week event handling (events that span across weeks are displayed correctly in each week)
- ⚙️ Customizable date range (minDate and maxDate)
- 👇 Day selection with callback
- 🎯 Material Design 3 support

### ⏩ Horizontal Calendar

- ✨ Horizontal infinite scrollable timeline calendar view
- 🧩 Automatic overlapping event layout (no overlapping events)
- 🎨 Highly customizable style (day width, event height, row height, header height)
- 📅 Weekend date visual differentiation with error color
- 🔴 Today auto-highlight with primary container style
- 👇 Event tap callback support (both global and per-event callbacks)
- 📝 Optimized event text display (auto center alignment in visible area, solving edge occlusion problem)
- ⚡ **High performance Canvas rendering**: CustomPainter direct drawing, 50%+ performance improvement, lower memory usage
- 🔄 **Incremental loading support**: Load events on demand as user scrolls, supports unlimited dataset size
- ⚡ **Dynamic corner radius**: Events automatically use right-angle corners when truncated at viewport edges
- 📱 **Compact mode**: Reduce text size to fit narrow screen scenarios
- ⏰ **Local time optimization**: Solve time zone issues with unified local time calculation

## Demo

### Vertical Calendar

![Vertical Calendar Demo](https://gist.githubusercontent.com/lyj-514328/0d23f1ef10584eaac9ae318fae9b1106/raw/a9a57e74256cfaa61216787feb4d8da4b71fb005/2026-03-11%252020-57-15-soConvert.webp)

### Horizontal Calendar

The horizontal calendar component provides a timeline view for project management, scheduling and task tracking scenarios.
![Horizontal Calendar Demo](https://gist.githubusercontent.com/lyj-514328/0d23f1ef10584eaac9ae318fae9b1106/raw/4c9ab1b85e796036a7e55dbba505b6fbd1e18f04/2026-03-15%252002-46-41-soConvert.webp)

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  agenda_calendar_infinite: ^0.1.0
```

Or reference it locally:

```yaml
dependencies:
  agenda_calendar_infinite:
    path: path/to/agenda_calendar_infinite
```

## Usage

### Vertical Calendar

```dart
import 'package:agenda_calendar_infinite/agenda_calendar_infinite.dart';

VerticalCalendar(
  selectedDay: _selectedDay,
  minDate: DateTime(2020, 1, 1),
  maxDate: DateTime(2030, 12, 31),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  },
  eventsBuilder: (month) {
    // Return events for the given month
    return [
      CalendarEvent(
        id: '1',
        title: 'Meeting',
        startDate: DateTime(2024, 1, 5),
        endDate: DateTime(2024, 1, 7),
        color: Colors.blue,
      ),
    ];
  },
)
```

### Horizontal Calendar

#### Basic Usage

```dart
import 'package:agenda_calendar_infinite/agenda_calendar_infinite.dart';

HorizontalCalendar(
  events: [
    CalendarEvent(
      id: 'task1',
      title: 'Requirements Review',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 11),
      color: Colors.blue,
      onTap: () => print('Tapped Requirements Review'),
    ),
    CalendarEvent(
      id: 'task2',
      title: 'Development',
      startDate: DateTime(2026, 3, 12),
      endDate: DateTime(2026, 3, 18),
      color: Colors.green,
    ),
    CalendarEvent(
      id: 'task3',
      title: 'Testing',
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 3, 20),
      color: Colors.orange,
    ),
  ],
  dayWidth: 120,
  eventHeight: 40,
  rowHeight: 60,
  initialDate: DateTime(2026, 3, 12),
  onEventTap: (event) {
    print('Tapped event: ${event.title}');
  },
)
```

#### Incremental Loading Usage (for large datasets)

```dart
HorizontalCalendar(
  dayWidth: 120,
  eventHeight: 40,
  rowHeight: 60,
  initialDate: DateTime.now(),
  minDate: DateTime(2020, 1, 1),
  maxDate: DateTime(2030, 12, 31),
  onEventTap: (event) {
    print('Tapped event: ${event.title}');
  },
  // Incremental loading callback, load events for given month range
  onLoadEvents: (startMonth, endMonth) async {
    // Load events from your API/database for the date range
    return await yourApi.loadEvents(startMonth, endMonth);
  },
)
```

## CalendarEvent Properties

| Property  | Type           | Description                                          |
| --------- | -------------- | ---------------------------------------------------- |
| id        | String         | Unique identifier for the event                      |
| title     | String         | Display title of the event                           |
| startDate | DateTime       | Start date of the event                              |
| endDate   | DateTime       | End date of the event                                |
| color     | Color          | Background color of the event (default: Colors.blue) |
| data      | dynamic        | Custom data associated with the event                |
| onTap     | VoidCallback?  | Optional tap callback for the event                  |

## VerticalCalendar Properties

| Property      | Type                                         | Description                                                         |
| ------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| selectedDay   | DateTime?                                    | Currently selected date                                             |
| onDaySelected | void Function(DateTime, DateTime)?           | Callback when a day is tapped, returns selected day and focused day |
| eventsBuilder | List `<CalendarEvent>` Function(DateTime)? | Builder function to return events for the specified month           |
| minDate       | DateTime?                                    | Minimum scrollable date limit                                       |
| maxDate       | DateTime?                                    | Maximum scrollable date limit                                       |

## HorizontalCalendar Properties

| Property     | Type                                                  | Description                                                                 |
| ------------ | ----------------------------------------------------- | --------------------------------------------------------------------------- |
| events       | List `<CalendarEvent>`?                             | List of events to display (not required when using incremental loading)     |
| dayWidth     | double                                                | Width of each day column (default: 120)                                     |
| eventHeight  | double                                                | Height of each event card (default: 40)                                     |
| rowHeight    | double                                                | Height of each row (default: 60)                                            |
| headerHeight | double                                                | Height of the date header (default: 60)                                     |
| initialDate  | DateTime?                                             | Initial date to display (default: today)                                    |
| minDate      | DateTime?                                             | Minimum date that can be scrolled to                                        |
| maxDate      | DateTime?                                             | Maximum date that can be scrolled to                                        |
| onEventTap   | void Function(CalendarEvent)?                        | Global callback when an event is tapped                                     |
| compact      | bool                                                  | Whether to use compact mode with smaller text size (default: false)         |
| onLoadEvents | Future<List<CalendarEvent>> Function(DateTime, DateTime)? | Incremental loading callback, receives start and end month, returns events |

## 🌍 Internationalization Support

This library supports multi-language automatic switching out of the box, with just two steps to configure:

### Step 1: Add localization configuration

Add the library's delegates and supported locales to your `MaterialApp`:

```dart
import 'package:agenda_calendar_infinite/agenda_calendar_infinite.dart';

MaterialApp(
  // Your other app configurations...
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    // Add this library's localization delegates
    ...agendaCalendarLocalizationsDelegates,
  ],
  // Add this library's supported locales
  supportedLocales: [
    // Your app's other supported locales...
    ...agendaCalendarSupportedLocales,
  ],
)
```

### Supported Languages

- 🇺🇸 English (default)
- 🇨🇳 Simplified Chinese

### Manual Language Override

If you want to fix the display language instead of following the system language:

```dart
MaterialApp(
  // Force display Simplified Chinese
  locale: const Locale('zh'),
  // Other configurations same as above...
)
```

## Example

See the `example` folder for a complete example application.

Run the example:

```bash
cd example
flutter run
```

## Additional information

- Repository: [lyj-514328/agenda_calendar_infinite](https://github.com/lyj-514328/agenda_calendar_infinite)
- Report issues at: [Issues · lyj-514328/agenda_calendar_infinite](https://github.com/lyj-514328/agenda_calendar_infinite/issues)
