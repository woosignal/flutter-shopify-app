import 'package:flutter/material.dart';
import '/bootstrap/extensions.dart';
import '../../../bootstrap/helpers.dart';
import '/resources/themes/styles/color_styles.dart';

/* Light Theme Colors
|-------------------------------------------------------------------------- */

class LightThemeColors implements ColorStyles {

  Map<String, dynamic>? get colors => getThemeColorForTemplate();

  Color themeColor(String key) {
    if (colors == null || (colors?.isEmpty ?? false)) {
      return Colors.white;
    }

    return Color(int.parse(colors?['light'][key]));
  }

  // general
  @override
  Color get background => themeColor('background');
  @override
  Color get backgroundContainer => Colors.white;

  @override
  Color get content => themeColor('primary_text');
  @override
  Color get primaryAccent => const Color(0xFF0045a0);

  @override
  Color get surfaceBackground => Colors.white;
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
  Color get buttonSecondaryBackground => const Color(0xff151925);
  @override
  Color get buttonSecondaryContent => Colors.white.applyOpacity(0.9);

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.blue;
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;

  // toast notification
  @override
  Color get toastNotificationBackground => Colors.white;
}
