//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal_shopify_api/models/product.dart' as ws_shopify;

class ProductDetailDescriptionWidget extends StatelessWidget {
  const ProductDetailDescriptionWidget({super.key, required this.product});

  final ws_shopify.Product? product;

  String get description => (product?.bodyHtml ?? "");

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) {
      return SizedBox.shrink();
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                trans("Description"),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: HtmlWidget(description, renderMode: RenderMode.column,
              onTapUrl: (String url) async {
            await launchUrl(Uri.parse(url));
            return true;
          }, textStyle: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
