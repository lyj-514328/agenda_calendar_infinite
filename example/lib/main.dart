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
  late final List<GanttEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = _generateEvents();
  }

  List<GanttEvent> _generateEvents() {
    final now = DateTime.now();
    final events = <GanttEvent>[];

    // 生成 50 个随机事件
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
    ];

    for (int i = 0; i < 50; i++) {
      final startDay = (i * 2) - 20 + (i % 10);
      final duration = 2 + (i % 8);
      final color = colors[i % colors.length];

      events.add(
        GanttEvent(
          id: '$i',
          title: '任务 ${i + 1}',
          startDate: now.add(Duration(days: startDay)),
          endDate: now.add(Duration(days: startDay + duration)),
          color: color,
        ),
      );
    }

    return events;
  }

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
        minDate: DateTime.now().subtract(const Duration(days: 60)),
        maxDate: DateTime.now().add(const Duration(days: 120)),
        onEventTap: (event) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了事件: ${event.title}')),
          );
        },
      ),
    );
  }
}
