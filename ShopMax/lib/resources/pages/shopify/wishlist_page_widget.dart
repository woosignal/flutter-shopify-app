//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/extensions.dart';
import 'package:flutter_app/resources/pages/shopify/product_detail_page.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/shopify_product_response.dart';

class WishListPageWidget extends NyStatefulWidget {
  static String path = "/wishlist";
  WishListPageWidget() : super(path, child: _WishListPageWidgetState());
}

class _WishListPageWidgetState extends NyState<WishListPageWidget> {
  bool? hasNextPage = true;
  String? endCursor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Wishlist")),
      ),
      body: SafeAreaWidget(
        child: NyPullToRefresh.grid(
          crossAxisCount: 1,
          mainAxisSpacing: 20,
          data: (page) async {
            if (hasNextPage == false) return [];
            List<String> favouriteProducts = await getWishlistProducts();
            ShopifyProductResponse? shopifyProductResponse =
                await (appWooSignalShopify(
                    (api) => api.getProductsJson(ids: favouriteProducts.map((e) => int.parse(e)).toList())));
            if (shopifyProductResponse?.pageInfo?.hasNextPage != true) {
              hasNextPage = false;
            }
            endCursor = shopifyProductResponse?.pageInfo?.endCursor;
            return shopifyProductResponse?.products ?? [];
          },
          child: (context, product) {
            product as ShopifyProduct;
            return Container(
              child: Row(
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedImageWidget(
                        image: (product.featuredImage?.url != null
                            ? product.featuredImage!.url
                            : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 4,
                  ).paddingOnly(right: 8),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.title ?? "",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.priceRange?.minVariantPrice?.amount
                                    .toMoney() ??
                                "",
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 5,
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => _removeFromWishlist(product),
                    ),
                  )
                ],
              ),
            ).onTapRoute(ProductDetailPage.path, data: product.uId);
          },
          empty: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 40,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                Text(trans("No items found"),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .setColor(context, (color) => color!.primaryContent))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _removeFromWishlist(ShopifyProduct product) async {
    await removeWishlistProduct(productId: product.id ?? "");
    showToastNotification(
      context,
      title: trans('Success'),
      icon: Icons.shopping_cart,
      description: trans('Item removed'),
    );
    setState(() {});
  }
}
