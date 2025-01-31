import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:split_pane/src/split_pane_theme_data.dart';

/// A visual indicator for the [DragHandleContainer].
class DragHandle extends StatefulWidget {
  /// Whether the handle is pressed down
  final bool pressed;

  /// The orientation of the handle
  final Axis orientation;

  /// Creates a new [DragHandle] widget.
  const DragHandle({
    super.key,
    this.pressed = false,
    this.orientation = Axis.vertical,
  });

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Durations.medium1,
      vsync: this,
      value: widget.pressed ? 1 : 0,
    );

    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubicEmphasized,
    );

    animation = curve;
  }

  @override
  void didUpdateWidget(covariant DragHandle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pressed != oldWidget.pressed) {
      if (widget.pressed) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final splitPaneTheme = theme.extension<SplitPaneThemeData>();

    final fallback = WidgetStateColor.fromMap({
      WidgetState.pressed: theme.colorScheme.onSurface,
      WidgetState.any: theme.colorScheme.outline,
    });

    final dragHandleColor = (splitPaneTheme?.dragHandleColor ?? fallback);

    final pressedColor = dragHandleColor.resolve({WidgetState.pressed});
    final defaultColor = dragHandleColor.resolve({});

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final longLength = lerpDouble(48, 52, animation.value);
        final shortLength = lerpDouble(4, 12, animation.value);
        final handleColor = Color.lerp(
          defaultColor,
          pressedColor,
          animation.value,
        );

        return Align(
          child: SizedBox(
            width: widget.orientation == Axis.horizontal
                ? longLength
                : shortLength,
            height:
                widget.orientation == Axis.vertical ? longLength : shortLength,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: handleColor,
                shape: StadiumBorder(),
              ),
            ),
          ),
        );
      },
    );
  }
}
