//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/woosignal_ui.dart';

class CheckoutStoreHeadingWidget extends StatelessWidget {
  const CheckoutStoreHeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(top: 16),
      child: ClipRRect(
        child: StoreLogo(height: 65),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
