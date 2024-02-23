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
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:woosignal_shopify_api/models/product.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class WishListPage extends NyStatefulWidget {
  static String path = "/wishlist";
  WishListPage() : super(path, child: _WishListPageState());
}

class _WishListPageState extends NyState<WishListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Wishlist")),
      ),
      body: SafeAreaWidget(
        child: NyListView.separated(
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey.shade100,
          ),
          data: () async {
            List<String> favouriteProducts = await getWishlistProducts();
            if (favouriteProducts.isEmpty) {
              return [];
            }
            List<Product>? products = await (appWooSignalShopify((api) =>
                api.getProductsRestApi(
                    ids: favouriteProducts.map((e) => int.parse(e)).toList())));
            return products;
          },
          child: (context, product) {
            product as Product;
            return Container(
              height: 160,
              margin: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedImageWidget(
                        image: product.image?.src ??
                            getEnv("PRODUCT_PLACEHOLDER_IMAGE"),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 160,
                  ).paddingOnly(right: 8),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                alignment: Alignment.topRight,
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _removeFromWishlist(product.id.toString()),
                              ),
                            ],
                          ),
                          Text(
                            product.title ?? "",
                            style: textTheme.headlineSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.price.toMoney(),
                            style: textTheme.bodyLarge,
                          ).fontWeightBold().paddingOnly(top: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).onTapRoute(ProductDetailPage.path, data: product.id);
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

  _removeFromWishlist(String productId) async {
    await removeWishlistProduct(productId: productId);
    showToastNotification(
      context,
      title: trans('Success'),
      icon: Icons.shopping_cart,
      description: trans('Item removed'),
    );
    setState(() {});
  }
}
