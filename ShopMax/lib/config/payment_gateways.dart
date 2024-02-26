import '/app/models/payment_type.dart';
import '/app/providers/payments/paypal_pay.dart';
import '/app/providers/payments/razorpay_pay.dart';
import '/app/providers/payments/stripe_pay.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* PAYMENT GATEWAYS
|--------------------------------------------------------------------------
| Configure which payment gateways you want to use.
| Docs here: https://woosignal.com/docs/app/shopmax
|-------------------------------------------------------------------------- */

const appPaymentGateways = ["Stripe", "PayPal"];
// Available: "Stripe", "PayPal", "RazorPay"
// e.g. app_payment_gateways = ["Stripe"]; will only use Stripe.

List<PaymentType> paymentTypeList = [
  addPayment(
    id: 1,
    name: "Stripe",
    description: trans("Debit or Credit Card"),
    assetImage: "dark_powered_by_stripe.png",
    pay: stripePay,
  ),

  addPayment(
    id: 4,
    name: "PayPal",
    description: trans("Debit or Credit Card"),
    assetImage: "paypal_logo.png",
    pay: payPalPay,
  ),

  addPayment(
    id: 5,
    name: "RazorPay",
    description: trans("Debit or Credit Card"),
    assetImage: "razorpay.png",
    pay: razorPay,
  ),

  // e.g. add more here

  // addPayment(
  //   id: 6,
  //   name: "MyNewPaymentMethod",
  //   description: "Debit or Credit Card",
  //   assetImage: "add icon image to public/assets/images/myimage.png",
  //   pay: "myCustomPaymentFunction",
  // ),
];
