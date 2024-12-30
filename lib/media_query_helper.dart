import 'package:flutter/material.dart';

abstract class MediaQueryHelper {
  /// Gets the screen width
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Gets the screen height
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Checks if the device is in portrait mode
  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  /// Checks if the device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Gets the device's pixel density
  static double getDevicePixelRatio(BuildContext context) =>
      MediaQuery.devicePixelRatioOf(context);

  /// Gets the top safe area padding (useful for notches)
  static double getTopPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).top;

  /// Gets the bottom safe area padding (useful for gesture navigation)
  static double getBottomPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  /// Gets the text scale factor for scaling text
  static double getTextScaleFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1);

  /// Checks if the screen width is larger than a specified breakpoint
  static bool isLargeScreen(BuildContext context, {double breakpoint = 600}) =>
      MediaQuery.sizeOf(context).width > breakpoint;

  /// Scales a value proportionally based on screen width
  static double scaleWidth(BuildContext context, double value) =>
      value * MediaQuery.sizeOf(context).width / 375;

  /// Scales a value proportionally based on screen height
  static double scaleHeight(BuildContext context, double value) =>
      value * MediaQuery.sizeOf(context).height / 812;
}
