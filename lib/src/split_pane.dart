import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:split_pane/src/drag_handle.dart';
import 'package:split_pane/src/split_controller.dart';
import 'package:split_pane/src/split_pane_layout_delegate.dart';

enum PrimaryPaneLocation { leading, trailing }

class SplitPane extends StatefulWidget {
  final SplitController? controller;
  final Widget primary;
  final Widget secondary;
  final List<double>? snapWidths;
  final Axis direction;
  final PrimaryPaneLocation primaryPaneLocation;

  const SplitPane({
    super.key,
    this.controller,
    required this.primary,
    required this.secondary,
    this.snapWidths = const [360.0, 412.0],
    this.primaryPaneLocation = PrimaryPaneLocation.trailing,
    this.direction = Axis.horizontal,
  });

  @override
  State<SplitPane> createState() => _SplitPaneState();
}

class _SplitPaneState extends State<SplitPane> with TickerProviderStateMixin {
  late final SplitController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SplitController(vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return CustomMultiChildLayout(
              delegate: SplitPaneLayoutDelegate(
                secondarySize: _controller.animation.value,
                isAbsolute: _controller.isAbsolute,
              ),
              children: [
                LayoutId(id: 1, child: widget.primary),
                LayoutId(id: 2, child: widget.secondary),
                LayoutId(
                  id: 0,
                  child: DragHandleContainer(
                    onDrag: (details) => onDrag(details, width, height),
                    onDragEnd: (details) => onDragEnd(details, width, height),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onDrag(DragUpdateDetails details, double width, double height) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset(:dx, :dy) = renderBox.globalToLocal(details.globalPosition);

    final fraction = switch (widget.direction) {
      Axis.horizontal => dx.clamp(0.0, width) / width,
      Axis.vertical => dy.clamp(0.0, height) / height,
    };

    _controller.setToFraction(fraction);
  }

  void onDragEnd(DragEndDetails details, double width, double height) {
    final currentAbsolute = _controller.getFixed(width);

    final closestAbsoluteSnapPoint = widget.snapWidths?.reduce((a, b) {
      final aDistance = (a - currentAbsolute).abs();
      final bDistance = (b - currentAbsolute).abs();

      return aDistance < bDistance ? a : b;
    });

    final currentFraction = _controller.getFraction(width);
    final closestFractionalSnapPoint = [0.0, 0.5, 1.0].reduce((a, b) {
      final aDistance = (a - currentFraction).abs();
      final bDistance = (b - currentFraction).abs();

      return aDistance < bDistance ? a : b;
    });

    bool useFraction = false;

    if (closestAbsoluteSnapPoint == null) {
      useFraction = true;
    } else {
      final absoluteDistance =
          (closestAbsoluteSnapPoint - currentAbsolute).abs();
      final fractionalDistance =
          ((closestFractionalSnapPoint * width) - currentAbsolute).abs();

      useFraction = fractionalDistance < absoluteDistance;
    }

    var duration = Durations.short4;
    var curve = Curves.easeOutBack;
    if (useFraction) {
      _controller.animateToFraction(
        closestFractionalSnapPoint,
        width,
        duration,
        curve,
      );
    } else {
      _controller.animateToFixed(
        closestAbsoluteSnapPoint!,
        width,
        duration,
        curve,
      );
    }
  }
}

class DragHandleContainer extends StatefulWidget {
  final GestureDragUpdateCallback? onDrag;
  final GestureDragEndCallback? onDragEnd;
  final Axis orientation;
  final double handleAlignment;

  const DragHandleContainer({
    super.key,
    this.onDrag,
    this.onDragEnd,
    this.orientation = Axis.vertical,
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
          onVerticalDragStart: isHorizontal ? onDragStart : null,
          onVerticalDragUpdate: isHorizontal ? widget.onDrag : null,
          onVerticalDragEnd: isHorizontal ? onDragEnd : null,
          onHorizontalDragUpdate: isVertical ? widget.onDrag : null,
          onHorizontalDragStart: isVertical ? onDragStart : null,
          onHorizontalDragEnd: isVertical ? onDragEnd : null,
          child: AnimatedAlign(
            alignment: Alignment(
              isHorizontal ? widget.handleAlignment : 0.5,
              isVertical ? widget.handleAlignment : 0.5,
            ),
            duration: Durations.medium1,
            child: DragHandle(pressed: _pressed),
          ),
        ),
      ),
    );
  }

  void onDragStart(DragStartDetails details) {
    setState(() => _pressed = true);
  }

  void onDragEnd(DragEndDetails details) {
    setState(() => _pressed = false);
    widget.onDragEnd?.call(details);
  }
}
