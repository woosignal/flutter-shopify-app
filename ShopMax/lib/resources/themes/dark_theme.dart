import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/bootstrap/extensions.dart';
import '/config/design.dart';
import '/resources/themes/styles/color_styles.dart';
import '/resources/themes/text_theme/default_text_theme.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Dark Theme
|--------------------------------------------------------------------------
| Theme Config - config/theme.dart
|-------------------------------------------------------------------------- */

ThemeData darkTheme(ColorStyles color) {
  TextTheme darkTheme =
      getAppTextTheme(appFont, defaultTextTheme.merge(_textTheme(color)));
  return ThemeData(
    useMaterial3: true,
    primaryColor: color.content,
    primaryColorDark: color.content,
    focusColor: color.content,
    scaffoldBackgroundColor: color.background,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: color.appBarBackground,
        titleTextStyle:
            darkTheme.titleLarge!.copyWith(color: color.appBarPrimaryContent),
        iconTheme: IconThemeData(color: color.appBarPrimaryContent),
        elevation: 1.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark),
    buttonTheme: ButtonThemeData(
      buttonColor: color.primaryAccent,
      colorScheme: ColorScheme.light(primary: color.buttonBackground),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: color.content),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: color.buttonContent,
          backgroundColor: color.buttonBackground),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBarBackground,
      unselectedIconTheme:
          IconThemeData(color: color.bottomTabBarIconUnselected),
      selectedIconTheme: IconThemeData(color: color.bottomTabBarIconSelected),
      unselectedLabelStyle: TextStyle(color: color.bottomTabBarLabelUnselected),
      selectedLabelStyle: TextStyle(color: color.bottomTabBarLabelSelected),
      selectedItemColor: color.bottomTabBarLabelSelected,
    ),
    textTheme: darkTheme,
    colorScheme: ColorScheme.dark(
      primary: color.primaryAccent,
      onSurface: Colors.black,
    ),
  );
}

/* Dark Text Theme
|-------------------------------------------------------------------------*/

TextTheme _textTheme(ColorStyles colors) {
  TextTheme textTheme = const TextTheme()
      .apply(displayColor: colors.content, bodyColor: colors.content);
  return textTheme.copyWith(
      titleLarge: TextStyle(color: colors.content.applyOpacity(0.8)),
      labelLarge: TextStyle(color: colors.content.applyOpacity(0.8)),
      bodySmall: TextStyle(color: colors.content.applyOpacity(0.8)),
      bodyMedium: TextStyle(color: colors.content.applyOpacity(0.8)));
}
