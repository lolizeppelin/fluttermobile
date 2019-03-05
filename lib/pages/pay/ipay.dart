import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/utils/requests.dart';
import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/actions/user.dart';

import 'package:fluipay/fluipay.dart' as fluipay;

import 'platforms.dart';


String getSystem() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  throw Exception('System type error');
}


class IPayApi {

  static final _sys = getSystem();
  static final url = 'http://$API_HOSTNAME/n1.0${FlutterComicClient.platforms}/weixin';
  static final Map<String, IPayApi> _instances = Map<String, IPayApi>();

  StreamSubscription subscription;

  String appId;
  bool h5;    // H5 支付标记

  factory IPayApi(Map<String, dynamic> ipayInfo) {

    if (_instances.containsKey(IPayApi._sys)) {
      return _instances[IPayApi._sys];
    } else {
      final instance = IPayApi._internal(ipayInfo);
      _instances[IPayApi._sys] = instance;
      return instance;
    }
  }

  IPayApi._internal(Map<String, dynamic> ipayInfo) {
    appId = ipayInfo['appId'];
    h5 = ipayInfo['h5'];
    if (!h5) fluipay.register(appId: appId);  // SDK支付,调用sdk初始化
  }

  Future create(int uid, int money, int cid, int chapter) {    // 通过服务器下单, h5 sdk通用
    return FlutterComicClient.iPayOrder(API_HOSTNAME, uid, money, cid, chapter, h5);
  }

  Future<Map<String, dynamic>> pay(String transid) async {   // 调用sdk支付
    Map<String, dynamic> result = Map<String, dynamic>.from(await fluipay.pay(transid: transid));
    return Map<String, dynamic>.from(result['data']);
  }

  Future<Map<String, dynamic>> esure(int oid) async {     // 去服务端校验支付结果
    return await FlutterComicClient.esureIpayOrder(API_HOSTNAME, oid);
  }

  List<bool> check(String url, String urr, String url_h) {  // H5支付用于校验跳转url
    return [true, true];
  }

}


class IPayPage extends StatefulWidget {

  final int money;
  final UsersDao user = UsersDao(SingletonStore.store);
  final OnFinish callback;

  IPayPage({this.money, this.callback});

  @override
  _IPayPageState createState() => _IPayPageState();
}


class _IPayPageState extends State<IPayPage> {

  final flutterWebviewPlugin = FlutterWebviewPlugin();

  StreamSubscription<WebViewHttpError> _onHttpError;
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;

  bool finish = false;

  String transid;

  String url;
  String url_r;  // h5 支付成功请求url
  String url_h;  // h5 支付失败请求url

  int oid = 0;

  IPayApi iPayApi;

  BuildContext context;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> platform = Map<String, dynamic>.from(widget.user.platforms['ipay']);
    iPayApi = IPayApi(platform);
    if (iPayApi.appId != platform['appId']) {
      iPayApi = null;  // 接口单例,变更需要重启客户端
      return;
    }
    if (iPayApi.h5) {  // h5 支付使用webview
      flutterWebviewPlugin.close();

      _onHttpError =
          flutterWebviewPlugin.onHttpError.listen((WebViewHttpError error) {
            print('http error~~~~~~~~~~~~~~~~~~${error.code}~~~${error.url}');
          });

      _onDestroy =
          flutterWebviewPlugin.onDestroy.listen((_) {
            print('http destroy~~~~~~~~~~~~~~~~~~Webview ?}');
            setState(() {
              oid = -1;
            });
          });

      _onUrlChanged =
          flutterWebviewPlugin.onUrlChanged.listen((String url) async {
            if (finish) return null;
            print('http change url~~~~~~~~~~~~~~~~~~Webview change $url');
            List<bool> r = iPayApi.check(this.url, this.url_r, this.url_h);
            if (!r[0]) return null;

            finish = r[0];
            bool success = r[1];
            if (success) {
              int coins = 0;
              try {
                Map<String, dynamic> result = await iPayApi.esure(oid);
                success = result['success'];
                if (success) coins = result['coins'];
              } catch (_) {
                success = false;
              }
              if (success) {
                print('paypal success');
                SingletonStore.store.dispatch(ChangeCoins(payload: coins));
                if (widget.callback != null) widget.callback(true);
                Navigator.pop(this.context);
                return null;
              }
            }
            setState(() {
              if (widget.callback != null) widget.callback(false);
              oid = -2;
            });
          });
    }
    // 下单
    pay();
  }

  @override
  void dispose() {
    this.context = null;
    if (iPayApi.h5) {
      _onHttpError.cancel();
      _onDestroy.cancel();
      _onUrlChanged.cancel();
    }
    flutterWebviewPlugin.close();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  pay() async {
    Map<String, dynamic> createResult;
    try {
      createResult = await iPayApi.create(widget.user.uid, widget.money, widget.user.cid, 0);
      print('服务端下单成功, 下单金额 ${widget.money}');
    } catch (_) {
      print('服务端下单失败');
      print(_);
      setState(() {
        oid = -1;
      });
      return;
    }
    final Map<String, dynamic> ipayOrder = Map<String, dynamic>.from(createResult['ipay']);

    setState(() {
      oid = createResult['oid'];
      url = ipayOrder['url'];
      url_r = ipayOrder['url_r'];
      url_h = ipayOrder['url_h'];
      transid = ipayOrder['transid'];
      print('h5 pay url is ' + url);
    });

    if (!iPayApi.h5) { // 使用APP支付,直接调用爱贝sdk支付
      print('~~~~~~~~~~try pay by ipay api');
      final payResult = await iPayApi.pay(transid);
      print(payResult);
      print('~~~~~~~~~~try pay by ipay api success');
      Map<String, dynamic> esureResult = await iPayApi.esure(oid);
      print('~~~~~~~~~~esure success');
    }

  }

  @override
  Widget build(BuildContext context) {

    print('ipay build');

    this.context = context;

    if (widget.user.uid == 0 || widget.user.token.length == 0) {
      return Scaffold(
        appBar: AppBar(title: Center(child: Text(S.of(context).NoUserFound))),
        body: Center(
          child: Text(S.of(context).PayNotStart + ',' + S.of(context).NoUserFound + ',' + S.of(context).GoToLogin),
        ),
      );
    }

    if (oid < 0) {
      return Scaffold(
        appBar: AppBar(title: Center(child: Text('IPay Pay ' + S.of(context).RechargeError))),
        body: Center(
          child: Text(S.of(context).PayFail + ',' + S.of(context).ReturnAndPay),
        ),
      );
    }

    if (oid == 0) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(child: CircularProgressIndicator())
      );
    }


    if (iPayApi.h5) {
      return WebviewScaffold(
          url: url,
          appBar: AppBar(
            backgroundColor: Colors.orangeAccent,
            centerTitle: true,
            title: Center(child: Text(S.of(context).PayOrder)),
          ),
          headers: { 'Content-Type': 'text/html', 'User-Agent': 'For IAppPay'},
          withZoom: true,
          withJavascript: true,
          withLocalStorage: true,
          withLocalUrl: true,
          enableMessaging: true
      );
    }

    return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator())
    );

  }
}