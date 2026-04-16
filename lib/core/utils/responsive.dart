import 'package:convo_hub/core/constants/app_breakpoints.dart';
import 'package:flutter/widgets.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static ScreenType screenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) {
      return ScreenType.desktop;
    }
    if (width >= AppBreakpoints.tablet) {
      return ScreenType.tablet;
    }
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) => screenType(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context) => screenType(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context) => screenType(context) == ScreenType.desktop;
}