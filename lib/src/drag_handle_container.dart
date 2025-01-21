import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:split_pane/src/drag_handle.dart';

/// Container for the drag handle that handles animation and drag callbacks.
class DragHandleContainer extends StatefulWidget {
  /// Callback for when the drag updates.
  final GestureDragUpdateCallback? onDrag;

  /// Callback for when the drag ends.
  final GestureDragEndCallback? onDragEnd;

  /// The orientation of the handle.
  final Axis orientation;

  /// The alignment of the handle within the container in the cross-axis.
  final double handleAlignment;

  /// Creates a new [DragHandleContainer] widget.
  const DragHandleContainer({
    super.key,
    this.onDrag,
    this.onDragEnd,
    required this.orientation,
    this.handleAlignment = 0.5,
  });

  @override
  State<DragHandleContainer> createState() => _DragHandleContainerState();
}

class _DragHandleContainerState extends State<DragHandleContainer> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.orientation == Axis.horizontal;
    final isVertical = widget.orientation == Axis.vertical;

    return MouseRegion(
      cursor: switch (widget.orientation) {
        Axis.horizontal => SystemMouseCursors.resizeRow,
        Axis.vertical => SystemMouseCursors.resizeColumn,
      },
      child: SizedBox(
        width: isVertical ? 24.0 : null,
        height: isHorizontal ? 24.0 : null,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: isHorizontal ? _onDragStart : null,
          onVerticalDragUpdate: isHorizontal ? widget.onDrag : null,
          onVerticalDragEnd: isHorizontal ? _onDragEnd : null,
          onHorizontalDragUpdate: isVertical ? widget.onDrag : null,
          onHorizontalDragStart: isVertical ? _onDragStart : null,
          onHorizontalDragEnd: isVertical ? _onDragEnd : null,
          child: AnimatedAlign(
            alignment: Alignment(
              isHorizontal ? widget.handleAlignment : 0.5,
              isVertical ? widget.handleAlignment : 0.5,
            ),
            duration: Durations.medium1,
            child: DragHandle(
              pressed: _pressed,
              orientation: widget.orientation,
            ),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    setState(() => _pressed = true);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _pressed = false);
    widget.onDragEnd?.call(details);
  }
}
