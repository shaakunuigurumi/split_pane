import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Controls a [SplitPane].
class SplitController extends ChangeNotifier {
  late final AnimationController _animationController;

  /// Whether the current position of the split pane is absolute.
  ///
  /// If true, the [position] value is the absolute position of the split pane
  /// in dp. If false, the [position] value is a fraction of the container size
  /// (e.g. `0.5` for 50%).

  bool isAbsolute = false;

  /// The current position .
  ///
  /// See also:
  ///
  /// - [isAbsolute], which determines whether this value is absolute or a fraction.
  double position = 0.5;

  /// Creates a new [SplitController].
  SplitController({required TickerProvider vsync}) {
    _animationController = AnimationController.unbounded(
      value: position,
      vsync: vsync,
    );
  }

  /// Whether the leading pane is collapsed.
  bool get leadingCollapsed => position <= 0.0;

  /// Whether the trailing pane is collapsed.
  bool get trailingCollapsed => position >= 1.0;

  /// Animated value of the [position].
  Animation<double> get animation => _animationController.view;

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  /// Animates the split pane to a [fraction] of the [containerSize].
  void animateToFraction(
    double fraction,
    double containerSize,
    Duration duration,
    Curve curve,
  ) {
    if (containerSize < 0 || containerSize.isInfinite) {
      throw ArgumentError.value(containerSize, 'containerSize');
    }

    if (fraction < 0 || fraction > 1.0) {
      throw ArgumentError.value(fraction, 'fraction');
    }

    if (isAbsolute) {
      setToFraction(_animationController.value / containerSize);
    }

    _animationController.animateTo(
      position = fraction,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Animates the split pane to a fixed [value].
  void animateToFixed(
    double value,
    double containerSize,
    Duration duration,
    Curve curve,
  ) {
    if (containerSize < 0 || containerSize.isInfinite) {
      throw ArgumentError.value(containerSize, 'containerSize');
    }

    if (value < 0 || value > containerSize) {
      throw ArgumentError.value(value, 'value');
    }

    if (!isAbsolute) {
      setToFixed(_animationController.value * containerSize);
    }

    _animationController.animateTo(
      position = value,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Sets the split pane to an fixed size of the following [value].
  void setToFixed(double value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value');
    }

    position = _animationController.value = value;
    isAbsolute = true;
    notifyListeners();
  }

  /// Sets the split pane to a fraction of the following [value].
  void setToFraction(double value) {
    if (value < 0 || value > 1.0) {
      throw ArgumentError.value(value, 'value');
    }

    position = _animationController.value = value;
    isAbsolute = false;
    notifyListeners();
  }

  double getFraction(double containerSize) {
    if (isAbsolute) {
      return _animationController.value / containerSize;
    }

    return _animationController.value;
  }

  double getFixed(double containerSize) {
    if (!isAbsolute) {
      return _animationController.value * containerSize;
    }

    return _animationController.value;
  }
}
