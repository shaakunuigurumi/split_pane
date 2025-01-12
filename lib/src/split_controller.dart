import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class SplitController extends ChangeNotifier {
  late final AnimationController _animationController;

  bool isAbsolute = false;

  /// The current position of the split pane.
  ///
  /// If [isAbsolute] is true, this value is the absolute position of the split
  /// pane, otherwise it is a double ranging from 0 to 1, relative to the
  /// container's size.
  double position = 0.5;

  SplitController({required TickerProvider vsync}) {
    _animationController = AnimationController.unbounded(
      value: position,
      vsync: vsync,
    );
  }

  bool get leadingCollapsed => position <= 0.0;

  bool get trailingCollapsed => position >= 1.0;

  Animation<double> get animation => _animationController.view;

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

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

  void setToFixed(double value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value');
    }

    position = _animationController.value = value;
    isAbsolute = true;
    notifyListeners();
  }

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
