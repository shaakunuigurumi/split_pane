import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:split_pane/split_pane.dart';

class SwitchPaneButton extends StatelessWidget {
  final VoidCallback onPressed;
  final PaneLocation paneLocation;
  final Axis direction;

  const SwitchPaneButton({
    super.key,
    required this.onPressed,
    required this.paneLocation,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: 'Switch panes',
      icon: buildIcon(),
    );
  }

  Widget buildIcon() {
    return switch ((paneLocation, direction)) {
      (PaneLocation.leading, Axis.horizontal) => Icon(Symbols.dock_to_left),
      (PaneLocation.leading, Axis.vertical) => Transform.flip(
          flipY: true,
          child: Icon(Symbols.dock_to_bottom),
        ),
      (PaneLocation.trailing, Axis.horizontal) => Icon(Symbols.dock_to_right),
      (PaneLocation.trailing, Axis.vertical) => Icon(Symbols.dock_to_bottom),
    };
  }
}
