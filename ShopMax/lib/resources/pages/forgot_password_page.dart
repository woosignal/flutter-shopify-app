import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ForgotPasswordPage extends NyStatefulWidget {
  static const path = '/forgot-password';

  ForgotPasswordPage() : super(path, child: _ForgotPasswordPageState());
}

class _ForgotPasswordPageState extends NyState<ForgotPasswordPage> {
  final TextEditingController _tfEmailController = TextEditingController();

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  StoreLogo(height: 100),
                  Flexible(
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(bottom: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Forgot Password".tr(),
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context).backgroundContainer,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        NyTextField.emailAddress(
                          controller: _tfEmailController,
                          validationRules: "email",
                          validationErrorMessage: "Invalid email address".tr(),
                        ),
                        PrimaryButton(
                          title: "Send Reset Email".tr(),
                          isLoading: isLocked('send_reset_email'),
                          action: _sendResetEmail,
                        ).paddingOnly(top: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            LinkButton(
              title: trans("Back"),
              action: pop,
            ),
          ],
        ),
      ),
    );
  }

  _sendResetEmail() async {
    String emailAddress = _tfEmailController.text;
    validate(
        rules: {
          "Email": [emailAddress, "email"]
        },
        onSuccess: () async {
          bool successful = await appWooSignalShopify((api) =>
              api.authCustomerForgotPassword(email: _tfEmailController.text));
          if (!successful) {
            showToastDanger(description: "Failed to send reset email".tr());
            return;
          }
          if (successful) {
            showToastSuccess(description: "Password reset email sent".tr());
            pop();
          }
        },
        lockRelease: 'send_reset_email');
  }
}
