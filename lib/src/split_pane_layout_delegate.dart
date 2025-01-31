import 'package:flutter/rendering.dart';

/// A layout delegate for the [SplitPane] widget.
class SplitPaneLayoutDelegate extends MultiChildLayoutDelegate {
  /// The size of the secondary pane.
  final double secondarySize;

  /// Whether the secondary pane size is absolute.
  final bool isAbsolute;

  /// In which direction the split pane is split.
  final Axis direction;

  /// Whether to invert the order of the panes.
  final bool invertPaneOrder;

  /// Creates a new [SplitPaneLayoutDelegate].
  SplitPaneLayoutDelegate({
    required this.secondarySize,
    required this.isAbsolute,
    required this.direction,
    required this.invertPaneOrder,
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
    final availableExtent = mainAxisExtent - dividerExtent;

    double primaryExtent;
    double secondaryExtent;

    if (isAbsolute) {
      secondaryExtent = secondarySize;
      primaryExtent = availableExtent - secondaryExtent;
    } else {
      secondaryExtent = availableExtent * secondarySize;
      primaryExtent = availableExtent - secondaryExtent;
    }

    primaryExtent = primaryExtent.clamp(0.0, mainAxisExtent);
    secondaryExtent = secondaryExtent.clamp(0.0, mainAxisExtent);

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

    final primaryConstraints = switch (direction) {
      Axis.horizontal => BoxConstraints.tightFor(
          width: primaryExtent,
          height: size.height,
        ),
      Axis.vertical => BoxConstraints.tightFor(
          width: size.width,
          height: primaryExtent,
        ),
    };

    if (invertPaneOrder) {
      positionChild(primary, Offset.zero);

      final secondaryOffset = mainAxisExtent - secondaryExtent;

      positionChild(
        secondary,
        switch (direction) {
          Axis.horizontal => Offset(secondaryOffset, 0),
          Axis.vertical => Offset(0, secondaryOffset),
        },
      );
    } else {
      positionChild(secondary, Offset.zero);

      final primaryOffset = mainAxisExtent - primaryExtent;

      positionChild(
        primary,
        switch (direction) {
          Axis.horizontal => Offset(primaryOffset, 0),
          Axis.vertical => Offset(0, primaryOffset),
        },
      );
    }

    layoutChild(primary, primaryConstraints);
    layoutChild(secondary, secondaryConstraints);

    final leadingPaneExtent = invertPaneOrder ? primaryExtent : secondaryExtent;
    positionChild(
      divider,
      switch (direction) {
        Axis.horizontal => Offset(leadingPaneExtent, 0),
        Axis.vertical => Offset(0, leadingPaneExtent),
      },
    );
  }

  @override
  bool shouldRelayout(covariant SplitPaneLayoutDelegate oldDelegate) {
    return secondarySize != oldDelegate.secondarySize ||
        isAbsolute != oldDelegate.isAbsolute ||
        direction != oldDelegate.direction ||
        invertPaneOrder != oldDelegate.invertPaneOrder;
  }
}
