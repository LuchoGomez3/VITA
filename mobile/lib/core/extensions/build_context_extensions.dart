import 'package:flutter/material.dart';

/// Convenience accessors for common theme values on [BuildContext].
extension BuildContextExtensions on BuildContext {
  /// Current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;
}
