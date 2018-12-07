import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/pages/hot.dart';
import 'package:flutter_manhua/pages/book.dart';
import 'package:flutter_manhua/pages/user.dart';
import 'package:flutter_manhua/redux/store.dart';

import 'package:flutter_manhua/utils/requests.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/utils/timeutils.dart';


const yellow = Color.fromARGB(255, 255, 190, 50);
const grey = Colors.grey;

class TabPage extends StatefulWidget {

  final sqlite = SingletonStore.sqlite;
  final store = SingletonStore.store;

  @override
  _TabPageState createState() => _TabPageState();

}

class _TabPageState extends State<TabPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  TabController tabController;
  Timer timer;

  final StreamController<int> _changeController = StreamController.broadcast(sync: true);

  @override
  bool get wantKeepAlive => true;       // main页面不显示的情况下也不保留

  @override
  void initState() {
    print('init main!!!!');
    super.initState();

    tabController = TabController(vsync: this, length: 3);

    tabController.addListener(_notify);


    widget.sqlite.one().then((user) {
      if (user != null) {
        FlutterComicClient.autologin(API_HOSTNAME, user['name'], user['passwd']);
      } else {
        if (AUTOACCOUNT) {      // 自动注册
          FlutterComicClient.autoregister(API_HOSTNAME, null, null);
        }
      }
    });
    FlutterComicClient.comics(API_HOSTNAME);

    timer = Timer.periodic(Duration(seconds: 600), (t) {  // 定时更新token
      _flushToken();
    });
    WidgetsBinding.instance.addObserver(this);    // 监听事件注册

    _changeController.add(0);

  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(S.of(context).AreYouSure),
        content: new Text(S.of(context).DoYouWantExitApp),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(S.of(context).NO),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text(S.of(context).YES),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    tabController.removeListener(_notify);
    tabController.dispose();
  }

  void _notify() {
    _changeController.add(tabController.index);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed) {
      _flushToken();    //app唤醒 更新token
    }
  }

  void _flushToken() async {
    print('````````````````````````timer flush token ${unixtime()}````````````````````');
    Map user = await widget.sqlite.one();
    if (user != null) {
      if (widget.store.state.user.last > 0 && widget.store.state.user.token.length > 0 && (unixtime() - widget.store.state.user.last) > 600) return null;
      print('````````````````````````need flush token````````````````````');
      FlutterComicClient.fluthToken(API_HOSTNAME, user['name'], user['passwd']);
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> tabs = [
      TabIcons(_changeController, 0, S.of(context).HotTitle, Icons.home),
      TabIcons(_changeController, 1,  S.of(context).BookTitle, 'assets/book.png'),
      TabIcons(_changeController, 2,  S.of(context).PersonTitle, Icons.person),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: Material(
          color: Colors.white,
          child: TabBar(
            controller: tabController,
            indicatorColor: Colors.orangeAccent,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: tabController,
          children: <Widget>[
            HotPage(),
            BooksPage(tabController),
            UserPage(),
          ],
        ),
      )
    );

  }
}


class TabIcons extends StatefulWidget {

  final StreamController<int> notify;

  final int index;
  final String name;
  final icon;

  TabIcons(this.notify, this.index, this.name, this.icon);

  @override
  _TabIconsState createState() => _TabIconsState();


}


class _TabIconsState extends State<TabIcons> {

  StreamSubscription subscription;
  bool active = false;

  @override
  void initState() {
    super.initState();
    if (widget.index == 0 ) active = true;
    subscription =  widget.notify.stream.listen((index) {
      setState(() {
        active = widget.index == index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  Widget _icon() {
    switch (widget.icon.runtimeType) {
      case IconData: return Icon(widget.icon, size: 35.0, color: active ? yellow : grey);
      case String: return Container(height: 35.0, width: 35.0, child: Image.asset(widget.icon, color: active ? yellow : grey));
    }
    return  Icon(Icons.http, size: 35.0, color: active ? yellow : grey);
  }


  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 72.0,
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: _icon()
              ),
              Text(widget.name, softWrap: false, overflow: TextOverflow.fade)
            ]
        ),
        widthFactor: 1.0,
      ),
    );
  }

}