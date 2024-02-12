//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/product.dart' as ws_shopify;

class ProductDetailImageSwiperWidget extends StatelessWidget {
  const ProductDetailImageSwiperWidget(
      {super.key, required this.product, required this.onTapImage});

  final ws_shopify.Product? product;
  final void Function(int i) onTapImage;

  List<ws_shopify.Images> get images => product?.images ?? [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: SizedBox(
        child: Swiper(
          itemBuilder: (BuildContext context, int index) => CachedImageWidget(
            image: images.isNotEmpty
                ? images[index].src
                : getEnv("PRODUCT_PLACEHOLDER_IMAGE"),
          ),
          itemCount: images.isEmpty ? 1 : images.length,
          viewportFraction: 0.85,
          scale: 0.9,
          onTap: onTapImage,
        ),
      ),
    );
  }
}
