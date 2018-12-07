import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/utils/requests.dart';
import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/actions/user.dart';

import 'platforms.dart';


class PaypalPage extends StatefulWidget {

  final int money;
  final UsersDao user = UsersDao(SingletonStore.store);
  final OnFinish callback;

  static final url = 'http://$API_HOSTNAME/n1.0${FlutterComicClient.html_template}/paypal';

  PaypalPage({this.money, this.callback});

  @override
  _PaypalPageState createState() => _PaypalPageState();
}

class _PaypalPageState extends State<PaypalPage> {

  final flutterWebviewPlugin = FlutterWebviewPlugin();

  StreamSubscription<WebViewHttpError> _onHttpError;
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onWebviewMessaged;

  bool payError = false;

  BuildContext context;

  @override
  void initState() {
    print('init state paypal');
    super.initState();
    flutterWebviewPlugin.close();

    _onHttpError =
        flutterWebviewPlugin.onHttpError.listen((WebViewHttpError error) {
          print('http error~~~~~~~~~~~~~~~~~~${error.code}~~~${error.url}');
        });

    _onDestroy =
        flutterWebviewPlugin.onDestroy.listen((_) {
          print('http destroy~~~~~~~~~~~~~~~~~~Webview ?}');
          setState(() {
            payError = true;
          });
        });

    _onWebviewMessaged =
        flutterWebviewPlugin.onWebviewMessage.listen((String message) {
          print('JavaScript callback message: $message');
          Map result = jsonDecode(message);
          if (result['success']) {
            print('paypal success');
            int coins = result['coins'];
            SingletonStore.store.dispatch(ChangeCoins(payload: coins));
            if (widget.callback != null) widget.callback(true);
            flutterWebviewPlugin.close();
            Navigator.pop(this.context);
          }
          setState(() {
            if (widget.callback != null) widget.callback(false);
            payError = true;
          });
        });
  }

  @override
  void dispose() {
    print('paypal dispose');
    this.context = null;
    _onHttpError.cancel();
    _onDestroy.cancel();
    _onWebviewMessaged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('paypal build');

    this.context = context;

    if (widget.user.uid == 0 || widget.user.token.length == 0) {
      return Scaffold(
        appBar: AppBar(title: Center(child: Text(S.of(context).NoUserFound))),
        body: Center(
          child: Text(S.of(context).PayNotStart + ',' + S.of(context).NoUserFound + ',' + S.of(context).GoToLogin),
        ),
      );
    }

    if (payError) {
      return Scaffold(
        appBar: AppBar(title: Center(child: Text('PayPal ' + S.of(context).RechargeError))),
        body: Center(
          child: Text(S.of(context).PayFail + ',' + S.of(context).ReturnAndPay),
        ),
      );
    }

    final String url = PaypalPage.url + '?uid=${widget.user.uid}&money=${widget.money}&cid=${widget.user.cid}&chapter=0';

    return WebviewScaffold(
        url: url,
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          centerTitle: true,
          title: Center(child: Text(S.of(context).PayOrder)),
        ),
        headers: { 'Content-Type': 'text/html' },
        withZoom: true,
        withJavascript: true,
        withLocalStorage: true,
        withLocalUrl: true,
        enableMessaging: true
    );
  }
}