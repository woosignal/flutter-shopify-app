//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/shopify/cart.dart';
import '/app/models/shopify/cart_line_item.dart';
import '/bootstrap/enums/wishlist_action_enums.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/shopify/cart_quantity_widget.dart';
import '/resources/widgets/shopify/product_quantity_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/product.dart' as ws_shopify;
import '../controller.dart';

class ProductDetailController extends Controller {
  int quantity = 1;
  ws_shopify.Product? product;
  ws_shopify.Variants? variant;
  final Map<int, dynamic> _tmpAttributeObj = {};

  addQuantityTapped({Function? onSuccess}) {
    if (variant?.inventoryPolicy == "deny") {
      if (quantity >= (variant?.inventoryQuantity ?? 0)) {
        showToastNotification(context!,
            title: trans("Maximum quantity reached"),
            description:
                "${trans("Sorry, only")} ${variant?.inventoryQuantity} ${trans("left")}",
            style: ToastNotificationStyleType.INFO);
        return;
      }
    }

    if (quantity != 0) {
      quantity++;
      if (onSuccess != null) {
        onSuccess();
      }
      updateState(ProductQuantity.state,
          data: {"product_id": product?.id, "quantity": quantity});
    }
  }

  removeQuantityTapped({Function? onSuccess}) {
    if ((quantity - 1) >= 1) {
      quantity--;
      if (onSuccess != null) {
        onSuccess();
      }
      updateState(ProductQuantity.state,
          data: {"product_id": product?.id, "quantity": quantity});
    }
  }

  toggleWishList(
      {required Function onSuccess,
      required WishlistAction wishlistAction}) async {
    String subtitleMsg;
    if (product == null) {
      return;
    }
    if (wishlistAction == WishlistAction.remove) {
      await removeWishlistProduct(productId: product!.id.toString());
      subtitleMsg = trans("This product has been removed from your wishlist");
    } else {
      await saveWishlistProduct(productId: product!.id.toString());
      subtitleMsg = trans("This product has been added to your wishlist");
    }
    showStatusAlert(
      context,
      title: trans("Success"),
      subtitle: subtitleMsg,
      icon: Icons.favorite,
      duration: 1,
    );

    onSuccess();
  }

  ws_shopify.Variants? findProductVariation() {
    return product?.findVariation(_tmpAttributeObj);
  }

  void modalBottomSheetOptionsForAttribute(ws_shopify.Options optionObj) {
    if (optionObj.name == null) return;
    ws_shopify.Options? option = product?.getOption(optionObj.name!);
    List<String> optionValues = (option?.values ?? []);
    wsModalBottom(
      context!,
      title: "${trans("Select a")} ${option?.name}",
      bodyWidget: ListView.separated(
        itemCount: optionValues.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              optionValues[index],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(option?.position) &&
                    _tmpAttributeObj[option?.position] == optionValues[index])
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () {
              if (option?.position == null) return;
              _tmpAttributeObj[option!.position!] = optionValues[index];
              variant = findProductVariation();
              Navigator.pop(context, () {});
              Navigator.pop(context);
              _modalBottomSheetAttributes();
            },
          );
        },
      ),
    );
  }

  itemAddToCart(
      {required CartLineItem cartLineItem, Function? onSuccess}) async {
    await Cart.getInstance.addToCart(cartLineItem: cartLineItem);
    showStatusAlert(
      context,
      title: trans("Success"),
      subtitle: trans("Added to cart"),
      duration: 1,
      icon: Icons.add_shopping_cart,
    );
    updateState(CartQuantity.state);
    if (onSuccess != null) {
      onSuccess();
    }
  }

  _modalBottomSheetAttributes() {
    List<ws_shopify.Options> options = product?.options ?? [];

    wsModalBottom(
      context!,
      title: trans("Options"),
      bodyWidget: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
          color: Colors.black12,
          thickness: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          ws_shopify.Options option = options[index];
          return ListTile(
            title: Text("${option.name}",
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(option.position))
                ? Text(_tmpAttributeObj[option.position],
                    style: Theme.of(context).textTheme.bodyLarge)
                : Text("${trans("Select a")} ${option.name}"),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(option.position))
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () => modalBottomSheetOptionsForAttribute(option),
          );
        },
      ),
      extraWidget: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Text(
              (variant != null
                  ? "${trans("Price")}: ${formatStringCurrency(total: variant?.price)}"
                  : ((((product?.options ?? []).length ==
                              _tmpAttributeObj.values.length) &&
                          variant == null)
                      ? trans("This variation is unavailable")
                      : trans("Choose your options"))),
              style: Theme.of(context!).textTheme.titleMedium,
            ),
            Text(
              (variant != null
                  ? !(variant?.canPurchase ?? false)
                      ? trans("Out of stock")
                      : ""
                  : ""),
              style: Theme.of(context!).textTheme.titleMedium,
            ),
            PrimaryButton(
                title: trans("Add to cart"),
                action: () async {
                  if ((product?.options ?? []).length !=
                      _tmpAttributeObj.values.length) {
                    showToastOops(
                        description:
                            trans("Please select valid options first"));
                    return;
                  }

                  ws_shopify.Variants? variation = findProductVariation();

                  if (variation == null) {
                    showToastOops(
                        description: trans("Product variation does not exist"));
                    return;
                  }

                  if (variation.isOutOfStock()) {
                    showToastSorry(
                        description: trans("This item is not in stock"));
                    return;
                  }

                  CartLineItem cartLineItem = CartLineItem(
                    title: product?.title,
                    productId: variation.productId,
                    variationId: variation.id,
                    quantity: quantity,
                    taxable: variation.taxable,
                    inventoryPolicy: variation.inventoryPolicy,
                    inventoryQuantity: variation.inventoryQuantity,
                    imageSrc: product?.findVariationImage(variation.imageId),
                    variationOptions: variation.title,
                    metaData: {},
                    price: variation.price,
                  );

                  await itemAddToCart(cartLineItem: cartLineItem);
                  Navigator.of(context!).pop();
                }),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10),
      ),
    );
  }

  void modalBottomSheetMenu() {
    wsModalBottom(
      context!,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: Text(
          parseHtmlString(product?.bodyHtml),
        ),
      ),
    );
  }

  addItemToCart() async {
    CartLineItem cartLineItem = CartLineItem(
      title: product?.title,
      productId: product?.id,
      variationId: product?.defaultVariant?.id,
      quantity: quantity,
      taxable: product?.defaultVariant?.taxable,
      inventoryPolicy: product?.defaultVariant?.inventoryPolicy,
      inventoryQuantity: product?.defaultVariant?.inventoryQuantity,
      imageSrc: product?.images?.first.src,
      variationOptions: "",
      metaData: {},
      price: product?.price,
    );

    if (product?.hasVariations() ?? false) {
      _modalBottomSheetAttributes();
      return;
    }
    if (!(product?.defaultVariant?.canPurchase ?? false)) {
      showToastSorry(description: "This item is out of stock");
      return;
    }

    await itemAddToCart(
      cartLineItem: cartLineItem,
    );
  }
}
