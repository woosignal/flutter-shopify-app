//  ShopMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/controllers/product_detail_controller.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/enums/wishlist_action_enums.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cart_icon_widget.dart';
import '/resources/widgets/product_detail_body_widget.dart';
import '/resources/widgets/product_detail_footer_actions_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/product.dart' as shopify;
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart'
    as shopify;

class ProductDetailPage extends NyStatefulWidget<ProductDetailController> {
  static RouteView path = ("/product-detail", (_) => ProductDetailPage());

  ProductDetailPage({super.key}) : super(child: () => _ProductDetailPageState());
}

class _ProductDetailPageState extends NyPage<ProductDetailPage> {
  shopify.Product? _product;

  final shopify.WooSignalApp? _wooSignalApp =
      AppHelper.instance.shopifyAppConfig;

  @override
  get init => () async {
    String? productId = widget.controller.data();
    if (productId != null) {
      _product = await appWooSignalShopify(
          (api) => api.getProduct(productId: productId));
    }
    if (_product == null) {
      showToastOops(description: "Product not found".tr());
      pop();
      return;
    }
    widget.controller.product = _product;
  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_wooSignalApp!.wishlistEnabled!)
            NyFutureBuilder(
                future: hasAddedWishlistProduct(_product?.id),
                child: (context, dynamic isInFavourites) {
                  return isInFavourites
                      ? IconButton(
                          onPressed: () => widget.controller.toggleWishList(
                              onSuccess: () => setState(() {}),
                              wishlistAction: WishlistAction.remove),
                          icon: Icon(Icons.favorite, color: Colors.red))
                      : IconButton(
                          onPressed: () => widget.controller.toggleWishList(
                              onSuccess: () => setState(() {}),
                              wishlistAction: WishlistAction.add),
                          icon: Icon(
                            Icons.favorite_border,
                          ));
                }),
          CartIconWidget(),
        ],
        title: StoreLogo(
            height: 55,
            showBgWhite: (Theme.of(context).brightness == Brightness.dark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: afterLoad(
          child: () => Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ProductDetailBodyWidget(
                  wooSignalApp: _wooSignalApp,
                  product: _product,
                ),
              ),
              // </Product body>
              ProductDetailFooterActionsWidget(
                onAddToCart: widget.controller.addItemToCart,
                onAddQuantity: () => widget.controller.addQuantityTapped(),
                onRemoveQuantity: () =>
                    widget.controller.removeQuantityTapped(),
                product: _product,
                quantity: widget.controller.quantity,
              )
            ],
          ),
        ),
      ),
    );
  }
}
