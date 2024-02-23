//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';

class SwitchAddressTab extends StatelessWidget {
  const SwitchAddressTab({
    super.key,
    required this.type,
    required this.title,
    required this.currentTabIndex,
    required this.onTapAction,
  });

  final String type;
  final String title;
  final int currentTabIndex;
  final Function() onTapAction;

  @override
  Widget build(BuildContext context) {
    bool isActive = false;
    if (type == "shipping" && currentTabIndex == 1) {
      isActive = true;
    }

    if (type == "billing" && currentTabIndex == 0) {
      isActive = true;
    }

    return Flexible(
      child: InkWell(
        child: Container(
          width: double.infinity,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: isActive ? Colors.white : Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? Colors.black : Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        ),
        onTap: onTapAction,
      ),
    );
  }
}
