import '/resources/pages/shopify/account_delete_page.dart';
import '/resources/pages/shopify/account_landing_page.dart';
import '/resources/pages/shopify/login_page.dart';
import '/resources/pages/shopify/account_order_detail_page.dart';
import '/resources/pages/shopify/account_profile_update_page.dart';
import '/resources/pages/shopify/register_page.dart';
import '/resources/pages/shopify/account_shipping_details_page.dart';
import '/resources/pages/shopify/product_search_page.dart';
import '/resources/pages/shopify/cart_page.dart';
import '/resources/pages/shopify/checkout_confirmation_page.dart';
import '/resources/pages/shopify/checkout_details_page.dart';
import '/resources/pages/shopify/checkout_payment_type_page.dart';
import '/resources/pages/shopify/checkout_shipping_type_page.dart';
import '/resources/pages/shopify/checkout_status_page.dart';
import '/resources/pages/shopify/customer_countries_page.dart';
import '/resources/pages/shopify/home_page.dart';
import '/resources/pages/shopify/home_search_page.dart';
import '/resources/pages/shopify/no_connection_page.dart';
import '/resources/pages/shopify/product_detail_page.dart';
import '/resources/pages/shopify/product_image_viewer_page.dart';
import '/resources/pages/shopify/wishlist_page_widget.dart';
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

      router.route(WishListPageWidget.path, (context) => WishListPageWidget(),
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
    });
