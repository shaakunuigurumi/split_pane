import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplitPaneThemeData extends ThemeExtension<SplitPaneThemeData>
    with Diagnosticable {
  final Curve? snapCurve;
  final Duration? snapDuration;
  final WidgetStateProperty<Color>? dragHandleColor;

  const SplitPaneThemeData({
    this.snapCurve,
    this.snapDuration,
    this.dragHandleColor,
  });

  @override
  SplitPaneThemeData copyWith({
    Curve? snapCurve,
    Duration? snapDuration,
    WidgetStateProperty<Color>? dragHandleColor,
  }) {
    return SplitPaneThemeData(
      snapCurve: snapCurve ?? this.snapCurve,
      snapDuration: snapDuration ?? this.snapDuration,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
    );
  }

  @override
  ThemeExtension<SplitPaneThemeData> lerp(SplitPaneThemeData? other, double t) {
    return SplitPaneThemeData(
      snapCurve: t > 0.5 ? other?.snapCurve : snapCurve,
      snapDuration: t > 0.5 ? other?.snapDuration : snapDuration,
      dragHandleColor: t > 0.5 ? other?.dragHandleColor : dragHandleColor,
    );
  }

  SplitPaneThemeData merge(SplitPaneThemeData data) {
    return SplitPaneThemeData(
      snapCurve: snapCurve ?? data.snapCurve,
      snapDuration: snapDuration ?? data.snapDuration,
      dragHandleColor: dragHandleColor ?? data.dragHandleColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<Curve>(
        'snapCurve',
        snapCurve,
        defaultValue: null,
      ),
    );

    properties.add(
      DiagnosticsProperty<Duration>(
        'snapDuration',
        snapDuration,
        defaultValue: null,
      ),
    );

    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color>?>(
        'dragHandleColor',
        dragHandleColor,
        defaultValue: null,
      ),
    );
  }
}
