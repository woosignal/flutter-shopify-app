//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/notification_icon_widget.dart';
import 'package:woosignal_shopify_api/models/response/collection_item_response.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/home_search_page.dart';
import '/resources/widgets/cached_image_widget.dart';
import '/resources/widgets/cart_icon_widget.dart';
import 'home_drawer_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/shopify_product_response.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class MelloThemeWidget extends StatefulWidget {
  MelloThemeWidget({super.key, required this.wooSignalApp});
  final WooSignalApp? wooSignalApp;

  @override
  createState() => _MelloThemeWidgetState();
}

class _MelloThemeWidgetState extends NyState<MelloThemeWidget> {
  bool? hasNextPage = true;
  String? endCursor;
  List<Collections> _collections = [];

  @override
  boot() async {
    await _fetchCollectionData();
  }

  _fetchCollectionData() async {
    if (_collections.isNotEmpty) {
      return;
    }
    if (widget.wooSignalApp == null) {
      return;
    }
    List<String> collectionIds = widget.wooSignalApp!.shopifyCollections
        .map((e) => e.collectionId ?? "")
        .toList();
    CollectionItem? collectionItem = await appWooSignalShopify(
        (api) => api.getCollectionsByIds(ids: collectionIds));
    if (collectionItem == null) {
      return;
    }
    setState(() {
      _collections = collectionItem.collections ?? [];
    });
  }

  @override
  Widget view(BuildContext context) {
    List<String>? bannerImages = widget.wooSignalApp!.bannerImages;
    return Scaffold(
      drawer: HomeDrawerWidget(
          wooSignalApp: widget.wooSignalApp, collections: _collections),
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () async {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              size: 35,
            ),
            onPressed: () => routeTo(HomeSearchPage.path),
          ),
          Flexible(
            child: NotificationIcon(),
          ),
          CartIconWidget(),
        ],
      ),
      body: SafeAreaWidget(
        child: NyPullToRefresh.grid(
            mainAxisSpacing: 15,
            crossAxisSpacing: 10,
            crossAxisCount: 2,
            header: (bannerImages?.isNotEmpty ?? false)
                ? Column(children: [
                    Container(
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return CachedImageWidget(
                            image: bannerImages?[index],
                            fit: BoxFit.contain,
                          );
                        },
                        itemCount: bannerImages?.length ?? 0,
                        viewportFraction: 0.8,
                        scale: 0.9,
                      ),
                      height: MediaQuery.of(context).size.height / 3.5,
                    ),
                  ])
                : null,
            child: (context, data) {
              data as ShopifyProduct;
              return ProductItem.fromShopifyProduct(data);
            },
            data: (int iteration) async {
              if (hasNextPage == false) return [];
              ShopifyProductResponse product = await appWooSignalShopify(
                  (api) => api.getProducts(after: endCursor, first: 50));
              if (product.pageInfo?.hasNextPage != true) {
                hasNextPage = false;
              }
              endCursor = product.pageInfo?.endCursor;
              return product.products;
            },
            beforeRefresh: () {
              hasNextPage = true;
              endCursor = null;
            }),
      ),
    );
  }
}
