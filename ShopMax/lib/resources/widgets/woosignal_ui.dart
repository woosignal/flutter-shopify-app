//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '/app/models/shopify/cart.dart' as shopify;
import '/app/models/shopify/checkout_session.dart' as shopify;
import '/bootstrap/app_helper.dart';
import '/bootstrap/extensions.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/product_detail_page.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/product.dart' as Shopify;
import 'package:woosignal_shopify_api/models/response/shopify_product_response.dart';
import 'package:woosignal_shopify_api/models/response/shopify_product_search_response.dart';

import '/app/models/shopify/cart.dart';

class CheckoutRowLine extends StatelessWidget {
  const CheckoutRowLine(
      {super.key,
      required this.heading,
      required this.leadImage,
      required this.leadTitle,
      required this.action,
      this.showBorderBottom = true});

  final String heading;
  final String? leadTitle;
  final Widget leadImage;
  final Function() action;
  final bool showBorderBottom;

  @override
  Widget build(BuildContext context) => Container(
        height: 125,
        padding: EdgeInsets.all(8),
        decoration: showBorderBottom == true
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              )
            : BoxDecoration(),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                child: Text(
                  heading,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(bottom: 8),
              ),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          leadImage,
                          Expanded(
                            child: Container(
                              child: Text(
                                leadTitle!,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                              padding: EdgeInsets.only(left: 15),
                              margin: EdgeInsets.only(right: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}

class TextEditingRow extends StatelessWidget {
  const TextEditingRow(
      {super.key,
      this.heading,
      this.controller,
      this.shouldAutoFocus,
      this.keyboardType,
      this.obscureText,
      this.dummyData});

  final String? heading;
  final TextEditingController? controller;
  final bool? shouldAutoFocus;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final String? dummyData;

  @override
  Widget build(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (heading != null)
              Flexible(
                child: Padding(
                  child: AutoSizeText(
                    heading!,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: ThemeColor.get(context).primaryContent),
                  ),
                  padding: EdgeInsets.only(bottom: 2),
                ),
              ),
            Flexible(
              child: NyTextField(
                controller: controller!,
                style: Theme.of(context).textTheme.titleMedium,
                keyboardType: keyboardType ?? TextInputType.text,
                autocorrect: false,
                autoFocus: shouldAutoFocus ?? false,
                obscureText: obscureText ?? false,
                textCapitalization: TextCapitalization.sentences,
                dummyData: dummyData,
              ),
            )
          ],
        ),
        padding: EdgeInsets.all(2),
        height: heading == null ? 50 : 88,
      );
}

class CheckoutMetaLine extends StatelessWidget {
  const CheckoutMetaLine({super.key, this.title, this.amount});

  final String? title, amount;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Container(
                child: AutoSizeText(title!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
              flex: 3,
            ),
            Flexible(
              child: Container(
                child:
                    Text(amount!, style: Theme.of(context).textTheme.bodyLarge),
              ),
              flex: 3,
            )
          ],
        ),
      );
}

List<BoxShadow> wsBoxShadow({double? blurRadius}) => [
      BoxShadow(
        color: Color(0xFFE8E8E8),
        blurRadius: blurRadius ?? 15.0,
        spreadRadius: 0,
        offset: Offset(
          0,
          0,
        ),
      )
    ];

class ShopifyProductItemContainer extends StatelessWidget {
  const ShopifyProductItemContainer({
    super.key,
    this.product,
    this.onTap,
  });

