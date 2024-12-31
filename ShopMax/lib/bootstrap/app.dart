import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Main entry point for the application
class Main extends StatelessWidget {
  final String? initialRoute;
  final ThemeMode themeMode;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Route<dynamic>? Function(RouteSettings settings) onGenerateRoute;
  final Route<dynamic>? Function(RouteSettings settings) onUnknownRoute;

  Main(
    Nylo nylo, {
    super.key,
  })  : onGenerateRoute = nylo.router!.generator(),
        onUnknownRoute = nylo.router!.unknownRoute(),
        navigatorKey = NyNavigator.instance.router.navigatorKey,
        initialRoute = nylo.getInitialRoute(),
        navigatorObservers = nylo.getNavigatorObservers(),
        themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    List<AppTheme> appThemes = Nylo.getAppThemes();
    return Container(
      color: Colors.white,
      child: LocalizedApp(
        child: ThemeProvider(
          themes: appThemes,
          child: ThemeConsumer(
            child: ValueListenableBuilder(
              valueListenable: ValueNotifier(NyLocalization.instance.locale),
              builder: (context, Locale locale, _) => MaterialApp(
                navigatorKey: navigatorKey,
                themeMode: themeMode,
                navigatorObservers: navigatorObservers,
                debugShowMaterialGrid: false,
                showPerformanceOverlay: false,
                checkerboardRasterCacheImages: false,
                checkerboardOffscreenLayers: false,
                showSemanticsDebugger: false,
                debugShowCheckedModeBanner: false,
                darkTheme: appThemes.darkTheme,
                initialRoute: initialRoute,
                onGenerateRoute: onGenerateRoute,
                onUnknownRoute: onUnknownRoute,
                theme: ThemeProvider.themeOf(context).data,
                localeResolutionCallback:
                    (Locale? locale, Iterable<Locale> supportedLocales) {
                  return locale;
                },
                localizationsDelegates: NyLocalization.instance.delegates,
                locale: locale,
                supportedLocales: [Locale('en', 'US')],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
