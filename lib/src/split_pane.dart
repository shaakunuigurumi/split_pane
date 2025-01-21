import 'package:flutter/material.dart';
import 'package:split_pane/src/drag_handle_container.dart';
import 'package:split_pane/src/split_controller.dart';
import 'package:split_pane/src/split_pane_layout_delegate.dart';

/// Defines the location of a pane within a split view.
///
/// The position of the pane depends on the text direction:
/// - In left-to-right (LTR) locales, the [trailing] side refers to the right, and the [leading] side refers to the left.
/// - In right-to-left (RTL) locales, the [trailing] side refers to the left, and the [leading] side refers to the right.
enum PaneLocation {
  /// The pane is positioned on the leading side:
  /// - Left side in LTR locales.
  /// - Right side in RTL locales.
  leading,

  /// The pane is positioned on the trailing side:
  /// - Right side in LTR locales.
  /// - Left side in RTL locales.
  trailing,
}

/// A Material Design split pane.
///
/// See also:
///
///  * [SplitController], which controls the split pane.
///  * <https://m3.material.io/foundations/layout/applying-layout/pane-layouts#8b4b4334-e530-4bef-8f89-2631986d33ea>
class SplitPane extends StatefulWidget {
  /// The [SplitController] of this split pane.
  ///
  /// If not provided, a new controller will be created.
  ///
  /// You can provide a custom controller to control the split pane or to
  /// maintain the state of the split pane whenever it disappears.
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
  final PaneLocation primaryPaneLocation;

  /// Creates a new [SplitPane] widget.
  const SplitPane({
    super.key,
    this.controller,
    required this.primary,
    required this.secondary,
    this.snapWidths = const [360.0, 412.0],
    this.primaryPaneLocation = PaneLocation.trailing,
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
                direction: widget.direction,
              ),
              children: [
                LayoutId(id: 1, child: widget.primary),
                LayoutId(id: 2, child: widget.secondary),
                LayoutId(
                  id: 0,
                  child: DragHandleContainer(
                    orientation: switch (widget.direction) {
                      Axis.horizontal => Axis.vertical,
                      Axis.vertical => Axis.horizontal,
                    },
                    onDrag: (details) => _onDrag(details, width, height),
                    onDragEnd: (details) => _onDragEnd(details, width, height),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onDrag(DragUpdateDetails details, double width, double height) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset(:dx, :dy) = renderBox.globalToLocal(details.globalPosition);

    final fraction = switch (widget.direction) {
      Axis.horizontal => dx.clamp(0.0, width) / width,
      Axis.vertical => dy.clamp(0.0, height) / height,
    };

    _controller.setToFraction(fraction);
  }

  void _onDragEnd(DragEndDetails details, double width, double height) {
    snap(switch (widget.direction) {
      Axis.horizontal => width,
      Axis.vertical => height,
    });
  }

  void snap(double containerSize) {
    final (closestSnapPoint, useFraction) =
        _closestSnapPoint(_controller.position, containerSize);

    final duration = Durations.short4;
    final curve = Curves.easeOutBack;
    if (useFraction) {
      _controller.animateToFraction(
        closestSnapPoint,
        containerSize,
        duration,
        curve,
      );
    } else {
      _controller.animateToFixed(
        closestSnapPoint,
        containerSize,
        duration,
        curve,
      );
    }
  }

  (double value, bool isAbsolute) _closestSnapPoint(
      double value, double containerSize) {
    final currentAbsolute = _controller.getFixed(containerSize);

    final snapWidths = widget.snapWidths;
    final closestAbsoluteSnapPoint =
        snapWidths == null ? null : _closest(snapWidths, currentAbsolute);

    final currentFraction = _controller.getFraction(containerSize);
    final closestFractionalSnapPoint =
        _closest([0.0, 0.5, 1.0], currentFraction);

    bool useFraction = false;

    if (closestAbsoluteSnapPoint == null) {
      useFraction = true;
    } else {
      final absoluteDistance =
          (closestAbsoluteSnapPoint - currentAbsolute).abs();
      final fractionalDistance =
          ((closestFractionalSnapPoint * containerSize) - currentAbsolute)
              .abs();

      useFraction = fractionalDistance < absoluteDistance;
    }

    return (
      useFraction ? closestFractionalSnapPoint : closestAbsoluteSnapPoint!,
      useFraction
    );
  }
}

T _closest<T extends num>(Iterable<T> values, T value) {
  return values.reduce((a, b) {
    final aDistance = (a - value).abs();
    final bDistance = (b - value).abs();

    return aDistance < bDistance ? a : b;
  });
}