  final Shopify.Product? product;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return SizedBox.shrink();
    }

    double height = 280;
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(4),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    CachedImageWidget(
                      image: ((product!.images ?? []).isNotEmpty
                          ? (product!.images ?? []).first.src
                          : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                      fit: BoxFit.contain,
                      height: height,
                      width: double.infinity,
                    ),
                    if (product?.createdAt?.isNewProduct() ?? false)
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "New",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                    if (product?.onSale ?? false)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${workoutSaleDiscount(salePrice: product?.compareAtPrice, priceBefore: product?.price)}% ${trans("off")}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                product?.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "${formatStringCurrency(total: product?.price)} ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.left,
                  ),
                  if (product?.onSale ?? false)
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${trans("Was")}: ',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 11,
                                  ),
                        ),
                        TextSpan(
                          text: formatStringCurrency(
                            total: product?.price,
                          ),
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                        ),
                      ]),
                    ),
                ].toList(),
              ),
            ),
          ],
        ),
      ),
      onTap: () => onTap != null
          ? onTap!(product)
          : Navigator.pushNamed(context, "/product-detail", arguments: product),
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    this.featureImage,
    this.name,
    this.price,
    this.productAddedAt,
    this.onTap,
    this.comparePrice,
    this.productId,
    this.height = 280,
  });

  /// Create a product item from a [ShopifyProduct] object.
  ProductItem.fromShopifyProduct(ShopifyProduct product,
      {this.onTap, this.height = 280})
      : featureImage = product.featuredImage?.url,
        name = product.title,
        price = product.priceRange?.minVariantPrice?.amount,
        productId = product.uId,
        comparePrice = product.compareAtPriceRange?.minVariantPrice?.amount,
        productAddedAt = product.createdAt.toDateTime();

  ProductItem.fromShopifyProductSearch(ProductSearch product,
      {this.onTap, this.height = 280})
      : featureImage = product.featuredImage?.url,
        name = product.title,
        price = product.priceRange?.minVariantPrice?.amount,
        productId = product.uId,
        comparePrice = product.compareAtPriceRange?.minVariantPrice?.amount,
        productAddedAt = product.createdAt.toDateTime();

  bool get isOnSale =>
      double.parse(comparePrice ?? "0") > double.parse(price ?? "0");

  final Function? onTap;
  final DateTime? productAddedAt;
  final String? name;
  final String? featureImage;
  final String? comparePrice;
  final int? productId;
  final double height;
  final String? price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Container(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.0),
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[100],
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  CachedImageWidget(
                    image:
                        (featureImage ?? getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                    fit: BoxFit.contain,
                    height: height,
                    width: double.infinity,
                  ),
                  if (productAddedAt.isNewProduct())
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        "New",
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  if (isOnSale)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    "${workoutSaleDiscount(salePrice: price, priceBefore: comparePrice)}% ${trans("off")}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            child: Text(
              name ?? "",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AutoSizeText(
                  "${price.toMoney()} ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.left,
                ),
                if (isOnSale)
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${trans("Was")}: ',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 11,
                            ),
                      ),
                      TextSpan(
                        text: comparePrice.toMoney(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                      ),
                    ]),
                  ),
              ].toList(),
            ),
          ),
        ],
      ),
    ).onTap(() => routeTo(ProductDetailPage.path, data: productId));
  }
}

wsModalBottom(BuildContext context,
    {String? title, Widget? bodyWidget, Widget? extraWidget}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (builder) {
      return SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColor.get(context).background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context).background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: bodyWidget,
                  ),
                ),
                if (extraWidget != null) extraWidget
              ],
            ),
          ),
        ),
      );
    },
  );
}

class ShopifyCheckoutTotal extends StatelessWidget {
  const ShopifyCheckoutTotal({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) => NyFutureBuilder<String>(
        future: shopify.CheckoutSession.getInstance.total(withFormat: true),
        child: (BuildContext context, data) => Padding(
          child: CheckoutMetaLine(title: title, amount: data),
          padding: EdgeInsets.only(bottom: 0, top: 15),
        ),
        loading: SizedBox.shrink(),
      );
}

class ShopifyCheckoutTaxTotal extends StatelessWidget {
  const ShopifyCheckoutTaxTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder<String>(
      future: shopify.Cart.getInstance.taxAmount(),
      child: (BuildContext context, data) {
        if (data == "0") {
          return SizedBox.shrink();
        }
        return Padding(
          child: CheckoutMetaLine(
            title: trans("Tax"),
            amount: formatStringCurrency(total: data),
          ),
          padding: EdgeInsets.only(bottom: 0, top: 0),
        );
      },
    );
  }
}

class CheckoutSubtotal extends StatelessWidget {
  const CheckoutSubtotal({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) => NyFutureBuilder<String>(
        future: Cart.getInstance.getSubtotal(withFormat: true),
        child: (BuildContext context, data) => Padding(
          child: CheckoutMetaLine(
            title: title,
            amount: data,
          ),
          padding: EdgeInsets.only(bottom: 0, top: 0),
        ),
        loading: SizedBox.shrink(),
      );
}

class ShopifyCheckoutSubtotal extends StatelessWidget {
  const ShopifyCheckoutSubtotal({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) => NyFutureBuilder<String>(
        future: shopify.Cart.getInstance.getSubtotal(withFormat: true),
        child: (BuildContext context, data) => Padding(
          child: CheckoutMetaLine(
            title: title,
            amount: data,
          ),
          padding: EdgeInsets.only(bottom: 0, top: 0),
        ),
        loading: SizedBox.shrink(),
      );
}

class StoreLogo extends StatelessWidget {
  const StoreLogo(
      {super.key,
      this.height = 100,
      this.width = 100,
      this.placeholder = const CircularProgressIndicator(),
      this.fit = BoxFit.contain,
      this.showBgWhite = true});

  final bool showBgWhite;
  final double height;
  final double width;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: showBgWhite ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5)),
        child: CachedImageWidget(
          image: AppHelper.instance.shopifyAppConfig?.appLogo,
          height: height,
          placeholder: Container(height: height, width: width),
        ),
      );
}
