import '/config/keys.dart';
import '/app/forms/style/form_style.dart';
import '/config/form_casts.dart';
import '/config/decoders.dart';
import '/config/design.dart';
import '/config/theme.dart';
import '/config/validation_rules.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    FormStyle formStyle = FormStyle();

    nylo.addLoader(loader);
    nylo.addLogo(logo);
    nylo.addThemes(appThemes);
    nylo.addToastNotification(getToastNotificationWidget);
    nylo.addValidationRules(validationRules);
    nylo.addModelDecoders(modelDecoders);
    nylo.addControllers(controllers);
    nylo.addApiDecoders(apiDecoders);
    nylo.addFormCasts(formCasts);
    nylo.useErrorStack();
    nylo.addFormStyle(formStyle);
    nylo.addAuthKey(Keys.auth);
    await nylo.syncKeys(Keys.syncedOnBoot);

    // Optional
    // nylo.showDateTimeInLogs(); // Show date time in logs
    // nylo.monitorAppUsage(); // Monitor the app usage

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {}
}
