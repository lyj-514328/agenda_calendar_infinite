import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../agenda_calendar_infinite.dart';
import '../utils/l10n.dart';
import 'calendar_event.dart';

class HorizontalCalendar extends StatefulWidget {
  final List<CalendarEvent>? events;
  final double dayWidth;
  final double eventHeight;
  final double rowHeight;
  final double headerHeight;
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(CalendarEvent event)? onEventTap;
  final bool compact;

  /// 增量加载事件回调，返回需要加载的月份范围的事件
  final Future<List<CalendarEvent>> Function(
    DateTime startMonth,
    DateTime endMonth,
  )?
  onLoadEvents;

  const HorizontalCalendar({
    super.key,
    this.events,
    this.dayWidth = 120,
    this.eventHeight = 40,
    this.rowHeight = 60,
    this.headerHeight = 60,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.onEventTap,
    this.onLoadEvents,
    this.compact = false,
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

  final CalendarEventLayout _eventLayout = CalendarEventLayout();

  int _minDayOffset = -500;
  int _maxDayOffset = 500;

  double _scrollOffset = 0;

  // 增量加载相关状态
  final Set<String> _loadedMonths = {}; // 已加载的月份，格式：2025-03
  final Set<String> _loadingMonths = {}; // 正在加载的月份
  final List<CalendarEvent> _allEvents = []; // 所有已加载的事件
  final Set<String> _eventIds = {}; // 事件ID去重
  bool _isIncrementalMode = false; // 是否为增量加载模式

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _initialDate = widget.initialDate ?? DateTime.now();
    _calculateDayOffsets();

    // 判断是否为增量加载模式
    _isIncrementalMode = widget.onLoadEvents != null;

    if (_isIncrementalMode) {
      // 增量模式：加载初始月份前后3个月
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkNeedLoadEvents();
      });
    } else {
      // 传统全量模式：直接使用传入的events
      _allEvents.addAll(widget.events ?? []);
      for (final event in _allEvents) {
        _eventIds.add(event.id);
      }
      _calculateEventRows();
    }

