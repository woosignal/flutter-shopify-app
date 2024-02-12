//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/shopify_product_response.dart';

class WishListPageWidget extends NyStatefulWidget {
  static String path = "/wishlist";
  WishListPageWidget() : super(path, child: _WishListPageWidgetState());
}

class _WishListPageWidgetState extends NyState<WishListPageWidget> {
  List<ShopifyProduct> _products = [];

  @override
  boot() async {
    await loadProducts();
  }

  loadProducts() async {
    List<dynamic> favouriteProducts = await getWishlistProducts();
    List<int> productIds =
        favouriteProducts.map((e) => e['id']).cast<int>().toList();
    if (productIds.isEmpty) {
      return;
    }
    _products = await (appWooSignalShopify((api) => api.getProducts()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Wishlist")),
      ),
      body: SafeArea(
        child: afterLoad(
            child: () => _products.isEmpty
                ? Center(
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
                                .setColor(
                                    context, (color) => color!.primaryContent))
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(top: 10),
                    itemBuilder: (BuildContext context, int index) {
                      ShopifyProduct product = _products[index];
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                            context, "/product-detail",
                            arguments: product),
                        child: Container(
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: CachedImageWidget(
                                  image: (product.featuredImage?.url != null
                                      ? product.featuredImage!.url
                                      : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                                width: MediaQuery.of(context).size.width / 4,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.title ?? "",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        formatStringCurrency(
                                            total: product.priceRange?.minVariantPrice?.amount),
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
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: _products.length)),
      ),
    );
  }

  _removeFromWishlist(ShopifyProduct product) async {
    await removeWishlistProduct(product: product);
    showToastNotification(
      context,
      title: trans('Success'),
      icon: Icons.shopping_cart,
      description: trans('Item removed'),
    );
    _products.remove(product);
    setState(() {});
  }
}
