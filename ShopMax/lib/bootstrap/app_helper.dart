//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class AppHelper {
  AppHelper._privateConstructor();

  static final AppHelper instance = AppHelper._privateConstructor();

  WooSignalApp? shopifyAppConfig;
}
