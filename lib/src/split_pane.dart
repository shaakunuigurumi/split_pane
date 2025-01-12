import 'package:flutter/material.dart';
import 'package:split_pane/src/drag_handle_container.dart';
import 'package:split_pane/src/split_controller.dart';
import 'package:split_pane/src/split_pane_layout_delegate.dart';

/// The location of the primary pane.
///
/// In left-to-right locales, the primary pane is on the [trailing] side. In
/// right-to-left locales, the primary pane is on the [leading] side.
enum PrimaryPaneLocation {
  /// The primary pane is on the leading (for LTR, left) side.
  leading,

  /// The primary pane is on the trailing (for LTR, right) side.
  trailing,
}

/// A Material Design split pane.
///
/// See also:
///
///  * [SplitController], which controls the split pane.
///  * <https://m3.material.io/foundations/layout/applying-layout/pane-layouts#8b4b4334-e530-4bef-8f89-2631986d33ea>
class SplitPane extends StatefulWidget {
  final SplitController? controller;

  /// The primary pane.
  ///
  /// This is usually a detail view.
  final Widget primary;

  /// The secondary pane.
  ///
  /// This is usually a list view.
  final Widget secondary;

  /// A list of widths where the secondary pane should snap to.
  final List<double>? snapWidths;

  /// The direction of the split pane.
  final Axis direction;

  /// The location of the primary pane.
  final PrimaryPaneLocation primaryPaneLocation;

  /// Creates a new [SplitPane] widget.
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
