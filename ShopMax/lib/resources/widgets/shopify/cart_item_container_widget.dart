//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/shopify/cart_line_item.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/helpers.dart';
import '../cached_image_widget.dart';

class CartItemContainer extends StatelessWidget {
  const CartItemContainer({
    super.key,
    required this.cartLineItem,
    required this.actionIncrementQuantity,
    required this.actionDecrementQuantity,
    required this.actionRemoveItem,
  });

  final CartLineItem cartLineItem;
  final void Function() actionIncrementQuantity;
  final void Function() actionDecrementQuantity;
  final void Function() actionRemoveItem;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: CachedImageWidget(
                    image: (cartLineItem.imageSrc?.isEmpty ?? true
                        ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                        : cartLineItem.imageSrc),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: Padding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          cartLineItem.title ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        (cartLineItem.variationOptions != null
                            ? Text(cartLineItem.variationOptions!,
                                style: Theme.of(context).textTheme.bodyLarge)
                            : Container()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              (!cartLineItem.inStock()
                                  ? trans("Out of stock")
                                  : trans("In Stock")),
                              style: (!cartLineItem.inStock()
                                  ? Theme.of(context).textTheme.bodySmall
                                  : Theme.of(context).textTheme.bodyMedium),
                            ),
                            Text(
                              formatDoubleCurrency(
                                total:
                                    parseWcPrice(cartLineItem.getCartTotal()),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(left: 8),
                  ),
                  flex: 5,
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: actionDecrementQuantity,
                      highlightColor: Colors.transparent,
                    ),
                    Text((cartLineItem.quantity ?? 1).toString(),
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: actionIncrementQuantity,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: Icon(Icons.delete_outline,
                      color: Colors.deepOrangeAccent, size: 20),
                  onPressed: actionRemoveItem,
                  highlightColor: Colors.transparent,
                ),
              ],
            )
          ],
        ),
      );
}
