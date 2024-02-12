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
import '/resources/widgets/safearea_widget.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProductImageViewerPage extends NyStatefulWidget {
  static String path = "/product-images";

  ProductImageViewerPage({Key? key})
      : super(path, key: key, child: _ProductImageViewerPageState());
}

class _ProductImageViewerPageState extends NyState<ProductImageViewerPage> {
  int? _initialIndex;
  List<String?> _arrImageSrc = [];

  @override
  void initState() {
    Map<String, dynamic> imageData = widget.controller.data();
    _initialIndex = imageData['index'];
    _arrImageSrc = imageData['images'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeAreaWidget(
        child: Column(
          children: [
            Expanded(
              child: Swiper(
                index: _initialIndex!,
                itemBuilder: (BuildContext context, int index) =>
                    CachedImageWidget(
                  image: (_arrImageSrc.isEmpty
                      ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                      : _arrImageSrc[index]),
                ),
                itemCount: _arrImageSrc.isEmpty ? 1 : _arrImageSrc.length,
                viewportFraction: 0.9,
                scale: 0.95,
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
