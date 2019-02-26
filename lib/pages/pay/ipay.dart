import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/utils/requests.dart';
import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/store.dart';

import 'package:fluwx/fluwx.dart' as fluwx;

import 'platforms.dart';


String getSystem() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'android';
  throw Exception('System type error');
}


class IPayApi {

  static final _sys = getSystem();
  static final url = 'http://$API_HOSTNAME/n1.0${FlutterComicClient.platforms}/weixin';
  static final Map<String, IPayApi> _instances = Map<String, IPayApi>();

  StreamSubscription subscription;

  String appId;
  String partnerId;
  String package;

  factory IPayApi(Map<String, dynamic> wxInfo) {

    if (_instances.containsKey(IPayApi._sys)) {
      return _instances[IPayApi._sys];
    } else {
      final instance = IPayApi._internal(wxInfo);
      _instances[IPayApi._sys] = instance;
      return instance;
    }
  }

  IPayApi._internal(Map<String, dynamic> wxInfo) {
    appId = wxInfo['appId'];
    partnerId = wxInfo['appId'];
    package = wxInfo['package'];
    fluwx.register(appId: appId);
  }


  void listen(callback) {
    if (subscription != null) throw Exception('Listen not cancel, can not listen new handle');
    subscription = fluwx.responseFromPayment.listen(callback);
  }

  void unlisten() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  bool get listening {
    return subscription != null;
  }

  Future create(int uid, int money, int cid, int chapter) {
    return FlutterComicClient.iPayOrder(API_HOSTNAME, money, uid, cid, chapter);
  }

  Future<bool> esure(int oid) async {
    try {
      await FlutterComicClient.esureIpayOrder(API_HOSTNAME, oid);
      return true;

    } catch (_) {
      return false;
    }
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


  bool conflict = false;

  bool loading = false;

  bool stop = false;

  String tid = '';

  String url;

  int oid = 0;

  IPayApi iPayApi;

  BuildContext context;

  @override
  void initState() {
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
            oid = -1;
          });
        });

    _onUrlChanged =
        flutterWebviewPlugin.onUrlChanged.listen((String url) {
          print('http change url~~~~~~~~~~~~~~~~~~Webview change}');
//          setState(() {
//            oid = -1;
//          });
        });



    Map<String, dynamic> platform = Map<String, dynamic>.from(widget.user.platforms['ipay']);
    iPayApi = IPayApi(platform);

    if (iPayApi.appId != platform['appId']) {
      iPayApi = null;  // 接口单例,变更需要重启客户端
      return;
    }
    if (iPayApi.listening) {
      conflict = true;
      return;
    }
    pay();
  }

  @override
  void dispose() {
    super.dispose();
    stop = true;

    this.context = null;
    _onHttpError.cancel();
    _onDestroy.cancel();
    flutterWebviewPlugin.dispose();

    if (iPayApi != null && !conflict) iPayApi.unlisten();
  }

  pay() async {

    setState(() {
      loading = true;
    });


    Map<String, dynamic> result;

    try {
      result = await iPayApi.create(widget.user.uid, widget.money, widget.user.cid, 0);
    } catch (_) {
      print('服务端下单失败');
      print(_);
      setState(() {
        oid = -1;
        loading = false;
      });
      return;
    }

    final Map<String, dynamic> ipayOrder = Map<String, dynamic>.from(result['ipay']);

    print('服务端下单成功');
    oid = result['oid'];
    url = ipayOrder['url'];
    if (stop) return;

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

    if (oid < 0) {
      return Scaffold(
        appBar: AppBar(title: Center(child: Text('IPay Pay ' + S.of(context).RechargeError))),
        body: Center(
          child: Text(S.of(context).PayFail + ',' + S.of(context).ReturnAndPay),
        ),
      );
    }


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
}