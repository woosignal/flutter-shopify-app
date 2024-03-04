//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:woosignal_shopify_api/models/response/product_search.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/shopify_product_search_response.dart';

class ProductSearchPage extends NyStatefulWidget {
  static String path = "/product-search";

  ProductSearchPage({Key? key})
      : super(path, key: key, child: _BrowseSearchState());
}

class _BrowseSearchState extends NyState<ProductSearchPage> {
  String? _search;
  bool hasNextPage = true;
  String? cursor;

  @override
  boot() async {
    _search = widget.controller.data();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans("Search results for"),
                style: Theme.of(context).textTheme.titleMedium),
            Text("\"$_search\""),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
          child: NyPullToRefresh.grid(
        crossAxisCount: 2,
        child: (context, product) {
          product as ProductSearch;
          return ProductItem.fromShopifyProductSearch(product);
        },
        data: (int iteration) async {
          if (hasNextPage == false) return [];
          ShopifyProductSearch? productSearch = await appWooSignalShopify(
              (api) =>
                  api.productSearch(query: _search, after: cursor, first: 50));
          cursor = productSearch?.pageInfo?.endCursor;
          if (productSearch?.pageInfo?.hasNextPage != true) {
            hasNextPage = false;
          }
          return productSearch?.products ?? [];
        },
        beforeRefresh: () {
          cursor = null;
          hasNextPage = true;
        },
      )),
    );
  }
}
