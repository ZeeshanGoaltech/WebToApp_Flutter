import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double designWidth = 439.714;
  static const double designHeight = 956;

  static double w(BuildContext context, double value) {
    return value * MediaQuery.sizeOf(context).width / designWidth;
  }

  static double h(BuildContext context, double value) {
    return value * MediaQuery.sizeOf(context).height / designHeight;
  }

  static double sp(BuildContext context, double value) {
    final scale = MediaQuery.sizeOf(context).width / designWidth;
    return value * scale.clamp(0.85, 1.25);
  }

  static double r(BuildContext context, double value) {
    return w(context, value);
  }
}
