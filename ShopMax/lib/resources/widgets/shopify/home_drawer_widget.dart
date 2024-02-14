//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/account_landing_page.dart';
import '/resources/pages/shopify/cart_page.dart';
import '/resources/pages/shopify/wishlist_page_widget.dart';
import '/resources/widgets/app_version_widget.dart';
import '/resources/widgets/cached_image_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/theme/helper/ny_theme.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal_shopify_api/models/menu_link.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class HomeDrawerWidget extends StatefulWidget {
  const HomeDrawerWidget({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  @override
  createState() => _HomeDrawerWidgetState();
}

class _HomeDrawerWidgetState extends State<HomeDrawerWidget> {
  List<MenuLink> _menuLinks = [];
  String? _themeType;

  @override
  void initState() {
    super.initState();
    _menuLinks = AppHelper.instance.shopifyAppConfig?.menuLinks ?? [];
    _themeType = AppHelper.instance.shopifyAppConfig?.theme;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = (Theme.of(context).brightness == Brightness.dark);
    return Drawer(
      child: Container(
        color: ThemeColor.get(context).background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(child: StoreLogo()),
              decoration: BoxDecoration(
                color: ThemeColor.get(context).background,
              ),
            ),
            if (["compo"].contains(_themeType) == false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    child: Text(
                      trans("Menu"),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  ),
                  ListTile(
                    title: Text(
                      trans("Profile"),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                    ),
                    leading: Icon(Icons.account_circle),
                    onTap: _actionProfile,
                  ),
                  if (widget.wooSignalApp!.wishlistEnabled == true)
                    // ListTile(
                    //   title: Text(
                    //     trans("Wishlist"),
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .bodyMedium!
                    //         .copyWith(fontSize: 16),
                    //   ),
                    //   leading: Icon(Icons.favorite_border),
                    //   onTap: _actionWishlist,
                    // ),
                  ListTile(
                    title: Text(
                      trans("Cart"),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                    ),
                    leading: Icon(Icons.shopping_cart),
                    onTap: _actionCart,
                  ),
                ],
              ),
            if (widget.wooSignalApp!.appTermsLink != null &&
                widget.wooSignalApp!.appPrivacyLink != null)
              Padding(
                child: Text(
                  trans("About Us"),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              ),
            if (widget.wooSignalApp!.appTermsLink != null &&
                widget.wooSignalApp!.appTermsLink!.isNotEmpty)
              ListTile(
                title: Text(
                  trans("Terms and conditions"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16),
                ),
                leading: Icon(Icons.menu_book_rounded),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                onTap: _actionTerms,
              ),
            if (widget.wooSignalApp!.appPrivacyLink != null &&
                widget.wooSignalApp!.appPrivacyLink!.isNotEmpty)
              ListTile(
                title: Text(
                  trans("Privacy policy"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16),
                ),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                leading: Icon(Icons.account_balance),
                onTap: _actionPrivacy,
              ),
            ListTile(
              title: Text(trans((isDark ? "Light Mode" : "Dark Mode")),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16)),
              leading: Icon(Icons.brightness_4_rounded),
              onTap: () {
                setState(() {
                  NyTheme.set(context,
                      id: isDark
                          ? "default_light_theme"
                          : "default_dark_theme");
                });
              },
            ),
            if (_menuLinks.isNotEmpty)
              Padding(
                child: Text(
                  trans("Social"),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              ),
            ..._menuLinks
                .where((element) => element.label != "")
                .map((menuLink) => ListTile(
                      title: Text(menuLink.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16)),
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CachedImageWidget(
                          image: menuLink.iconUrl,
                          width: 40,
                        ),
                      ),
                      onTap: () async =>
                          await launchUrl(Uri.parse(menuLink.linkUrl)),
                    )),
            ListTile(
              title: AppVersionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  _actionTerms() => openBrowserTab(url: widget.wooSignalApp!.appTermsLink!);

  _actionPrivacy() => openBrowserTab(url: widget.wooSignalApp!.appPrivacyLink!);

  _actionProfile() async {
    Navigator.pop(context);
    UserAuth.instance.redirect = AccountLandingPage.path;
    routeTo(AccountLandingPage.path);
  }

  _actionWishlist() async {
    Navigator.pop(context);
    routeTo(WishListPageWidget.path);
  }

  _actionCart() {
    Navigator.pop(context);
    routeTo(CartPage.path);
  }
}
