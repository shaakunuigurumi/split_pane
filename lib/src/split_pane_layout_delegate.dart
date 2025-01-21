import 'dart:ui';

import 'package:flutter/rendering.dart';

/// A layout delegate for the [SplitPane] widget.
class SplitPaneLayoutDelegate extends MultiChildLayoutDelegate {
  /// The size of the secondary pane.
  final double secondarySize;

  /// Whether the secondary pane size is absolute.
  final bool isAbsolute;

  /// In which direction the split pane is split.
  final Axis direction;

  /// Creates a new [SplitPaneLayoutDelegate].
  SplitPaneLayoutDelegate({
    required this.secondarySize,
    required this.isAbsolute,
    required this.direction,
  });

  @override
  void performLayout(Size size) {
    const divider = 0;
    const primary = 1;
    const secondary = 2;

    final (mainAxisExtent, crossAxisExtent) = switch (direction) {
      Axis.horizontal => (size.width, size.height),
      Axis.vertical => (size.height, size.width),
    };

    // 1. layout divider
    final dividerConstraints = switch (direction) {
      Axis.horizontal => BoxConstraints(
          minWidth: 0,
          maxWidth: size.width,
          minHeight: size.height,
          maxHeight: size.height,
        ),
      Axis.vertical => BoxConstraints(
          minWidth: size.width,
          maxWidth: size.width,
          minHeight: 0,
          maxHeight: size.height,
        ),
    };

    final Size(width: dividerWidth, height: dividerHeight) =
        layoutChild(divider, dividerConstraints);

    final dividerExtent = switch (direction) {
      Axis.horizontal => dividerWidth,
      Axis.vertical => dividerHeight,
    };

    // 2. layout secondary pane
    final secondaryExtent = clampDouble(
      isAbsolute
          ? secondarySize
          : (mainAxisExtent * secondarySize) - dividerExtent,
      0.0,
      mainAxisExtent,
    );

    final secondaryConstraints = switch (direction) {
      Axis.horizontal => BoxConstraints.tightFor(
          width: secondaryExtent,
          height: size.height,
        ),
      Axis.vertical => BoxConstraints.tightFor(
          width: size.width,
          height: secondaryExtent,
        ),
    };

    layoutChild(secondary, secondaryConstraints);

    positionChild(secondary, Offset.zero);

    // 3. position divider

    final dividerPosition = clampDouble(
      secondaryExtent,
      0.0,
      mainAxisExtent - dividerExtent,
    );

    final dividerOffset = switch (direction) {
      Axis.horizontal => Offset(dividerPosition, 0),
      Axis.vertical => Offset(0, dividerPosition),
    };

    positionChild(divider, dividerOffset);

    // 4. layout primary pane
    final dividerBleed = clampDouble(secondaryExtent / dividerExtent, 0, 1);

    var primarySize = clampDouble(
      mainAxisExtent - secondaryExtent - dividerExtent * dividerBleed,
      0,
      mainAxisExtent,
    );

    final primaryConstraints = switch (direction) {
      Axis.horizontal => BoxConstraints.tightFor(
          width: primarySize,
          height: size.height,
        ),
      Axis.vertical => BoxConstraints.tightFor(
          height: primarySize,
          width: size.width,
        ),
    };

    layoutChild(primary, primaryConstraints);

    final primaryOffset = switch (direction) {
      Axis.horizontal => Offset(mainAxisExtent - primarySize, 0),
      Axis.vertical => Offset(0, mainAxisExtent - primarySize),
    };

    positionChild(primary, primaryOffset);
  }

  @override
  bool shouldRelayout(covariant SplitPaneLayoutDelegate oldDelegate) {
    return secondarySize != oldDelegate.secondarySize ||
        isAbsolute != oldDelegate.isAbsolute ||
        direction != oldDelegate.direction;
  }
}
