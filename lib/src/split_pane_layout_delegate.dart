import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';

class SplitPaneLayoutDelegate extends MultiChildLayoutDelegate {
  final double secondarySize;
  final bool isAbsolute;
  final double spacerWidth = 24;

  SplitPaneLayoutDelegate({
    required this.secondarySize,
    required this.isAbsolute,
  });

  @override
  void performLayout(Size size) {
    const divider = 0;
    const primary = 1;
    const secondary = 2;

    // 1. layout divider
    final dividerConstraints = BoxConstraints(
      minWidth: 0,
      maxWidth: size.width,
      minHeight: size.height,
      maxHeight: size.height,
    );

    final Size(width: dividerWidth) = layoutChild(divider, dividerConstraints);

    // 2. layout secondary pane
    final secondaryWidth = clampDouble(
      isAbsolute ? secondarySize : size.width * secondarySize,
      0.0,
      size.width,
    );

    layoutChild(
      secondary,
      BoxConstraints.tightFor(width: secondaryWidth, height: size.height),
    );

    positionChild(secondary, Offset.zero);

    // 3. position divider

    final dividerLeft = clampDouble(
      secondaryWidth,
      0.0,
      size.width - dividerWidth,
    );
    final dividerPosition = Offset(dividerLeft, 0);
    positionChild(divider, dividerPosition);

    // 4. layout primary pane

    final dividerBleed = clampDouble(secondaryWidth / dividerWidth, 0, 1);


    var primaryWidth = clampDouble(
      size.width - secondaryWidth - dividerWidth * dividerBleed,
      0,
      size.width,
    );

    final primaryConstraints = BoxConstraints.tightFor(
      width: primaryWidth,
      height: size.height,
    );

    layoutChild(primary, primaryConstraints);

    positionChild(primary, Offset(size.width - primaryWidth, 0));
  }

  @override
  bool shouldRelayout(covariant SplitPaneLayoutDelegate oldDelegate) {
    return secondarySize != oldDelegate.secondarySize ||
        isAbsolute != oldDelegate.isAbsolute;
  }
}
