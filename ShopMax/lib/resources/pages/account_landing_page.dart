//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/account_detail_orders_widget.dart';
import '/resources/widgets/account_detail_settings_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';

class AccountLandingPage extends NyStatefulWidget {
  final bool showLeadingBackButton;
  static String path = "/account-detail";
  AccountLandingPage({this.showLeadingBackButton = true})
      : super(path, child: _AccountLandingPageState());
}

class _AccountLandingPageState extends NyState<AccountLandingPage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  int _currentTabIndex = 0;
  AuthCustomerInfo? _customerInfo;

  @override
  boot() async {
    await _fetchCustomer();
    _tabController = TabController(vsync: this, length: 2);
  }

  _fetchCustomer() async {
    _customerInfo = await appWooSignalShopify((api) => api.authCustomer());
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showLeadingBackButton
            ? Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                margin: EdgeInsets.only(left: 0),
              )
            : Container(),
        title: Text(trans("Account")),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 65,
                        ),
                        height: 90,
                        width: 90,
                      ),
                      Expanded(
                        child: Padding(
                          child: Text(
                            [_customerInfo?.firstName, _customerInfo?.lastName]
                                .where((t) => (t != null || t != ""))
                                .toList()
                                .join(" "),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          padding: EdgeInsets.only(left: 16),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    child: TabBar(
                      tabs: [
                        Tab(text: trans("Orders")),
                        Tab(text: trans("Settings")),
                      ],
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      indicator: BubbleTabIndicator(
                        indicatorHeight: 30.0,
                        indicatorRadius: 5,
                        indicatorColor: Colors.black87,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      onTap: _tabsTapped,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: (Theme.of(context).brightness == Brightness.light)
                    ? wsBoxShadow()
                    : null,
                color: ThemeColor.get(context).backgroundContainer,
              ),
            ),
            Expanded(
              child: NySwitch(
                widgets: [
                  AccountDetailOrders(),
                  AccountDetailSettings(),
                ],
                indexSelected: _currentTabIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  _tabsTapped(int i) {
    setState(() {
      _currentTabIndex = i;
    });
  }
}
