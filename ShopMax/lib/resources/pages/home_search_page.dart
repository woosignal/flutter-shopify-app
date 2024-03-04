//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/product_search_page.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/woosignal_ui.dart';

class HomeSearchPage extends NyStatefulWidget {
  static String path = "/home-search";

  HomeSearchPage() : super(path, child: _HomeSearchPageState());
}

class _HomeSearchPageState extends NyState<HomeSearchPage> {
  _HomeSearchPageState();

  final TextEditingController _txtSearchController = TextEditingController();

  _actionSearch() {
    String search = _txtSearchController.text;
    validate(rules: {
      "search": [search, "not_empty"]
    }, onSuccess: () {
      routeTo(ProductSearchPage.path, data: search, onPop: (value) {
        if (["notic", "compo"]
            .contains(AppHelper.instance.shopifyAppConfig?.theme) ==
            false) {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NyTextField.compact(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: _txtSearchController,
              style: Theme.of(context).textTheme.displaySmall,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autoFocus: true,
              backgroundColor: Colors.grey.shade100,
              textCapitalization: TextCapitalization.sentences,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: PrimaryButton(
                title: trans("Search"),
                action: _actionSearch,
              ),
            )
          ],
        ),
      ),
    );
  }
}
