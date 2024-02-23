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
      router.route(HomePage.path, (context) => HomePage()).initialRoute();

      router.route(CartPage.path, (context) => CartPage());

      router.route(CheckoutConfirmationPage.path,
          (context) => CheckoutConfirmationPage());

      router.route(ProductSearchPage.path, (context) => ProductSearchPage(),
          transition: PageTransitionType.fade);

      router.route(ProductDetailPage.path, (context) => ProductDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(
          ProductImageViewerPage.path, (context) => ProductImageViewerPage(),
          transition: PageTransitionType.fade);

      router.route(WishListPage.path, (context) => WishListPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(
          AccountOrderDetailPage.path, (context) => AccountOrderDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(CheckoutStatusPage.path, (context) => CheckoutStatusPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(CheckoutDetailsPage.path, (context) => CheckoutDetailsPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          CheckoutPaymentTypePage.path, (context) => CheckoutPaymentTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route(CheckoutShippingTypePage.path,
          (context) => CheckoutShippingTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route(HomeSearchPage.path, (context) => HomeSearchPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          CustomerCountriesPage.path, (context) => CustomerCountriesPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(NoConnectionPage.path, (context) => NoConnectionPage());

      // Account Section

      router.route(LoginPage.path, (context) => LoginPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(RegisterPage.path, (context) => RegisterPage());

      router.route(AccountLandingPage.path, (context) => AccountLandingPage(),
          routeGuards: [AuthProfileRouteGuard()]);

      router.route(AccountProfileUpdatePage.path,
          (context) => AccountProfileUpdatePage());

      router.route(AccountDeletePage.path, (context) => AccountDeletePage());

      router.route(AccountShippingDetailsPage.path,
          (context) => AccountShippingDetailsPage());
      router.route(
          BrowseCategoriesPage.path, (context) => BrowseCategoriesPage());
      router.route(ForgotPasswordPage.path, (context) => ForgotPasswordPage());

    });
