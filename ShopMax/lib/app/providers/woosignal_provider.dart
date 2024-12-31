import 'package:nylo_framework/nylo_framework.dart';
import '../../config/localization.dart';
import '/bootstrap/helpers.dart';
import '/bootstrap/app_helper.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart' as shopify;
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart'
as shopify;

class WoosignalProvider implements NyProvider {

  @override
  boot(Nylo nylo) async {

    await shopify.WooSignalShopify.instance.init(
      appKey: getEnv('APP_KEY'),
      debugMode: getEnv('APP_DEBUG'),
      encryptKey: getEnv('ENCRYPT_KEY'),
      encryptSecret: getEnv('ENCRYPT_SECRET'),
    );

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

    Locale? locale;

    if (wooSignalApp != null) {
      AppHelper.instance.shopifyAppConfig = wooSignalApp;

      if (getEnv('DEFAULT_LOCALE', defaultValue: null) == null &&
          wooSignalApp.locale != null) {
        locale = Locale(wooSignalApp.locale!);
      } else {
        locale = Locale(getEnv('DEFAULT_LOCALE', defaultValue: 'en'));
      }
    }

    await NyLocalization.instance.init(
      localeType: localeType,
      languageCode: locale?.languageCode ?? languageCode,
      assetsDirectory: assetsDirectory,
    );
   
     return nylo;
  }
  
  @override
  afterBoot(Nylo nylo) async {
   
     // Called after Nylo has finished booting
     // ...
  }
}
