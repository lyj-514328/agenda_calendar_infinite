import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 日历事件布局项目
class VerticalCalendarItem {
  final String id;
  final int startColumn;
  final int endColumn;
  final Widget child;

  VerticalCalendarItem({
    required this.id,
    required this.startColumn,
    required this.endColumn,
    required this.child,
  }) : assert(startColumn <= endColumn, 'startColumn must be <= endColumn'),
       assert(startColumn >= 0, 'startColumn must be >= 0');

  int get columnSpan => endColumn - startColumn + 1;
}

/// 基于 RenderBox 的日历事件布局组件
///
/// 特点：
/// 1. 支持多列布局（默认7列，对应一周7天）
/// 2. 项目可以跨越多列
/// 3. 自动堆叠：新项目会找到占用列的最大下边界作为起始位置
/// 4. 动态高度：直接测量子组件实际高度
class VerticalCalendarLayout extends MultiChildRenderObjectWidget {
  final int columnCount;
  final double columnSpacing;
  final double rowSpacing;
  final double minRowHeight;

  VerticalCalendarLayout({
    super.key,
    this.columnCount = 7,
    this.columnSpacing = 2,
    this.rowSpacing = 2,
    this.minRowHeight = 20,
    required List<VerticalCalendarItem> items,
  }) : super(
         children: items
             .map((e) => _VerticalCalendarItemData(item: e, child: e.child))
             .toList(),
       );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderVerticalCalendarLayout(
      columnCount: columnCount,
      columnSpacing: columnSpacing,
      rowSpacing: rowSpacing,
      minRowHeight: minRowHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderVerticalCalendarLayout renderObject,
  ) {
    renderObject
      ..columnCount = columnCount
      ..columnSpacing = columnSpacing
      ..rowSpacing = rowSpacing
      ..minRowHeight = minRowHeight;
  }
}

class _VerticalCalendarItemData
    extends ParentDataWidget<_VerticalCalendarItemParentData> {
  final VerticalCalendarItem item;

  const _VerticalCalendarItemData({required super.child, required this.item});

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as _VerticalCalendarItemParentData;
    if (parentData.item != item) {
      parentData.item = item;
      renderObject.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => VerticalCalendarLayout;
}

class _VerticalCalendarItemParentData extends ContainerBoxParentData<RenderBox> {
  VerticalCalendarItem? item;
}

class RenderVerticalCalendarLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _VerticalCalendarItemParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _VerticalCalendarItemParentData
        > {
  int _columnCount;
  double _columnSpacing;
  double _rowSpacing;
  double _minRowHeight;

  RenderVerticalCalendarLayout({
    required int columnCount,
    required double columnSpacing,
    required double rowSpacing,
    required double minRowHeight,
  }) : _columnCount = columnCount,
       _columnSpacing = columnSpacing,
       _rowSpacing = rowSpacing,
       _minRowHeight = minRowHeight;

  int get columnCount => _columnCount;
  set columnCount(int value) {
    if (_columnCount != value) {
      _columnCount = value;
      markNeedsLayout();
    }
  }

  double get columnSpacing => _columnSpacing;
  set columnSpacing(double value) {
    if (_columnSpacing != value) {
      _columnSpacing = value;
      markNeedsLayout();
    }
  }

  double get rowSpacing => _rowSpacing;
  set rowSpacing(double value) {
    if (_rowSpacing != value) {
      _rowSpacing = value;
      markNeedsLayout();
    }
  }

  double get minRowHeight => _minRowHeight;
  set minRowHeight(double value) {
    if (_minRowHeight != value) {
      _minRowHeight = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _VerticalCalendarItemParentData) {
      child.parentData = _VerticalCalendarItemParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    final maxWidth = constraints.maxWidth;
    final columnWidth =
        (maxWidth - columnSpacing * (columnCount - 1)) / columnCount;

    // 记录每列的当前下边界位置
    final columnBottoms = List<double>.filled(columnCount, 0.0);
    double maxHeight = 0.0;

    // 一遍布局完成
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData as _VerticalCalendarItemParentData;
      final item = parentData.item!;

      final startCol = item.startColumn.clamp(0, columnCount - 1);
      final endCol = item.endColumn.clamp(0, columnCount - 1);
      final childWidth =
          item.columnSpan * columnWidth + (item.columnSpan - 1) * columnSpacing;

      // 布局子组件
      child.layout(
        BoxConstraints(maxWidth: childWidth, minWidth: childWidth),
        parentUsesSize: true,
      );

      final childHeight = math.max(child.size.height, minRowHeight);

      // 计算占用列的最大下边界
      double maxBottom = 0.0;
      for (int c = startCol; c <= endCol; c++) {
        maxBottom = math.max(maxBottom, columnBottoms[c]);
      }

      // 设置位置
      parentData.offset = Offset(
        startCol * (columnWidth + columnSpacing),
        maxBottom,
      );

      // 更新占用列的下边界
      final newBottom = maxBottom + childHeight + rowSpacing;
      for (int c = startCol; c <= endCol; c++) {
        columnBottoms[c] = newBottom;
      }

      // 更新总高度
      maxHeight = math.max(maxHeight, maxBottom + childHeight);

      child = parentData.nextSibling;
    }

    size = Size(maxWidth, maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
