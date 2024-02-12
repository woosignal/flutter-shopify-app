/*
|--------------------------------------------------------------------------
| CURRENCY
|
| Configure which currency you want to use.
| Docs here: https://woosignal.com/docs/app/shopmax
|--------------------------------------------------------------------------
*/

import '/bootstrap/enums/symbol_position_enums.dart';

/*
|--------------------------------------------------------------------------
| APP CURRENCY
|
| Configure the currency settings. To change the currency used (e.g. "USD"),
| update the "currency" value in the WooSignal dashboard.
|--------------------------------------------------------------------------
*/

const SymbolPositionType appCurrencySymbolPosition = SymbolPositionType.left;
// currency_symbol_position example.
// left: $15
// right: 15€
