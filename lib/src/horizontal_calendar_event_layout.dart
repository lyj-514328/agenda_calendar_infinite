import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HorizontalCalendarEventItem {
  final String id;
  final int startColumn;
  final int endColumn;
  final int row;
  final Widget child;

  HorizontalCalendarEventItem({
    required this.id,
    required this.startColumn,
    required this.endColumn,
    required this.row,
    required this.child,
  });
}

class HorizontalCalendarEventLayout extends MultiChildRenderObjectWidget {
  final double dayWidth;
  final double rowHeight;
  final double columnSpacing;

  HorizontalCalendarEventLayout({
    super.key,
    required this.dayWidth,
    required this.rowHeight,
    this.columnSpacing = 0,
    required List<HorizontalCalendarEventItem> items,
  }) : super(
         children: items
             .map(
               (e) => _HorizontalCalendarEventItemData(item: e, child: e.child),
             )
             .toList(),
       );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHorizontalCalendarEventLayout(
      dayWidth: dayWidth,
      rowHeight: rowHeight,
      columnSpacing: columnSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHorizontalCalendarEventLayout renderObject,
  ) {
    renderObject
      ..dayWidth = dayWidth
      ..rowHeight = rowHeight
      ..columnSpacing = columnSpacing;
  }
}

class _HorizontalCalendarEventItemData
    extends ParentDataWidget<_HorizontalCalendarEventItemParentData> {
  final HorizontalCalendarEventItem item;

  const _HorizontalCalendarEventItemData({
    required super.child,
    required this.item,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData =
        renderObject.parentData as _HorizontalCalendarEventItemParentData;
    if (parentData.item != item) {
      parentData.item = item;
      renderObject.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => HorizontalCalendarEventLayout;
}

class _HorizontalCalendarEventItemParentData
    extends ContainerBoxParentData<RenderBox> {
  HorizontalCalendarEventItem? item;
}

class RenderHorizontalCalendarEventLayout extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          _HorizontalCalendarEventItemParentData
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _HorizontalCalendarEventItemParentData
        > {
  double _dayWidth;
  double _rowHeight;
  double _columnSpacing;

  RenderHorizontalCalendarEventLayout({
    required double dayWidth,
    required double rowHeight,
    required double columnSpacing,
  }) : _dayWidth = dayWidth,
       _rowHeight = rowHeight,
       _columnSpacing = columnSpacing;

  double get dayWidth => _dayWidth;
  set dayWidth(double value) {
    if (_dayWidth != value) {
      _dayWidth = value;
      markNeedsLayout();
    }
  }

  double get rowHeight => _rowHeight;
  set rowHeight(double value) {
    if (_rowHeight != value) {
      _rowHeight = value;
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

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _HorizontalCalendarEventItemParentData) {
      child.parentData = _HorizontalCalendarEventItemParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    double maxWidth = 0;
    double maxHeight = 0;

    var child = firstChild;
    while (child != null) {
      final parentData =
          child.parentData as _HorizontalCalendarEventItemParentData;
      final item = parentData.item!;

      final columnSpan = item.endColumn - item.startColumn + 1;
      final childWidth =
          columnSpan * dayWidth + (columnSpan - 1) * columnSpacing;

      child.layout(
        BoxConstraints(
          maxWidth: childWidth,
          minWidth: childWidth,
          maxHeight: rowHeight,
        ),
        parentUsesSize: true,
      );

      final x = item.startColumn * (dayWidth + columnSpacing);
      final y = item.row * rowHeight;

      parentData.offset = Offset(x, y);

      maxWidth = math.max(maxWidth, x + childWidth);
      maxHeight = math.max(maxHeight, y + rowHeight);

      child = parentData.nextSibling;
    }

    size = Size(constraints.maxWidth, constraints.maxHeight);
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
