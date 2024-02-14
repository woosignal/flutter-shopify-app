import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/bootstrap/app_helper.dart';
import '/config/font.dart';
import '/resources/themes/styles/color_styles.dart';
import '/resources/themes/text_theme/default_text_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Light Theme
|--------------------------------------------------------------------------
| Theme Config - config/theme.dart
|-------------------------------------------------------------------------- */

ThemeData lightTheme(ColorStyles lightColors) {
  if (AppHelper.instance.shopifyAppConfig != null) {
    try {
      appFont = GoogleFonts.getFont(
          AppHelper.instance.shopifyAppConfig?.themeFont ?? "Poppins");
    } on Exception catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        NyLogger.error(e.toString());
      }
    }
  }

  TextTheme lightTheme =
      getAppTextTheme(appFont, defaultTextTheme.merge(_textTheme(lightColors)));

  return ThemeData(
    useMaterial3: true,
    primaryColor: lightColors.primaryContent,
    primaryColorLight: lightColors.primaryAccent,
    focusColor: lightColors.primaryContent,
    scaffoldBackgroundColor: lightColors.background,
    hintColor: lightColors.primaryAccent,
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: lightColors.appBarBackground,
      titleTextStyle: lightTheme.titleLarge!
          .copyWith(color: lightColors.appBarPrimaryContent),
      iconTheme: IconThemeData(color: lightColors.appBarPrimaryContent),
      elevation: 1.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightColors.buttonPrimaryContent,
      colorScheme: ColorScheme.light(primary: lightColors.buttonBackground),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: lightColors.primaryContent),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: lightColors.buttonPrimaryContent,
          backgroundColor: lightColors.buttonBackground),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightColors.bottomTabBarBackground,
      unselectedIconTheme:
          IconThemeData(color: lightColors.bottomTabBarIconUnselected),
      selectedIconTheme:
          IconThemeData(color: lightColors.bottomTabBarIconSelected),
      unselectedLabelStyle:
          TextStyle(color: lightColors.bottomTabBarLabelUnselected),
      selectedLabelStyle:
          TextStyle(color: lightColors.bottomTabBarLabelSelected),
      selectedItemColor: lightColors.bottomTabBarLabelSelected,
    ),
    textTheme: lightTheme,
    colorScheme: ColorScheme.light(
        background: lightColors.background,
        primary: lightColors.primaryContent),
  );
}

/*
|--------------------------------------------------------------------------
| Light Text Theme
|--------------------------------------------------------------------------
*/

TextTheme _textTheme(ColorStyles colors) {
  Color primaryContent = colors.primaryContent;
  TextTheme textTheme = TextTheme().apply(displayColor: primaryContent);
  return textTheme.copyWith(
    labelLarge: TextStyle(color: primaryContent.withOpacity(0.8)),
    bodyMedium: TextStyle(color: primaryContent.withOpacity(0.8)),
  );
}
