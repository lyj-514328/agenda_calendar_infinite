import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../agenda_calendar_infinite.dart';
import '../utils/l10n.dart';
import 'calendar_event.dart';
import 'horizontal_calendar_event_layout.dart';

class HorizontalCalendar extends StatefulWidget {
  final List<CalendarEvent> events;
  final double dayWidth;
  final double eventHeight;
  final double rowHeight;
  final double headerHeight;
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(CalendarEvent event)? onEventTap;

  const HorizontalCalendar({
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
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  late final ScrollController _horizontalController;
  late DateTime _initialDate;
  final Key _centerKey = const ValueKey<String>(
    'horizontal-calendar-center-key',
  );

  Map<String, int>? _cachedEventRows;
  int? _cachedTotalRows;

  int _minDayOffset = -500;
  int _maxDayOffset = 500;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _initialDate = widget.initialDate ?? DateTime.now();
    _calculateEventRows();
    _calculateDayOffsets();

    _horizontalController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _horizontalController.offset;
    });
  }

  @override
  void didUpdateWidget(HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events ||
        oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate) {
      _cachedEventRows = null;
      _cachedTotalRows = null;
      _calculateEventRows();
      _calculateDayOffsets();
    }
  }

  void _calculateDayOffsets() {
    _minDayOffset = -500;
    _maxDayOffset = 500;

    if (widget.minDate != null) {
      _minDayOffset = _getDayOffsetFromInitial(widget.minDate!);
    }
    if (widget.maxDate != null) {
      _maxDayOffset = _getDayOffsetFromInitial(widget.maxDate!);
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
          if (!(eventEnd.isBefore(range.start) ||
              eventStart.isAfter(range.end))) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          usedRows
              .putIfAbsent(row, () => [])
              .add(DateTimeRange(start: eventStart, end: eventEnd));
          eventRows[event.id] = row;
          placed = true;
        } else {
          row++;
        }
      }
    }

    _cachedEventRows = eventRows;
    _cachedTotalRows = usedRows.keys.isNotEmpty
        ? usedRows.keys.reduce(math.max) + 1
        : 0;
  }

  int _getDayOffsetFromInitial(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedInitial = DateTime(
      _initialDate.year,
      _initialDate.month,
      _initialDate.day,
    );
    return normalizedDate.difference(normalizedInitial).inDays;
  }

  DateTime _getDateFromOffset(int offset) {
    return DateTime(
      _initialDate.year,
      _initialDate.month,
      _initialDate.day + offset,
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight =
        widget.headerHeight + (_cachedTotalRows ?? 0) * widget.rowHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CustomScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              center: _centerKey,
              anchor: 0.5,
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
            ),
            _buildEventLayer(totalHeight, _scrollOffset, constraints.maxWidth),
          ],
        );
      },
    );
  }

  Widget _buildEventLayer(
    double totalHeight,
    double scrollOffset,
    double visibleWidth,
  ) {
    final visibleEvents = <_VisibleEvent>[];
    const maxDays = 1000; // -500 到 +500 天
    const halfMaxDays = 500; // 偏移量

    // 计算可见范围
    final scrollOffsetDay = (scrollOffset / widget.dayWidth).floor();
    final visibleDays = (visibleWidth / widget.dayWidth).ceil();
    final visibleStartDay = scrollOffsetDay - 1;
    final visibleEndDay = scrollOffsetDay + visibleDays + 1;

    for (final event in widget.events) {
      final startDayOffset = _getDayOffsetFromInitial(event.startDate);
      final endDayOffset = _getDayOffsetFromInitial(event.endDate);

      // 跳过完全不可见的事件
      if (endDayOffset < visibleStartDay || startDayOffset > visibleEndDay) {
        continue;
      }

      final displayStart = math.max(startDayOffset, -halfMaxDays);
      final displayEnd = math.min(endDayOffset, halfMaxDays);

      final row = _cachedEventRows?[event.id] ?? 0;

      visibleEvents.add(
        _VisibleEvent(
          event: event,
          startColumn: displayStart + halfMaxDays,
          endColumn: displayEnd + halfMaxDays,
          row: row,
          actualStartOffset: startDayOffset * widget.dayWidth,
          actualEndOffset: (endDayOffset + 1) * widget.dayWidth,
        ),
      );
    }

    return Positioned(
      left: -scrollOffset - halfMaxDays * widget.dayWidth,
      top: widget.headerHeight,
      width: maxDays * widget.dayWidth,
      height: totalHeight - widget.headerHeight,
      child: HorizontalCalendarEventLayout(
        dayWidth: widget.dayWidth,
        rowHeight: widget.rowHeight,
        items: visibleEvents
            .map(
              (e) => HorizontalCalendarEventItem(
                id: e.event.id,
                startColumn: e.startColumn,
                endColumn: e.endColumn,
                row: e.row,
                child: GestureDetector(
                  onTap: () => widget.onEventTap?.call(e.event),
                  child: _buildEventWidget(
                    e.event,
                    e.actualStartOffset - scrollOffset,
                    e.actualEndOffset - scrollOffset,
                    visibleWidth,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReverseSliver(double totalHeight) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final dayOffset = -(index + 1);

        if (widget.minDate != null && dayOffset < _minDayOffset) {
          return SizedBox(width: widget.dayWidth);
        }

        return _buildDayColumn(dayOffset, totalHeight);
      }),
    );
  }

  Widget _buildForwardSliver(double totalHeight) {
    return SliverList(
      key: _centerKey,
      delegate: SliverChildBuilderDelegate((context, index) {
        final dayOffset = index;

        if (widget.maxDate != null && dayOffset > _maxDayOffset) {
          return SizedBox(width: widget.dayWidth);
        }

        return _buildDayColumn(dayOffset, totalHeight);
      }),
    );
  }

  Widget _buildDayColumn(int dayOffset, double totalHeight) {
    final date = _getDateFromOffset(dayOffset);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return SizedBox(
      width: widget.dayWidth,
      height: totalHeight,
      child: Stack(
        children: [
          _buildDayBackground(isWeekend, isToday),
          _buildDayHeader(date, isWeekend, isToday),
        ],
      ),
    );
  }

  Widget _buildDayBackground(bool isWeekend, bool isToday) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : isWeekend
              ? Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3)
              : null,
          border: const Border(
            right: BorderSide(width: 0.5, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(DateTime date, bool isWeekend, bool isToday) {
    final loc = getLoc(context);
    final weekdayNames = [
      loc.monday,
      loc.tuesday,
      loc.wednesday,
      loc.thursday,
      loc.friday,
      loc.saturday,
      loc.sunday,
    ];
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
              weekdayNames[date.weekday - 1],
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

  Widget _buildEventWidget(
    CalendarEvent event,
    double visibleLeft,
    double visibleRight,
    double visibleWidth,
  ) {
    // 计算事件在可视区域内的实际边界
    final actualVisibleLeft = math.max(visibleLeft, 0.0);
    final actualVisibleRight = math.min(visibleRight, visibleWidth);

    // 可见区域居中对齐
    const TextAlign textAlign = TextAlign.center;
    // 计算左右内边距，让文字始终在可见区域内居中显示
    final leftPadding = (actualVisibleLeft - visibleLeft).clamp(
      8.0,
      double.infinity,
    );
    final rightPadding = (visibleRight - actualVisibleRight).clamp(
      8.0,
      double.infinity,
    );
    final padding = EdgeInsets.only(
      left: leftPadding,
      right: rightPadding,
      top: 4,
      bottom: 4,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: (widget.rowHeight - widget.eventHeight) / 2,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: padding,
        child: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

class _VisibleEvent {
  final CalendarEvent event;
  final int startColumn;
  final int endColumn;
  final int row;
  final double actualStartOffset;
  final double actualEndOffset;

  _VisibleEvent({
    required this.event,
    required this.startColumn,
    required this.endColumn,
    required this.row,
    required this.actualStartOffset,
    required this.actualEndOffset,
  });
}
