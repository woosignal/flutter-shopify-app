import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';

class DeleteAccountEvent implements NyEvent {
  @override
  final listeners = {
    _DefaultListener: _DefaultListener(),
  };
}

class _DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    AuthCustomerInfo? authCustomerInfo =
        await appWooSignalShopify((api) => api.authCustomer());
    if (authCustomerInfo == null) {
      return;
    }

    String body = """
Dear ${getEnv('APP_NAME')},

I hope this email finds you well. I am reaching out to formally request the deletion of my customer account associated with ${getEnv('APP_NAME')}.

Please find below the details of my account:

Account Email Address: ${authCustomerInfo.email}

I understand that by requesting the deletion of my account, all associated data will be permanently removed from your system, including order history and personal information. I have reviewed this decision and am aware of the consequences.

I kindly request that you proceed with the deletion of my account at your earliest convenience. If there are any specific steps or procedures I need to follow to complete this process, please do not hesitate to inform me.

I would appreciate receiving confirmation once my account has been successfully deleted. Should there be any further actions required from my end, please do not hesitate to let me know.

Thank you for your prompt attention to this matter. I would like to take this opportunity to thank your team for the services provided thus far.

Best regards,

${authCustomerInfo.firstName}
""";

    final Uri deleteAccount = Uri(
        scheme: 'mailto',
        path: getEnv('SUPPORT_EMAIL'),
        queryParameters: {
          'subject': 'Request for Account Deletion - ${getEnv('APP_NAME')}',
          'body': body
        });

    return await launchUrl(deleteAccount);
  }
}
