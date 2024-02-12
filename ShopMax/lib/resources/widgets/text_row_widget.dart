//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';

class TextRowWidget extends StatelessWidget {
  const TextRowWidget({super.key, required this.title, required this.text});

  final String? title, text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Container(
            child: Text(title!, style: Theme.of(context).textTheme.titleLarge),
          ),
          flex: 3,
        ),
        Flexible(
          child: Container(
            child: Text(
              text!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
            ),
          ),
          flex: 3,
        )
      ],
    );
  }
}
