import 'package:flutter/material.dart';

/// Placeholder widget depicting a pane.
class Pane extends StatelessWidget {
  final Widget? child;

  const Pane({this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: child ?? SizedBox.expand(),
    );
  }
}
