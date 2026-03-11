import 'package:flutter/material.dart';
import 'package:agenda_calendar_infinite/agenda_calendar_infinite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Calendar Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalendarExamplePage(),
    );
  }
}

class CalendarExamplePage extends StatefulWidget {
  const CalendarExamplePage({super.key});

  @override
  State<CalendarExamplePage> createState() => _CalendarExamplePageState();
}

class _CalendarExamplePageState extends State<CalendarExamplePage> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Calendar Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: VerticalCalendar(
          selectedDay: _selectedDay,
          minDate: DateTime(2020, 1, 1),
          maxDate: DateTime(2030, 12, 31),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
          eventsBuilder: (month) {
            return _generateSampleEvents(month);
          },
        ),
      ),
    );
  }

  List<CalendarEvent> _generateSampleEvents(DateTime month) {
    final now = DateTime.now();
    final events = <CalendarEvent>[];

    events.add(
      CalendarEvent(
        id: '1',
        title: '会议',
        startDate: DateTime(month.year, month.month, 5),
        endDate: DateTime(month.year, month.month, 7),
        color: Colors.blue,
      ),
    );

    events.add(
      CalendarEvent(
        id: '2',
        title: '项目截止',
        startDate: DateTime(month.year, month.month, 12),
        endDate: DateTime(month.year, month.month, 12),
        color: Colors.red,
      ),
    );

    events.add(
      CalendarEvent(
        id: '3',
        title: '跨周活动',
        startDate: DateTime(month.year, month.month, 20),
        endDate: DateTime(month.year, month.month, 25),
        color: Colors.green,
      ),
    );

    if (month.month == now.month && month.year == now.year) {
      events.add(
        CalendarEvent(
          id: '4',
          title: '今天的事件',
          startDate: DateTime(now.year, now.month, now.day),
          endDate: DateTime(now.year, now.month, now.day),
          color: Colors.orange,
        ),
      );
    }

    return events;
  }
}
