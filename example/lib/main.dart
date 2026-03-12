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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CalendarExamplePage(),
    GanttChartExamplePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '日历视图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '甘特图视图',
          ),
        ],
      ),
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
        title: const Text('日历视图示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: VerticalCalendar(
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

class GanttChartExamplePage extends StatefulWidget {
  const GanttChartExamplePage({super.key});

  @override
  State<GanttChartExamplePage> createState() => _GanttChartExamplePageState();
}

class _GanttChartExamplePageState extends State<GanttChartExamplePage> {
  final List<GanttEvent> _events = [
    GanttEvent(
      id: '1',
      title: '项目规划',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      color: Colors.blue,
    ),
    GanttEvent(
      id: '2',
      title: 'UI设计',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      color: Colors.purple,
    ),
    GanttEvent(
      id: '3',
      title: '前端开发',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      color: Colors.green,
    ),
    GanttEvent(
      id: '4',
      title: '后端开发',
      startDate: DateTime.now().add(const Duration(days: 6)),
      endDate: DateTime.now().add(const Duration(days: 18)),
      color: Colors.orange,
    ),
    GanttEvent(
      id: '5',
      title: '测试阶段',
      startDate: DateTime.now().add(const Duration(days: 16)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      color: Colors.red,
    ),
    GanttEvent(
      id: '6',
      title: '上线部署',
      startDate: DateTime.now().add(const Duration(days: 21)),
      endDate: DateTime.now().add(const Duration(days: 22)),
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('甘特图视图示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GanttChart(
        events: _events,
        dayWidth: 120,
        eventHeight: 40,
        rowHeight: 60,
        headerHeight: 60,
        minDate: DateTime.now().subtract(const Duration(days: 30)),
        maxDate: DateTime.now().add(const Duration(days: 60)),
        onEventTap: (event) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了事件: ${event.title}')),
          );
        },
      ),
    );
  }
}
