//  StoreMob
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:woosignal_shopify_api/models/shopify_cart_product.dart';

import '/bootstrap/helpers.dart';

class CartLineItem {
  String? title;
  int? productId;
  int? variationId;
  int? quantity;
  String? inventoryPolicy;
  String? inventoryManagement;
  int? inventoryQuantity;
  String? taxCode;
  bool? taxable;
  String? price;
  String? imageSrc;
  String? variationOptions;
  double? weight;
  Object? metaData = {};
  Map<String, dynamic> appMeta = {};

  CartLineItem(
      {this.title,
      this.productId,
      this.variationId,
      this.inventoryPolicy,
      this.inventoryQuantity,
      this.inventoryManagement,
      this.quantity,
      this.variationOptions,
      this.imageSrc,
      this.taxable,
      this.price,
      this.metaData,
      this.weight});

  String getCartTotal() {
    return ((quantity ?? 1) * parseWcPrice(price)).toString();
  }

  bool inStock() {
    if (inventoryManagement == null) {
      return true;
    }
    if (inventoryManagement == 'shopify' && inventoryPolicy == 'continue') {
      return inventoryQuantity! > 0;
    }
    return false;
  }

  CartLineItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        productId = json['product_id'],
        variationId = json['variation_id'],
        quantity = json['quantity'],
        inventoryQuantity = json['inventory_quantity'],
        inventoryManagement = json['inventory_management'],
        inventoryPolicy = json['inventory_policy'],
        price = json['price'],
        imageSrc = json['image_src'],
        variationOptions = json['variation_options'],
        taxable = json['taxable'],
        weight = double.parse((json['weight'] ?? 0).toString()),
        metaData = json['metaData'];

  CartLineItem.fromProduct(CartProduct product)
      : title = product.title,
        productId = product.id,
        variationId = product.variant?.id,
        quantity = product.cartQuantity,
        inventoryQuantity = product.variant?.inventoryQuantity,
        inventoryPolicy = product.variant?.inventoryPolicy,
        price = product.variant?.price,
        inventoryManagement = product.variant?.inventoryManagement,
        taxable = product.variant?.taxable,
        weight = product.variant?.weight,
        imageSrc = product.findVariationImage(),
        variationOptions =
            product.isVariation == true ? product.variant?.title : '',
        metaData = {};

  Map<String, dynamic> toJson() => {
        'title': title,
        'product_id': productId,
        'variation_id': variationId,
        'quantity': quantity,
        'inventory_policy': inventoryPolicy,
        'inventory_quantity': inventoryQuantity,
        'inventory_management': inventoryManagement,
        'image_src': imageSrc,
        'variation_options': variationOptions,
        'price': price,
        'weight': weight,
        'taxable': taxable,
        'meta_data': metaData,
        'app_meta': appMeta
      };
}
