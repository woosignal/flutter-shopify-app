import '/app/controllers/product_detail_controller.dart';

import '/app/controllers/home_controller.dart';
import '/app/models/user.dart';
import '/app/models/notification_item.dart';
import '/app/networking/api_service.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart'
as shopify;

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/6.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  shopify.AuthCustomer: (data) => shopify.AuthCustomer.fromJson(data),

  List<NotificationItem>: (data) =>
      List.from(data).map((json) => NotificationItem.fromJson(json)).toList(),

  NotificationItem: (data) => NotificationItem.fromJson(data),

  // User: (data) => User.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/6.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/6.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),
  ProductDetailController: () => ProductDetailController(),

  // ...
};
