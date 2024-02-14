//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/shopify/mello_theme_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class HomePage extends NyStatefulWidget {
  static String path = "/home";
  HomePage() : super(path, child: _HomePageState());
}

class _HomePageState extends State<HomePage> {
  final WooSignalApp? _wooSignalApp = AppHelper.instance.shopifyAppConfig;

  @override
  Widget build(BuildContext context) {
    Widget theme = MelloThemeWidget(wooSignalApp: _wooSignalApp);
    return theme;
  }
}
