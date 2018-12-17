import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/utils/requests.dart';
import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/actions/user.dart';

import 'package:fluwx/fluwx.dart' as fluwx;

import 'platforms.dart';


String getSystem() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'android';
  throw Exception('System type error');
}


class WeixinApi {

  static final _sys = getSystem();
  static final url = 'http://$API_HOSTNAME/n1.0${FlutterComicClient.platforms}/weixin';
  static final Map<String, WeixinApi> _instances = Map<String, WeixinApi>();

  StreamSubscription subscription;

  String appId;
  String partnerId;
  String package;

  factory WeixinApi(Map<String, String> wxInfo) {

    if (_instances.containsKey(WeixinApi._sys)) {
      return _instances[WeixinApi._sys];
    } else {
      final instance = WeixinApi._internal(wxInfo);
      _instances[WeixinApi._sys] = instance;
      return instance;
    }
  }

  WeixinApi._internal(Map<String, String> wxInfo) {
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
    return subscription == null;
  }

  Future create(int uid, int money, int cid, int chapter) {
    return FlutterComicClient.weixinOrder(API_HOSTNAME, money, uid, cid, chapter);
  }

  Future pay(int oid, String prepayId, String nonceStr, int timeStamp, String sign) {
    return fluwx.pay(appId: appId, partnerId: partnerId, prepayId: prepayId,
        packageValue: package, nonceStr: nonceStr,
        timeStamp: timeStamp, sign: sign);
  }

  Future<bool> esure(int oid) async {
    try {
      await FlutterComicClient.esureWeiXinOrder(API_HOSTNAME, oid);
      return true;

    } catch (_) {
      return false;
    }
  }

}


class WeiXinPage extends StatefulWidget {

  final int money;
  final UsersDao user = UsersDao(SingletonStore.store);
  final OnFinish callback;

  WeiXinPage({this.money, this.callback});

  @override
  _WeiXinPageState createState() => _WeiXinPageState();
}

class _WeiXinPageState extends State<WeiXinPage> {

  bool loading = true;
  int step = 1;

  bool stop = false;

  WeixinApi wxApi;

  BuildContext context;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> platform = widget.user.platforms['weixin'];
    wxApi = WeixinApi(platform);
    if (wxApi.appId != platform['appId']) wxApi = null;  // 微信接口单例,变更需要重启客户端
  }

  @override
  void dispose() {
    super.dispose();
    stop = true;
    wxApi.unlisten();
  }

  Future<Null> pay() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> result = await wxApi.create(widget.user.uid, widget.money, widget.user.cid, 0);  // 服务端下单,同步
    final Map<String, dynamic> wxOrder = result['weixin'];

    print('服务端下单成功');
    if (wxApi.listening) throw Exception('Api is listening');
    final int oid = result['oid'];

    await wxApi.pay(oid, wxOrder['prepayId'], wxOrder['random'], wxOrder['time'], wxOrder['sign'])   // 客户端支付协程
        .then((_) {
            step = 2;
            print('客户端支付成功');
          })
        .catchError((_) {
          setState(() {
            loading = false;
          });
          print('客户端支付失败');
        });

    if (step < 2 || stop) return;

    await Future.delayed(const Duration(seconds: 3));    // 等待服务端收到支付回调
    if (stop) return;

    wxApi.listen((_) async {      // 支付确认协程


      print(_);                    // 处理客户端支付回调

      setState(() {
        step = 0;
        loading = false;
      });

      return;


      int count = 3;
      print('客户端尝试确认支付');

      while (count>0) {
        if (await wxApi.esure(oid)) {
          print('客户端确认支付成功');
          SingletonStore.store.dispatch(ChangeCoins(payload: result['coins']));
          if (!stop) {
            wxApi.unlisten();
            setState(() {
              step = 0;
              loading = false;
            });
          }
          return;
        }
        if (stop) return;
        await Future.delayed(const Duration(seconds: 3));
        if (stop) return;
        count --;
      }

      if (stop) {
        wxApi.unlisten();
        setState(() {
          loading = false;
        });
      }
      print('客户端确认支付失败');
    });
  }


  @override
  Widget build(BuildContext context) {

    if (wxApi == null) 
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('微信支付API初始化失败'),
        ),
      );

    if (wxApi.listening)
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('上一个支付API未完成不能支付'),
        ),
      );


    return Scaffold(
     body: loading
         ? Center(child: CircularProgressIndicator())
         : Container(child: Text('step is $step'))
    );
  }
}