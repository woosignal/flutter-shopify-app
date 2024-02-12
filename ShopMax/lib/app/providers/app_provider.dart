import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/config/auth.dart';
import '/config/decoders.dart';
import '/config/design.dart';
import '/config/theme.dart';
import '/config/validation_rules.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/localization.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart' as shopify;
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart'
    as shopify;

class AppProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await shopify.WooSignalShopify.instance
        .init(appKey: getEnv('APP_KEY'), debugMode: getEnv('APP_DEBUG'));

    AppHelper.instance.shopifyAppConfig = shopify.WooSignalApp();
    AppHelper.instance.shopifyAppConfig?.themeFont = "Poppins";
    AppHelper.instance.shopifyAppConfig?.themeColors = {
      'light': {
        'background': '0xFFFFFFFF',
        'primary_text': '0xFF000000',
        'button_background': '0xFF529cda',
        'button_text': '0xFFFFFFFF',
        'app_bar_background': '0xFFFFFFFF',
        'app_bar_text': '0xFF3a3d40',
      },
      'dark': {
        'background': '0xFF212121',
        'primary_text': '0xFFE1E1E1',
        'button_background': '0xFFFFFFFF',
        'button_text': '0xFF232c33',
        'app_bar_background': '0xFF2C2C2C',
        'app_bar_text': '0xFFFFFFFF',
      }
    };

    // WooSignal Setup
    shopify.WooSignalApp? wooSignalApp = await (appWooSignalShopify(
            (api) => api.getApp(encrypted: shouldEncrypt())));
    Locale locale = Locale('en');

    if (wooSignalApp != null) {
      AppHelper.instance.shopifyAppConfig = wooSignalApp;

      if (getEnv('DEFAULT_LOCALE', defaultValue: null) == null &&
          wooSignalApp.locale != null) {
        locale = Locale(wooSignalApp.locale!);
      } else {
        locale = Locale(envVal('DEFAULT_LOCALE', defaultValue: 'en'));
      }
    }

    /// NyLocalization
    await NyLocalization.instance.init(
        localeType: localeType,
        languageCode: locale.languageCode,
        languagesList: languagesList,
        assetsDirectory: assetsDirectory,
        valuesAsMap: valuesAsMap);

    nylo.addLoader(loader);
    nylo.addLogo(logo);
    nylo.addThemes(appThemes);
    nylo.addToastNotification(getToastNotificationWidget);
    nylo.addValidationRules(validationRules);
    nylo.addModelDecoders(modelDecoders);
    nylo.addControllers(controllers);
    nylo.addApiDecoders(apiDecoders);

    await login();

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {}
}
