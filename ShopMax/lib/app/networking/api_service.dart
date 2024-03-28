import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/* ApiService
|--------------------------------------------------------------------------
| Define your API endpoints
| Learn more https://nylo.dev/docs/5.20.0/networking
|-------------------------------------------------------------------------- */

class ApiService extends NyApiService {
  ApiService({BuildContext? buildContext}) : super(buildContext);

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  Map<Type, Interceptor> get interceptors => {
    PrettyDioLogger: PrettyDioLogger()
  };

  Future<dynamic> fetchTestData() async {
    return await network(
      request: (request) => request.get("/endpoint-path"),
    );
  }
}
