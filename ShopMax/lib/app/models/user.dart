//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? userId;
  String? token;

  User();
  User.fromUserAuthResponse({this.userId, this.token});

  @override
  toJson() => {"token": token, "user_id": userId};

  User.fromJson(dynamic data) {
    token = data['token'];
    userId = data['user_id'];
  }
}
