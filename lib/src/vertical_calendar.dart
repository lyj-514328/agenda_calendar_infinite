import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../agenda_calendar_infinite.dart';
import '../utils/l10n.dart';
import 'calendar_event.dart';
import 'calendar_event_layout.dart';

class VerticalCalendar extends StatefulWidget {
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
  final List<CalendarEvent> Function(DateTime month)? eventsBuilder;
  final DateTime? minDate;
  final DateTime? maxDate;

  const VerticalCalendar({
    super.key,
    this.selectedDay,
    this.onDaySelected,
    this.eventsBuilder,
    this.minDate,
    this.maxDate,
  });

  @override
  State<VerticalCalendar> createState() => VerticalCalendarState();
}

class VerticalCalendarState extends State<VerticalCalendar> {
  late ScrollController _scrollController;
  late DateTime _initialMonth;
  final double _monthHeaderHeight = 50;
  final double _dayHeight = 44;
  final double _weekDayHeight = 24;
  final double _eventMinHeight = 20;
  final double _eventSpacing = 2;
  final Key _centerKey = const ValueKey<String>('center-key');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initialDate = widget.selectedDay ?? now;
    _initialMonth = DateTime(initialDate.year, initialDate.month, 1);
    _scrollController = ScrollController();
  }

  void jumpToDate(DateTime date) {
    if (context.mounted) {
      setState(() {
        _initialMonth = DateTime(date.year, date.month, 1);
      });
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      center: _centerKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      slivers: [_buildReverseSliverList(), _buildForwardSliverList()],
    );
  }

  Widget _buildReverseSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final monthIndex = -(index + 1);
        final monthDate = DateTime(
          _initialMonth.year,
          _initialMonth.month + monthIndex,
          1,
        );
        if (widget.minDate != null && monthDate.isBefore(widget.minDate!)) {
          return const SizedBox.shrink();
        }
        return _buildMonth(context, monthDate);
      }),
    );
  }

  Widget _buildForwardSliverList() {
    return SliverList(
      key: _centerKey,
      delegate: SliverChildBuilderDelegate((context, index) {
        final monthDate = DateTime(
          _initialMonth.year,
          _initialMonth.month + index,
          1,
        );
        if (widget.maxDate != null && monthDate.isAfter(widget.maxDate!)) {
          return const SizedBox.shrink();
        }
        return _buildMonth(context, monthDate);
      }),
    );
  }

  Widget _buildMonth(BuildContext context, DateTime monthDate) {
    final events = widget.eventsBuilder?.call(monthDate) ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - 16) / 7;
        return Column(
          children: [
            _buildMonthHeader(context, monthDate),
            _buildWeekDays(context),
            _buildMonthGrid(context, monthDate, events, cellWidth),
            const Divider(height: 8, thickness: 1),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(BuildContext context, DateTime monthDate) {
    final loc = getLoc(context);
    return Container(
      height: _monthHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        DateFormat(loc.monthYearFormat).format(monthDate),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildWeekDays(BuildContext context) {
    final loc = getLoc(context);
    final weekDays = [
      loc.monday,
      loc.tuesday,
      loc.wednesday,
      loc.thursday,
      loc.friday,
      loc.saturday,
      loc.sunday,
    ];
    return Container(
      height: _weekDayHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 5 || index == 6;
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  color: isWeekend
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    DateTime monthDate,
    List<CalendarEvent> events,
    double cellWidth,
  ) {
    final daysInMonth = DateUtils.getDaysInMonth(
      monthDate.year,
      monthDate.month,
    );
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final weeksInMonth = ((daysInMonth + firstWeekday - 1) / 7).ceil();

    final monthStart = DateTime(monthDate.year, monthDate.month, 1);
    final monthEnd = DateTime(monthDate.year, monthDate.month, daysInMonth);

    final monthEvents = events.where((e) {
      final eventStart = DateTime(
        e.startDate.year,
        e.startDate.month,
        e.startDate.day,
      );
      final eventEnd = DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
      return !(eventEnd.isBefore(monthStart) || eventStart.isAfter(monthEnd));
    }).toList();

    final groupedEvents = _groupEventsByWeek(
      monthEvents,
      monthStart,
      firstWeekday,
      cellWidth,
    );

    final days = <Widget>[];
    final totalCells = weeksInMonth * 7;

    for (int i = 0; i < totalCells; i++) {
      final dayOffset = i - firstWeekday + 1;
      if (dayOffset < 1 || dayOffset > daysInMonth) {
        days.add(_buildEmptyCell());
      } else {
        final dayDate = DateTime(monthDate.year, monthDate.month, dayOffset);
        days.add(_buildDayCell(context, dayDate));
      }
    }

    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      final weekIndex = i ~/ 7;
      rows.add(
        Column(
          children: [
            SizedBox(
              height: _dayHeight,
              child: Row(children: days.sublist(i, i + 7)),
            ),
            if (groupedEvents.containsKey(weekIndex))
              CalendarEventLayout(
                columnCount: 7,
                columnSpacing: 2,
                rowSpacing: _eventSpacing,
                minRowHeight: _eventMinHeight,
                items: groupedEvents[weekIndex]!,
              ),
          ],
        ),
      );
    }

    return Column(children: rows);
  }

  Map<int, List<CalendarEventItem>> _groupEventsByWeek(
    List<CalendarEvent> events,
    DateTime monthStart,
    int firstWeekday,
    double cellWidth,
  ) {
    final groupedItems = <int, List<CalendarEventItem>>{};

    for (final event in events) {
      final eventStart = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      final eventEnd = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
      );

      final displayStart = eventStart.isBefore(monthStart)
          ? monthStart
          : eventStart;
      final displayEnd =
          eventEnd.isAfter(DateTime(monthStart.year, monthStart.month + 1, 0))
          ? DateTime(monthStart.year, monthStart.month + 1, 0)
          : eventEnd;

      final startDayDiff = displayStart.difference(monthStart).inDays;
      final startColumn = (startDayDiff + firstWeekday) % 7;
      final startWeek = (startDayDiff + firstWeekday) ~/ 7;

      final endDayDiff = displayEnd.difference(monthStart).inDays;
      final endColumn = (endDayDiff + firstWeekday) % 7;
      final endWeek = (endDayDiff + firstWeekday) ~/ 7;

      for (int week = startWeek; week <= endWeek; week++) {
        final weekStartCol = week == startWeek ? startColumn : 0;
        final weekEndCol = week == endWeek ? endColumn : 6;
        final isStartOfWeek = week == startWeek;
        final isEndOfWeek = week == endWeek;

        groupedItems.putIfAbsent(week, () => []);
        groupedItems[week]!.add(
          CalendarEventItem(
            id: '${event.id}_$week',
            startColumn: weekStartCol,
            endColumn: weekEndCol,
            child: _buildEventWidget(event, isStartOfWeek, isEndOfWeek),
          ),
        );
      }
    }

    return groupedItems;
  }

  Widget _buildEventWidget(
    CalendarEvent event,
    bool isStartOfWeek,
    bool isEndOfWeek,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: isStartOfWeek ? 4 : 0,
        right: isEndOfWeek ? 4 : 0,
      ),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: isStartOfWeek ? const Radius.circular(4) : Radius.zero,
          bottomLeft: isStartOfWeek ? const Radius.circular(4) : Radius.zero,
          topRight: isEndOfWeek ? const Radius.circular(4) : Radius.zero,
          bottomRight: isEndOfWeek ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(
          event.title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          maxLines: null,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Expanded(child: Container());
  }

  Widget _buildDayCell(BuildContext context, DateTime dayDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSelected =
        widget.selectedDay != null &&
        DateUtils.isSameDay(widget.selectedDay, dayDate);
    final isToday = DateUtils.isSameDay(dayDate, today);
    final isWeekend =
        dayDate.weekday == DateTime.saturday ||
        dayDate.weekday == DateTime.sunday;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onDaySelected?.call(dayDate, dayDate);
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isToday
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${dayDate.day}',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isToday
                    ? Theme.of(context).colorScheme.primary
                    : isWeekend
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected || isToday ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
