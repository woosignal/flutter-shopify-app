import '/app/models/user.dart';
import '/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart'
    as shopify;

/*
|--------------------------------------------------------------------------
| Model Decoders
| -------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models. Learn more https://nylo.dev/docs/5.20.0/decoders#model-decoders
|--------------------------------------------------------------------------
*/

final Map<Type, dynamic> modelDecoders = {
  // ...
  User: (data) => User.fromJson(data),

  shopify.AuthCustomer: (data) => shopify.AuthCustomer.fromJson(data)
};

/*
|--------------------------------------------------------------------------
| API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
| Learn more https://nylo.dev/docs/5.20.0/decoders#api-decoders
|--------------------------------------------------------------------------
*/

final Map<Type, NyApiService> apiDecoders = {
  ApiService: ApiService(),

  // ...
};

/*
|--------------------------------------------------------------------------
| Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
| E.g. NyPage<MyController>
|
| Learn more https://nylo.dev/docs/5.20.0/controllers#using-controllers-with-ny-page
|--------------------------------------------------------------------------
*/
final Map<Type, dynamic> controllers = {
  // ...
};
