import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class GanttEvent {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final dynamic data;

  GanttEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.color = Colors.blue,
    this.data,
  });
}

class GanttChart extends StatefulWidget {
  final List<GanttEvent> events;
  final double dayWidth;
  final double eventHeight;
  final double rowHeight;
  final double headerHeight;
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(GanttEvent event)? onEventTap;

  const GanttChart({
    super.key,
    required this.events,
    this.dayWidth = 120,
    this.eventHeight = 40,
    this.rowHeight = 60,
    this.headerHeight = 60,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.onEventTap,
  });

  @override
  State<GanttChart> createState() => GanttChartState();
}

class GanttChartState extends State<GanttChart> {
  late final ScrollController _horizontalController;
  late DateTime _initialDate;
  final Key _centerKey = const ValueKey<String>('gantt-center-key');

  Map<String, int>? _cachedEventRows;
  int? _cachedTotalRows;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _initialDate = widget.initialDate ?? DateTime.now();
    _calculateEventRows();
  }

  @override
  void didUpdateWidget(GanttChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _cachedEventRows = null;
      _cachedTotalRows = null;
      _calculateEventRows();
    }
  }

  void _calculateEventRows() {
    if (_cachedEventRows != null && _cachedTotalRows != null) {
      return;
    }

    final usedRows = <int, List<DateTimeRange>>{};
    final eventRows = <String, int>{};

    for (final event in widget.events) {
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

      int row = 0;
      bool placed = false;
      while (!placed) {
        final ranges = usedRows[row] ?? [];
        bool canPlace = true;
        for (final range in ranges) {
          if (!(eventEnd.isBefore(range.start) || eventStart.isAfter(range.end))) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          usedRows.putIfAbsent(row, () => []).add(DateTimeRange(start: eventStart, end: eventEnd));
          eventRows[event.id] = row;
          placed = true;
        } else {
          row++;
        }
      }
    }

    _cachedEventRows = eventRows;
    _cachedTotalRows = usedRows.keys.isNotEmpty ? usedRows.keys.reduce(math.max) + 1 : 0;
  }

  int _getDayOffsetFromInitial(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedInitial = DateTime(_initialDate.year, _initialDate.month, _initialDate.day);
    return normalizedDate.difference(normalizedInitial).inDays;
  }

  DateTime _getDateFromOffset(int offset) {
    return DateTime(_initialDate.year, _initialDate.month, _initialDate.day + offset);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.headerHeight + (_cachedTotalRows ?? 0) * widget.rowHeight;

    return CustomScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      center: _centerKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      slivers: [
        _buildReverseSliver(totalHeight),
        _buildForwardSliver(totalHeight),
      ],
    );
  }

  Widget _buildReverseSliver(double totalHeight) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final dayOffset = -(index + 1);
        final date = _getDateFromOffset(dayOffset);

        if (widget.minDate != null && date.isBefore(widget.minDate!)) {
          return SizedBox(width: widget.dayWidth);
        }

        return _buildDayColumn(date, totalHeight);
      }),
    );
  }

  Widget _buildForwardSliver(double totalHeight) {
    return SliverList(
      key: _centerKey,
      delegate: SliverChildBuilderDelegate((context, index) {
        final dayOffset = index;
        final date = _getDateFromOffset(dayOffset);

        if (widget.maxDate != null && date.isAfter(widget.maxDate!)) {
          return SizedBox(width: widget.dayWidth);
        }

        return _buildDayColumn(date, totalHeight);
      }),
    );
  }

  Widget _buildDayColumn(DateTime date, double totalHeight) {
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return SizedBox(
      width: widget.dayWidth,
      height: totalHeight,
      child: Stack(
        children: [
          _buildDayBackground(isWeekend),
          _buildDayHeader(date, isWeekend, isToday),
          _buildDayEvents(date),
        ],
      ),
    );
  }

  Widget _buildDayBackground(bool isWeekend) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: isWeekend
              ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
              : null,
          border: const Border(
            right: BorderSide(width: 0.5, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(DateTime date, bool isWeekend, bool isToday) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: widget.headerHeight,
      child: Container(
        decoration: BoxDecoration(
          color: isWeekend
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
          border: const Border(
            right: BorderSide(width: 0.5, color: Colors.grey),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('M/d').format(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isWeekend
                    ? Theme.of(context).colorScheme.error
                    : isToday
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getWeekdayName(date.weekday),
              style: TextStyle(
                fontSize: 10,
                color: isWeekend
                    ? Theme.of(context).colorScheme.error
                    : isToday
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayEvents(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final widgets = <Widget>[];

    for (final event in widget.events) {
      final eventStart = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
      final eventEnd = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);

      if (dayStart.isBefore(eventStart) || dayStart.isAfter(eventEnd)) {
        continue;
      }

      final isStartOfEvent = DateUtils.isSameDay(dayStart, eventStart);
      final isEndOfEvent = DateUtils.isSameDay(dayStart, eventEnd);
      final row = _cachedEventRows?[event.id] ?? 0;

      widgets.add(
        Positioned(
          left: 0,
          top: widget.headerHeight + row * widget.rowHeight + (widget.rowHeight - widget.eventHeight) / 2,
          width: widget.dayWidth,
          height: widget.eventHeight,
          child: GestureDetector(
            onTap: () => widget.onEventTap?.call(event),
            child: _buildEventWidget(event, isStartOfEvent, isEndOfEvent),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Stack(
        children: widgets,
      ),
    );
  }

  Widget _buildEventWidget(GanttEvent event, bool isStartOfEvent, bool isEndOfEvent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: isStartOfEvent ? const Radius.circular(4) : Radius.zero,
          bottomLeft: isStartOfEvent ? const Radius.circular(4) : Radius.zero,
          topRight: isEndOfEvent ? const Radius.circular(4) : Radius.zero,
          bottomRight: isEndOfEvent ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      child: isStartOfEvent
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            )
          : null,
    );
  }
}

String _getWeekdayName(int weekday) {
  const names = ['一', '二', '三', '四', '五', '六', '日'];
  return names[weekday - 1];
}