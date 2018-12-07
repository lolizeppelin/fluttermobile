import 'package:intl/intl.dart';

import 'package:flutter_manhua/constant/common.dart';


void main() {
  print('\n');
  print('~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  String currency = 'EUR';
  Map<String, dynamic> _currency = Currencys[currency];
  NumberFormat f = NumberFormat.currency(locale: 'en_US',
      name: _currency['name'], symbol: _currency['symbol'],
      decimalDigits: 2);
  print(currency + ' ' + f.format(1));
  print('~~~~~~~~~~~~~~~~~~~~~~~~~~~');
}
