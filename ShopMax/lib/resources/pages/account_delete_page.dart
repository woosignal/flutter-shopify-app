//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/events/delete_account_event.dart';
import '/app/events/logout_event.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AccountDeletePage extends NyStatefulWidget {
  static String path = "/account-delete";
  AccountDeletePage() : super(path, child: _AccountDeletePageState());
}

class _AccountDeletePageState extends NyState<AccountDeletePage> {
  @override
  init() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trans("Delete Account")),
      ),
      body: SafeAreaWidget(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_accounts_rounded, size: 50),
                Text(
                  trans("Delete your account"),
                  style: textTheme.displaySmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(trans("Are you sure?")),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryButton(
                title: trans("Yes, delete my account"),
                isLoading: isLocked('delete_account'),
                action: _deleteAccount,
              ),
              LinkButton(title: trans("Back"), action: pop)
            ],
          )
        ],
      )),
    );
  }

  _deleteAccount() async {
    confirmAction(() async {
      await lockRelease('delete_account', perform: () async {
        await event<DeleteAccountEvent>();

        showToast(
            title: trans("Success"), description: trans("Account deleted"));
        await event<LogoutEvent>();
      });
    }, title: "Delete my account".tr());
  }
}
