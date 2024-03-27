//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '../pages/account_order_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_order.dart';

class AccountDetailOrders extends StatefulWidget {
  @override
  createState() => _AccountDetailOrdersState();
}

class _AccountDetailOrdersState extends NyState<AccountDetailOrders> {
  @override
  bool get showInitialLoader => false;

  String? nextPage;
  bool? hasNextPage;

  @override
  Widget view(BuildContext context) {
    return NyPullToRefresh(
        child: (context, order) {
          order as Orders;
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 8,
                right: 6,
              ),
              title: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFFCFCFC),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${order.name}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order.fulfillmentStatus ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formatStringCurrency(total: order.totalPrice?.amount),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${order.lineItems?.length} ${trans("items")}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      "${order.processedAt.toDateTime().toDateString()}\n${order.processedAt.toDateTime().toTimeString()}",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () =>
                  routeTo(AccountOrderDetailPage.path, data: order.uid),
            ),
          );
        },
        data: (iteration) async {
          if (hasNextPage == false) return [];
          AuthCustomerOrder? authCustomerOrder =
              await fetchOrders(perPage: 50, after: nextPage);
          nextPage = null;
          if (authCustomerOrder == null) return [];
          if (authCustomerOrder.pageInfo?.hasNextPage == false) {
            hasNextPage = false;
            return authCustomerOrder.orders;
          }
          if (authCustomerOrder.pageInfo?.hasNextPage == true) {
            nextPage = authCustomerOrder.pageInfo?.endCursor;
          }
          return authCustomerOrder.orders;
        },
        beforeRefresh: () {
          hasNextPage = true;
          nextPage = null;
          setState(() {});
        },
        empty: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.shopping_cart,
                color: Colors.black54,
                size: 40,
              ),
              Text(
                trans("No orders found"),
              ),
            ],
          ),
        ),
        loading: ListView(
          children: [
            Card(
              child: ListTile(
                contentPadding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: 8,
                  right: 6,
                ),
                title: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFFCFCFC),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Some Text",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Some Text",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            formatStringCurrency(total: "Some Text"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            "Some Text",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Text(
                        "Some Text",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            )
          ],
        ),
        useSkeletonizer: true);
  }

  Future<AuthCustomerOrder?> fetchOrders({int? perPage, String? after}) async {
    return await appWooSignalShopify(
        (api) => api.authCustomerOrders(perPage: perPage, after: after));
  }
}
