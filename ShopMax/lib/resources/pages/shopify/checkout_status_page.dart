//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/controllers/checkout_status_controller.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/order_created_response.dart';
import '/app/models/shopify/cart.dart';
import '/app/models/shopify/checkout_session.dart';
import '/resources/widgets/woosignal_ui.dart';

class CheckoutStatusPage extends NyStatefulWidget {
  static String path = "/checkout-status";

  @override
  final CheckoutStatusController controller = CheckoutStatusController();

  CheckoutStatusPage({Key? key})
      : super(path, key: key, child: _CheckoutStatusState());
}

class _CheckoutStatusState extends NyState<CheckoutStatusPage> {
  OrderCreatedResponse? _order;

  @override
  init() async {
    _order = widget.controller.data();
    await Cart.getInstance.clear();
    CheckoutSession.getInstance.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: StoreLogo(height: 60),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          child: Text(
                            trans("Order Status"),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          padding: EdgeInsets.only(bottom: 15),
                        ),
                        Text(
                          trans("Thank You!"),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          trans("Your transaction details"),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${trans("Order Ref")}. #${_order?.order?.id.toString()}",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12, width: 1.0),
                        ),
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.white
                                : null),
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  Container(
                    child: Image.asset(
                      getImageAsset("camion.gif"),
                      height: 170,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    width: double.infinity,
                  ),
                ],
              ),
              Align(
                child: Padding(
                  child: Text(
                    trans("Items"),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                  padding: EdgeInsets.all(8),
                ),
                alignment: Alignment.center,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _order?.order?.lineItems == null
                        ? 0
                        : _order?.order?.lineItems?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final lineItem = _order!.order?.lineItems![index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: wsBoxShadow(),
                          color:
                              (Theme.of(context).brightness == Brightness.light)
                                  ? Colors.white
                                  : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  lineItem?.name ?? "",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  softWrap: false,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "x${lineItem?.quantity.toString()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ).flexible(),
                            Text(
                              formatStringCurrency(
                                total: lineItem?.price.toString(),
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ).paddingOnly(left: 16)
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.all(8),
                      );
                    }),
              ),
              Align(
                child: LinkButton(
                  title: trans("Back to Home"),
                  action: () {
                    routeToInitial();
                  },
                ),
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
