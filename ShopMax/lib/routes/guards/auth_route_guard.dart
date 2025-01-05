import '/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Auth Route Guard
|--------------------------------------------------------------------------
| Checks if the User is authenticated.
|
| * [Tip] Create new route guards using the CLI 🚀
| Run the below in the terminal to create a new route guard.
| "dart run nylo_framework:main make:route_guard check_subscription"
|
| Learn more https://nylo.dev/docs/6.x/router#route-guards
|-------------------------------------------------------------------------- */

class AuthRouteGuard extends NyRouteGuard {
  AuthRouteGuard();

  @override
  onRequest(PageRequest pageRequest) async {

    bool isLoggedIn = (await Auth.isAuthenticated());
    if (!isLoggedIn) {
      return redirect(HomePage.path);
    }

    return pageRequest;
  }
}
