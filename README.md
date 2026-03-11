# Agenda Calendar Infinite

A Flutter calendar widget with infinite scroll and event display support.

## Features

- Infinite scrollable calendar (both forward and backward)
- Event display support with customizable colors
- Multi-day event support (events spanning multiple days)
- Cross-week event handling (events that span across weeks are displayed correctly in each week)
- Customizable date range (minDate and maxDate)
- Day selection with callback
- Material Design 3 support

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  agenda_calendar_infinite: ^0.0.1
```

Or reference it locally:

```yaml
dependencies:
  agenda_calendar_infinite:
    path: path/to/agenda_calendar_infinite
```

## Usage

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

## CalendarEvent Properties

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier for the event |
| title | String | Display title of the event |
| startDate | DateTime | Start date of the event |
| endDate | DateTime | End date of the event |
| color | Color | Background color of the event (default: Colors.blue) |
| data | dynamic | Custom data associated with the event |

## Example

See the `example` folder for a complete example application.

Run the example:

```bash
cd example
flutter run
```

## Additional information

- Repository: https://github.com/your-githubusername/agenda_calendar_infinite
- Report issues at: https://github.com/your-githubusername/agenda_calendar_infinite/issues
