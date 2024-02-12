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
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/shopify_country_response.dart';

class CustomerCountriesPage extends NyStatefulWidget {
  static String path = "/customer-countries";
  CustomerCountriesPage() : super(path, child: _CustomerCountriesPageState());
}

class _CustomerCountriesPageState extends NyState<CustomerCountriesPage> {

  final TextEditingController _tfSearchCountry = TextEditingController();

  List<ShopifyCountry> _countries = [], _activeShippingResults = [];

  @override
  boot() async {
    ShopifyCountryResponse? shopifyCountryResponse = await appWooSignalShopify((api) => api.getCountries());
    if (shopifyCountryResponse == null) {
      showToastDanger(description: trans("Something went wrong"));
      pop();
      return;
    }

    _countries = shopifyCountryResponse.countries ?? [];
    _activeShippingResults = _countries;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Select a country")),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              margin: EdgeInsets.only(bottom: 10, top: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: ThemeColor.get(context).background,
              ),
              height: 60,
              child: Row(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.search),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tfSearchCountry,
                      autofocus: true,
                      onChanged: _handleOnChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    ShopifyCountry defaultShipping = _activeShippingResults[index];
                    return InkWell(
                      onTap: () => _handleCountryTapped(defaultShipping),
                      child: Container(
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!)),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text(defaultShipping.name ?? ""),
                      ),
                    );
                  },
                  itemCount: _activeShippingResults.length),
            ),
          ],
        ),
      ),
    );
  }

  _handleOnChanged(String value) {
    _activeShippingResults = _countries
        .where((country) =>
        country.name!.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  _handleCountryTapped(ShopifyCountry defaultShipping) {
    if ((defaultShipping.provinces ?? []).isNotEmpty) {
      _handleStates(defaultShipping);
      return;
    }
    _popWithShippingResult(defaultShipping);
  }

  _handleStates(ShopifyCountry defaultShipping) {
    FocusScope.of(context).unfocus();
    wsModalBottom(
      context,
      title: trans("Select a state"),
      bodyWidget: ListView.separated(
        itemCount: (defaultShipping.provinces ?? []).length,
        itemBuilder: (BuildContext context, int index) {
          Provinces state = (defaultShipping.provinces ?? [])[index];

          return InkWell(
            child: Container(
              child: Text(
                state.name!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              padding: EdgeInsets.only(top: 25, bottom: 25),
            ),
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () {
              Navigator.pop(context);
              _popWithShippingResult(defaultShipping, state: state);
            },
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  _popWithShippingResult(ShopifyCountry defaultShipping,
      {Provinces? state}) {
    if (state != null) {
      defaultShipping.provinces = [];
      defaultShipping.provinces?.add(state);
    }
    Navigator.pop(context, defaultShipping);
  }
}
