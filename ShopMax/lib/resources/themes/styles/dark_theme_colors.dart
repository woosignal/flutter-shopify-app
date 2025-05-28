import 'package:flutter/material.dart';
import '../../../bootstrap/helpers.dart';
import '/resources/themes/styles/color_styles.dart';

/* Dark Theme Colors
|-------------------------------------------------------------------------- */

class DarkThemeColors implements ColorStyles {
  Map<String, dynamic>? get colors => getThemeColorForTemplate();

  Color themeColor(String key) {
    if (colors == null || (colors?.isEmpty ?? false)) {
      return Colors.white;
    }

    return Color(int.parse(colors?['dark'][key]));
  }

  // general
  @override
  Color get background => themeColor('background');
  @override
  Color get backgroundContainer => const Color(0xFF4a4a4a);

  @override
  Color get content => themeColor('primary_text');
  @override
  Color get primaryAccent => const Color(0xffa0baff);

  @override
  Color get surfaceBackground => Colors.white70;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => themeColor('app_bar_background');
  @override
  Color get appBarPrimaryContent => themeColor('app_bar_text');

  // buttons
  @override
  Color get buttonBackground => themeColor('button_background');
  @override
  Color get buttonContent => themeColor('button_text');

  @override
  Color get buttonSecondaryBackground => Colors.grey.shade800;
  @override
  Color get buttonSecondaryContent => Colors.white70;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.white70;
  @override
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.white54;
  @override
  Color get bottomTabBarLabelSelected => Colors.white;

  // toast notification
  @override
  Color get toastNotificationBackground => const Color(0xff3e4447);
}
