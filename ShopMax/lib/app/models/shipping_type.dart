//  StoreMob
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:woosignal_shopify_api/models/shopify_shipping_method.dart';

import '/bootstrap/helpers.dart';

class ShippingType {
  ShippingMethod? shippingMethod;

  ShippingType({this.shippingMethod});

  Map<String, dynamic> toJson() => {
        'shippingMethod': shippingMethod,
      };

  String? getTotal({bool? withFormatting}) {
    if (withFormatting == true) {
      return formatStringCurrency(total: shippingMethod?.price);
    }
    return shippingMethod?.price;
  }

  String? getTitle() {
    return shippingMethod?.title;
  }
}
