# Agenda Calendar Infinite

A Flutter calendar widget library with infinite scroll support, including both vertical month calendar and horizontal Gantt chart components.

## Features

### Vertical Calendar
- Infinite scrollable calendar (both forward and backward)
- Event display support with customizable colors
- Multi-day event support (events spanning multiple days)
- Cross-week event handling (events that span across weeks are displayed correctly in each week)
- Customizable date range (minDate and maxDate)
- Day selection with callback
- Material Design 3 support

### Horizontal Calendar
- Horizontal infinite scrollable timeline calendar view
- Automatic overlapping event layout (no overlapping events)
- Highly customizable style (day width, event height, row height, header height)
- Weekend date visual differentiation with error color
- Today auto-highlight with primary container style
- Event tap callback support
- Optimized event text display (auto center alignment in visible area, solving edge occlusion problem)
- High performance rendering (only build visible area content)

## Demo

### Vertical Calendar
![Vertical Calendar Demo](https://gist.githubusercontent.com/lyj-514328/0d23f1ef10584eaac9ae318fae9b1106/raw/a9a57e74256cfaa61216787feb4d8da4b71fb005/2026-03-11%252020-57-15-soConvert.webp)

### Horizontal Calendar
The horizontal calendar component provides a timeline view for project management, scheduling and task tracking scenarios.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  agenda_calendar_infinite: ^0.0.4
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

## CalendarEvent Properties

| Property  | Type     | Description                                          |
| --------- | -------- | ---------------------------------------------------- |
| id        | String   | Unique identifier for the event                      |
| title     | String   | Display title of the event                           |
| startDate | DateTime | Start date of the event                              |
| endDate   | DateTime | End date of the event                                |
| color     | Color    | Background color of the event (default: Colors.blue) |
| data      | dynamic  | Custom data associated with the event                |

## HorizontalCalendar Properties

| Property     | Type                         | Description                                                              |
| ------------ | ---------------------------- | ------------------------------------------------------------------------ |
| events       | List<CalendarEvent>          | List of events to display                                                |
| dayWidth     | double                       | Width of each day column (default: 120)                                  |
| eventHeight  | double                       | Height of each event card (default: 40)                                  |
| rowHeight    | double                       | Height of each row (default: 60)                                         |
| headerHeight | double                       | Height of the date header (default: 60)                                  |
| initialDate  | DateTime?                    | Initial date to display (default: today)                                 |
| minDate      | DateTime?                    | Minimum date that can be scrolled to                                     |
| maxDate      | DateTime?                    | Maximum date that can be scrolled to                                     |
| onEventTap   | void Function(CalendarEvent)? | Callback when an event is tapped                                        |

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