    _horizontalController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _horizontalController.offset;
    });
    // 增量模式下检查是否需要加载新的月份
    if (_isIncrementalMode) {
      _checkNeedLoadEvents();
    }
  }

  /// 检查是否需要加载新的月份事件
  void _checkNeedLoadEvents() {
    if (!_isIncrementalMode || widget.onLoadEvents == null) return;

    // 计算当前可见范围的中心日期
    final centerOffsetDay = (_scrollOffset / widget.dayWidth).round();
    final centerDate = _getDateFromOffset(centerOffsetDay);

    // 加载范围：当前月份前后3个月
    final startLoadMonth = DateTime(centerDate.year, centerDate.month - 3, 1);
    final endLoadMonth = DateTime(
      centerDate.year,
      centerDate.month + 4,
      1,
    ); // +4 因为要包含endMonth的前一个月

    // 遍历需要加载的月份
    for (
      var month = startLoadMonth;
      month.isBefore(endLoadMonth);
      month = DateTime(month.year, month.month + 1)
    ) {
      // 检查是否超过minDate和maxDate限制
      if (widget.minDate != null &&
          month.isBefore(
            DateTime(widget.minDate!.year, widget.minDate!.month, 1),
          )) {
        continue;
      }
      if (widget.maxDate != null &&
          month.isAfter(
            DateTime(widget.maxDate!.year, widget.maxDate!.month, 1),
          )) {
        continue;
      }

      final monthKey = '${month.year}-${month.month}';
      if (!_loadedMonths.contains(monthKey) &&
          !_loadingMonths.contains(monthKey)) {
        _loadMonthEvents(month);
      }
    }
  }

  /// 加载指定月份的事件
  Future<void> _loadMonthEvents(DateTime month) async {
    final monthKey = '${month.year}-${month.month}';
    if (_loadingMonths.contains(monthKey) || _loadedMonths.contains(monthKey)) {
      return;
    }

    _loadingMonths.add(monthKey);
    try {
      // 计算当前月份的起止
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // 调用上层回调加载事件
      final events = await widget.onLoadEvents!(monthStart, monthEnd);

      if (mounted) {
        // 增量添加事件
        _addEvents(events);
        _loadedMonths.add(monthKey);
      }
    } catch (e) {
      debugPrint('加载月份$monthKey事件失败: $e');
    } finally {
      if (mounted) {
        _loadingMonths.remove(monthKey);
      }
    }
  }

  @override
  void didUpdateWidget(HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final minMaxChanged =
        oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate;

    if (minMaxChanged) {
      _calculateDayOffsets();
      if (_isIncrementalMode) {
        // 增量模式下日期范围变化，清空已加载数据重新加载
        _loadedMonths.clear();
        _loadingMonths.clear();
        _allEvents.clear();
        _eventIds.clear();
        _eventLayout.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkNeedLoadEvents();
        });
      }
    }

    // 全量模式下处理events变化
    if (!_isIncrementalMode && oldWidget.events != widget.events) {
      _allEvents.clear();
      _eventIds.clear();
      _allEvents.addAll(widget.events ?? []);
      for (final event in _allEvents) {
        _eventIds.add(event.id);
      }
      _calculateEventRows();
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

  /// 全量计算事件行
  void _calculateEventRows() {
    _eventLayout.clear();
    _eventLayout.addEvents(_allEvents);
  }

  /// 增量添加新事件
  void _addEvents(List<CalendarEvent> newEvents) {
    if (newEvents.isEmpty) return;

    for (final event in newEvents) {
      if (_eventIds.contains(event.id)) continue; // 去重
      _eventIds.add(event.id);
      _allEvents.add(event);
      _eventLayout.addSingleEvent(event);
    }

    if (mounted) {
      setState(() {});
    }
  }

  int _getDayOffsetFromInitial(DateTime date) {
    // 统一转换为本地时间后再归一化日期
    final localDate = date.toLocal();
    final normalizedDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final localInitial = _initialDate.toLocal();
    final normalizedInitial = DateTime(
      localInitial.year,
      localInitial.month,
      localInitial.day,
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
        widget.headerHeight + _eventLayout.totalRows * widget.rowHeight;

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
            _buildYearHeaders(totalHeight, _scrollOffset, constraints.maxWidth),
            _buildEventLayer(totalHeight, _scrollOffset, constraints.maxWidth),
          ],
        );
      },
    );
  }

  Widget _buildYearHeaders(
    double totalHeight,
    double scrollOffset,
    double viewportWidth,
  ) {
    // 计算当前可见范围内的年份
    final startDate = _getDateFromOffset(
      (scrollOffset / widget.dayWidth).floor() - 366,
    );
    final endDate = _getDateFromOffset(
      (scrollOffset / widget.dayWidth).ceil() +
          viewportWidth ~/ widget.dayWidth +
          366,
    );

    final yearWidgets = <Widget>[];
    int currentYear = startDate.year;
    while (currentYear <= endDate.year) {
      // 计算年份的位置和宽度
      final firstDayOfYear = DateTime(currentYear, 1, 1);
      final lastDayOfYear = DateTime(currentYear, 12, 31);
      final startOffset = _getDayOffsetFromInitial(firstDayOfYear);
      final endOffset = _getDayOffsetFromInitial(lastDayOfYear);
      final left =
          startOffset * widget.dayWidth - scrollOffset + viewportWidth * 0.5;
      final width = (endOffset - startOffset + 1) * widget.dayWidth;

      // 只有当年份在可见范围内才渲染
      if (left + width > 0 && left < viewportWidth) {
        // 计算文字在可见区域居中
        final visibleLeft = math.max(left, 0.0);
        final visibleRight = math.min(left + width, viewportWidth);
        final textLeftPadding = (visibleLeft - left).clamp(
          16.0,
          double.infinity,
        );
        final textRightPadding = (left + width - visibleRight).clamp(
          16.0,
          double.infinity,
        );

        yearWidgets.add(
          Positioned(
            left: left,
            top: 0,
            width: width,
            height: 28,
            child: Container(
              padding: EdgeInsets.only(
                left: textLeftPadding,
                right: textRightPadding,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                border: Border(
                  right: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Text(
                getLoc(context).yearFormat(currentYear),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
      currentYear++;
    }

    return SizedBox(
      width: viewportWidth,
      height: totalHeight,
      child: Stack(children: yearWidgets),
    );
  }

  Widget _buildEventLayer(
    double totalHeight,
    double scrollOffset,
    double viewportWidth,
  ) {
    final visibleEvents = <VisibleEvent>[];

    // 计算可见范围：因为anchor=0.5，视口中间对应scrollOffset=0的位置，需要调整偏移计算
    final anchorOffsetDay = (viewportWidth / widget.dayWidth) * 0.5;
    final scrollOffsetDay = (scrollOffset / widget.dayWidth).floor();
    final visibleDays = (viewportWidth / widget.dayWidth).ceil();
    final visibleStartDay =
        scrollOffsetDay - anchorOffsetDay.floor() - 10; // 多加载10天避免滚动空白
    final visibleEndDay =
        scrollOffsetDay + visibleDays - anchorOffsetDay.ceil() + 10;

    for (final event in _allEvents) {
      final startDayOffset = _getDayOffsetFromInitial(event.startDate);
      final endDayOffset = _getDayOffsetFromInitial(event.endDate);

      // 跳过完全不可见的事件
      if (endDayOffset < visibleStartDay || startDayOffset > visibleEndDay) {
        continue;
      }

      final row = _eventLayout.getEventRow(event.id) ?? 0;

      visibleEvents.add(
        VisibleEvent(
          event: event,
          startColumn: startDayOffset,
          endColumn: endDayOffset,
          row: row,
          actualStartOffset: startDayOffset * widget.dayWidth,
          actualEndOffset: (endDayOffset + 1) * widget.dayWidth,
        ),
      );
    }

    // 创建绘制器
    final painter = HorizontalCalendarEventPainter(
      visibleEvents: visibleEvents,
      dayWidth: widget.dayWidth,
      rowHeight: widget.rowHeight,
      eventHeight: widget.eventHeight,
      scrollOffset: scrollOffset,
      viewportWidth: viewportWidth,
      initialDate: _initialDate,
      context: context,
    );

    return Positioned(
      left: 0,
      right: 0,
      top: widget.headerHeight,
      height: totalHeight - widget.headerHeight,
      child: GestureDetector(
        onTapUp: (details) {
          // 点击抬起时才触发事件
          final event = painter.getEventAtPosition(details.localPosition);
          if (event != null) {
            widget.onEventTap?.call(event);
            event.onTap?.call();
          }
        },
        child: CustomPaint(painter: painter),
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
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : isWeekend
              ? Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : null,
          border: Border(
            right: BorderSide(
              width: 0.5,
              color: Theme.of(context).dividerColor,
            ),
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

    final dateFontSize = widget.compact ? 11.0 : 12.0;
    final weekdayFontSize = widget.compact ? 9.0 : 10.0;
    final spacing = widget.compact ? 1.0 : 2.0;

    return Positioned(
      top: 28, // 年份标签高度28，日期头部往下移
      left: 0,
      right: 0,
      height: widget.headerHeight - 25, // 多留3px空间避免文本溢出
      child: Container(
        decoration: BoxDecoration(
          color: isWeekend
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isToday
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          border: Border(
            right: BorderSide(
              width: 0.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('M/d').format(date),
              style: TextStyle(
                fontSize: dateFontSize,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isWeekend
                    ? Theme.of(context).colorScheme.error
                    : isToday
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            SizedBox(height: spacing), // 缩小间距避免溢出
            Text(
              weekdayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: weekdayFontSize,
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
}

/// 事件布局计算器，负责计算事件的行位置，解决重叠问题
class CalendarEventLayout {
  final Map<String, int> _eventRows = {};
  final Map<int, List<DateTimeRange>> _usedRows = {};
  int _totalRows = 0;

  int get totalRows => _totalRows;
  Map<String, int> get eventRows => Map.unmodifiable(_eventRows);

  /// 清空所有布局数据
  void clear() {
    _eventRows.clear();
    _usedRows.clear();
    _totalRows = 0;
  }

  /// 批量添加事件
  void addEvents(List<CalendarEvent> events) {
    for (final event in events) {
      addSingleEvent(event);
    }
  }

  /// 添加单个事件，计算其行位置
  void addSingleEvent(CalendarEvent event) {
    if (_eventRows.containsKey(event.id)) return;

    // 统一转换为本地时间后再归一化日期
    final localStart = event.startDate.toLocal();
    final eventStart = DateTime(
      localStart.year,
      localStart.month,
      localStart.day,
    );

    final localEnd = event.endDate.toLocal();
    final eventEnd = DateTime(localEnd.year, localEnd.month, localEnd.day);

    int row = 0;
    bool placed = false;
    while (!placed) {
      final ranges = _usedRows[row] ?? [];
      bool canPlace = true;
      for (final range in ranges) {
        if (!(eventEnd.isBefore(range.start) ||
            eventStart.isAfter(range.end))) {
          canPlace = false;
          break;
        }
      }
      if (canPlace) {
        _usedRows
            .putIfAbsent(row, () => [])
            .add(DateTimeRange(start: eventStart, end: eventEnd));
        _eventRows[event.id] = row;
        placed = true;
        if (row >= _totalRows) {
          _totalRows = row + 1;
        }
      } else {
        row++;
      }
    }
  }

  /// 获取事件的行号
  int? getEventRow(String eventId) => _eventRows[eventId];
}

/// 可见事件数据类
class VisibleEvent {
  final CalendarEvent event;
  final int startColumn;
  final int endColumn;
  final int row;
  final double actualStartOffset;
  final double actualEndOffset;

  VisibleEvent({
    required this.event,
    required this.startColumn,
    required this.endColumn,
    required this.row,
    required this.actualStartOffset,
    required this.actualEndOffset,
  });
}

/// 自定义事件绘制器
class HorizontalCalendarEventPainter extends CustomPainter {
  final List<VisibleEvent> visibleEvents;
  final double dayWidth;
  final double rowHeight;
  final double eventHeight;
  final double scrollOffset;
  final double viewportWidth;
  final DateTime initialDate;
  final BuildContext context;

  HorizontalCalendarEventPainter({
    required this.visibleEvents,
    required this.dayWidth,
    required this.rowHeight,
    required this.eventHeight,
    required this.scrollOffset,
    required this.viewportWidth,
    required this.initialDate,
    required this.context,
  }) : super(repaint: const AlwaysStoppedAnimation(0));

  @override
  void paint(Canvas canvas, Size size) {
    final anchorOffset = viewportWidth * 0.5;

    for (final visibleEvent in visibleEvents) {
      final event = visibleEvent.event;
      // 计算事件在可见区域内的实际位置
      final left = visibleEvent.actualStartOffset - scrollOffset + anchorOffset;
      final right = visibleEvent.actualEndOffset - scrollOffset + anchorOffset;

      // 事件完全不可见，跳过
      if (right <= 0 || left >= viewportWidth) continue;

      final actualLeft = left.clamp(0.0, viewportWidth);
      final actualRight = right.clamp(0.0, viewportWidth);
      final eventWidth = actualRight - actualLeft;
      if (eventWidth <= 0) continue;

      // 计算垂直位置
      final top = visibleEvent.row * rowHeight + (rowHeight - eventHeight) / 2;
      // 动态设置圆角：被截断的一侧用直角
      final leftTruncated = left < 0; // 左侧被截断
      final rightTruncated = right > viewportWidth; // 右侧被截断

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(actualLeft, top, eventWidth, eventHeight - 4),
        topLeft: leftTruncated ? Radius.zero : const Radius.circular(8),
        bottomLeft: leftTruncated ? Radius.zero : const Radius.circular(8),
        topRight: rightTruncated ? Radius.zero : const Radius.circular(8),
        bottomRight: rightTruncated ? Radius.zero : const Radius.circular(8),
      );

      // 绘制背景
      final paint = Paint()..color = event.color.withValues(alpha: 0.8);
      canvas.drawRRect(rect, paint);

      // 计算文字内边距，事件被截断时最多留8px边距，避免文字被挤偏
      final paddingLeft = (actualLeft - left).clamp(4.0, 8.0);
      final paddingRight = (right - actualRight).clamp(4.0, 8.0);

      // 宽度足够的情况下才绘制文字
      final availableTextWidth = eventWidth - paddingLeft - paddingRight;
      if (eventWidth >= 20 && availableTextWidth > 0) {
        // 绘制文字
        final textSpan = TextSpan(
          text: event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '...',
        );

        textPainter.layout(minWidth: 0, maxWidth: availableTextWidth);

        final textX =
            actualLeft +
            paddingLeft +
            (availableTextWidth - textPainter.width) / 2;
        final textY = top + (eventHeight - 4 - textPainter.height) / 2;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  /// 根据点击位置查找对应的事件
  CalendarEvent? getEventAtPosition(Offset position) {
    final anchorOffset = viewportWidth * 0.5;

    for (final visibleEvent in visibleEvents) {
      final left = visibleEvent.actualStartOffset - scrollOffset + anchorOffset;
      final right = visibleEvent.actualEndOffset - scrollOffset + anchorOffset;
      final top = visibleEvent.row * rowHeight + (rowHeight - eventHeight) / 2;
      final bottom = top + eventHeight - 4;

      if (position.dx >= left &&
          position.dx <= right &&
          position.dy >= top &&
          position.dy <= bottom) {
        return visibleEvent.event;
      }
    }

    return null;
  }

  @override
  bool hitTest(Offset position) {
    // 只返回是否命中，不处理点击事件，避免频繁触发
    return getEventAtPosition(position) != null;
  }

  @override
  bool shouldRepaint(covariant HorizontalCalendarEventPainter oldDelegate) {
    return visibleEvents != oldDelegate.visibleEvents ||
        scrollOffset != oldDelegate.scrollOffset ||
        viewportWidth != oldDelegate.viewportWidth;
  }
}
