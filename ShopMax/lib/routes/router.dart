import '/resources/pages/notifications_page.dart';
import '/resources/pages/forgot_password_page.dart';
import '/resources/pages/browse_categories_page.dart';
import '/resources/pages/account_delete_page.dart';
import '/resources/pages/account_landing_page.dart';
import '/resources/pages/login_page.dart';
import '/resources/pages/account_order_detail_page.dart';
import '/resources/pages/account_profile_update_page.dart';
import '/resources/pages/register_page.dart';
import '/resources/pages/account_shipping_details_page.dart';
import '/resources/pages/product_search_page.dart';
import '/resources/pages/cart_page.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/pages/checkout_details_page.dart';
import '/resources/pages/checkout_payment_type_page.dart';
import '/resources/pages/checkout_shipping_type_page.dart';
import '/resources/pages/checkout_status_page.dart';
import '/resources/pages/customer_countries_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/home_search_page.dart';
import '/resources/pages/no_connection_page.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/pages/product_image_viewer_page.dart';
import '/resources/pages/wishlist_page.dart';
import '/routes/guards/auth_profile_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
  router.add(HomePage.path).initialRoute();

  router.add(CartPage.path);

  router.add(CheckoutConfirmationPage.path);

  router.add(ProductSearchPage.path,
      transition: PageTransitionType.fade);

  router.add(ProductDetailPage.path);

  router.add(
      ProductImageViewerPage.path,
      transition: PageTransitionType.fade);

  router.add(WishListPage.path);

  router.add(
      AccountOrderDetailPage.path);

  router.add(CheckoutStatusPage.path);

  router.add(CheckoutDetailsPage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(
      CheckoutPaymentTypePage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(CheckoutShippingTypePage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(HomeSearchPage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(
      CustomerCountriesPage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(NoConnectionPage.path);

  // Account Section

  router.add(LoginPage.path,
      transition: PageTransitionType.bottomToTop);

  router.add(RegisterPage.path);

  router.add(AccountLandingPage.path,
      routeGuards: [AuthProfileRouteGuard()]);

  router.add(AccountProfileUpdatePage.path);

  router.add(AccountDeletePage.path);

  router.add(AccountShippingDetailsPage.path);

  router.add(
      BrowseCategoriesPage.path);

  router.add(ForgotPasswordPage.path);

  router.add(NotificationsPage.path);
});
