import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';

import 'package:flutter_manhua/pages/pay/paypal.dart';
import 'package:flutter_manhua/pages/pay/weixin.dart';

import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/store.dart';


typedef void Cancel();
typedef void Confirm();
typedef dynamic OnFinish(bool result);


const Map PLATFORMS = {
  'paypal': PaypalPage,
  'weixin': WeiXinPage,
};


class PlateFormChoice extends StatefulWidget {

  final Confirm confirmCallback;
  final Cancel cancelCallback;
  final OnFinish finishCallback;

  final UsersDao user = UsersDao(SingletonStore.store);

  PlateFormChoice(this.confirmCallback, this.cancelCallback, this.finishCallback);

  @override
  _PlateFormChoiceState createState() => _PlateFormChoiceState();

}


class _PlateFormChoiceState extends State<PlateFormChoice> {


  List<String> platforms;  // 可选支付渠道列表

  String platform;          // 当前支付渠道
  int pay;                  // 当前选定金额

  int scale;                // 转换比例
  String currency;          // 货币类型
  List<int> choices;        // 可选金额列表


  @override
  void initState() {
    super.initState();
    platforms =   widget.user.platforms != null
        ? widget.user.platforms.keys.toList()
        : [];

    Set<String> LOCALPLATFORMS = Set.from(PLATFORMS.keys);
    
    for (String p in platforms) {           //  判断本地代码是否支持渠道
      if (!LOCALPLATFORMS.contains(p)) platforms.remove(p);
    }

    if (platforms.length > 0) {
      platform = platforms[0];
      _selectPlatform(platform);
    }

  }


  void _selectPlatform(String p) {
    platform = p;
    Map _platform = widget.user.platforms[platform];

    choices = List<int>.from(_platform['choices']);
    scale = _platform['scale'];
    currency = _platform['currency'];
    if (choices.length > 0) pay = choices[0];
  }


  static NumberFormat _currencyFormat(Locale local, String currency) {

    Map<String, dynamic> _currency = Currencys[currency];

    return NumberFormat.currency(locale: local.toString(),
        name: _currency['name'], symbol: _currency['symbol'],
        decimalDigits: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    if (platforms.length == 0) {
      return Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(S.of(context).NoPayPlatforms),
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            alignment: Alignment.centerLeft,
            child: Text(S.of(context).ChooseRechargeMoney, style: TextStyle(fontWeight: FontWeight.w100, fontSize: 16.0, color: Colors.deepOrangeAccent))
        ),
        SizedBox(height: 5.0),
        Container(
          height: 70.0,
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: ListView.builder(
            padding: EdgeInsets.only(left: 10.0),
            itemCount: choices.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              bool active = (pay == choices[index]);
              NumberFormat format = _currencyFormat(Localizations.localeOf(context), currency);
              return Container(
                width: 150,
                child: Padding(padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    child: Container(
                      color: active ? Colors.deepOrange : null,
                      decoration: active ? null : BoxDecoration(border: Border.all(width: 1.0, color: Colors.grey)),
                      child: Column(
                        mainAxisAlignment:  MainAxisAlignment.center,
                        children: <Widget>[
                          Center(child: Text('${choices[index]*scale} ' + S.of(context).CoinName, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.black))),
                          Center(child: Text('$currency  ${format.format(choices[index])}', style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.black))),
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        pay = choices[index];
                      });
                    },
                  )
                )
              );
            },
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            alignment: Alignment.centerLeft,
            child: Text(S.of(context).ChooseRechargeType, style: TextStyle(fontWeight: FontWeight.w100, fontSize: 16.0, color: Colors.deepOrangeAccent))
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          height: 70.0,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 10.0),
            itemCount: platforms.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              bool active = (platform == platforms[index]);
              return GestureDetector(
                  child: Container(
                    width: 80.0,
                    child: Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Container(
                          child: Image.asset('assets/$platform.png'),
                          decoration: active ? BoxDecoration(border: Border.all(width: 2.0, color: Colors.orange)) : null
                      ),
                    )
                  ),
                  onTap: () {
                    setState(() {
                      _selectPlatform(platforms[index]);
                    });
                  });
              },
          ),
        ),
        SizedBox(height: 15.0),
        Container(
          height: 60,
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: Material(
              borderRadius: BorderRadius.circular(15.0),
//              shadowColor: Colors.lightBlueAccent.shade100,
              color: Colors.orange,
//              elevation: 5.0,
              child: MaterialButton(
                height: 50,
                  onPressed: () {
                    if (widget.confirmCallback != null) widget.confirmCallback();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaypalPage(money: pay, callback: widget.finishCallback)));
                  },
                  child: Container(
                    child: Center(
                      child: Text(S.of(context).RechargeNow, style: TextStyle(fontWeight: FontWeight.w100, fontSize: 30.0, color: Colors.white)),
                    ),
                  )
              )
          ),
        )
      ],
    );
  }

}