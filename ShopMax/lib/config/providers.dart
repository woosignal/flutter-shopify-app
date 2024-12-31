import '/app/providers/firebase_provider.dart';

import '/app/providers/woosignal_provider.dart';
import '/app/providers/push_notifications_provider.dart';
import '/app/providers/app_provider.dart';
import '/app/providers/event_provider.dart';
import '/app/providers/route_provider.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Providers
|--------------------------------------------------------------------------
| Add your "app/providers" here.
| Providers are booted when your application start.
|
| Learn more: https://nylo.dev/docs/6.x/providers
|-------------------------------------------------------------------------- */

final Map<Type, NyProvider> providers = {
  AppProvider: AppProvider(),
  RouteProvider: RouteProvider(),
  EventProvider: EventProvider(),
  PushNotificationsProvider: PushNotificationsProvider(),
  FirebaseProvider: FirebaseProvider(),
  WoosignalProvider: WoosignalProvider(),
};
