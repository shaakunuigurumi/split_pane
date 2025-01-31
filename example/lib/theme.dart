import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(seedColor: Colors.purple);

final theme = ThemeData.from(colorScheme: colorScheme).copyWith(
  scaffoldBackgroundColor: colorScheme.surfaceContainer,
  iconTheme: IconThemeData(opticalSize: 24),
);
