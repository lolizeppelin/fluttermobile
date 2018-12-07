import 'dart:async';

import 'package:flutter/material.dart';

import 'package:redux/redux.dart';

import 'package:photo_view/photo_view.dart';


import 'package:flutter_manhua/generated/i18n.dart';

import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/structs/main.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/actions/comic.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/utils/requests.dart';

import 'package:flutter_manhua/redux/dao/chapters.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_manhua/pages/pay/platforms.dart';
import 'package:flutter_manhua/pages/pay/recharge.dart';


final bool last = false;
final bool next = true;


class ChapterPage extends StatefulWidget {

  final Store<MainReduxState> store = SingletonStore.store;

  ChapterPage() { print('new chapter page');}

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> { // 章节内容页面

  final String cdnhost = CDN_HOSTNAME;
  final ScrollController _controller = ScrollController();

  ChaptersDao dao;

  final List<int> images = [];

  int start = 0;

  bool networking = false;

  Widget recharge;

  double height;

  @override
  void initState() {
    super.initState();

    dao = ChaptersDao(widget.store);
    start = dao.index;                                 // 页面刷新时的章节

    images.add(dao.chapter.max);    // 当前章节页数

    _controller.addListener(() {    // 到底以后继续拉不会被监听到,所以需要触底后回滚一点点距离方便触发
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _fetchMore(next);
      }
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _counts => images.fold(0, (p, c) => p + c);

  String _translate(int pindex) {

    int page;
    int pages = 0;
    int count;
    Chapter chapter;
    for (int i = 0; i <images.length; i++) {
        count = images[i];
        pages += count;
        if (pages > pindex)  {
          chapter = dao.chapters[start+i];
          if (i == 0) {
            page = pindex + 1;
          }
          else {
            pages -= count;
            page = pindex - pages + 1;
          }
          String url = 'http://$CDN_HOSTNAME/${dao.comic.cid}/${chapter.index}/$page.${dao.comic.ext}';
          print(url);
          return url;
        }
    }
    return 'http://$CDN_HOSTNAME/error.html';
  }

  Future _fetchMore(bool down) async {
    print('call fetch more');
    if (networking) return null;

    if (!down) {                                                     // 上翻
      if (dao.last == null) return null;
      setState(() {
        images.clear();
        widget.store.dispatch(ChangeChapter(payload: dao.last.index));
        start = dao.index;
        images.add(dao.chapter.max);
      });
      return null;
    }

    if (dao.next == null) return null;                             // 最大章节

    _controller.jumpTo(_controller.position.maxScrollExtent - 0.3);  // 回滚0.3方便再次触发触底事件激活遮罩

    Chapter chapter = dao.next;
    if (chapter.key.length == 0) {                                   // 章节未付费
      print('~~~~~~~~need pay~~~~~~~~~~~~point ${dao.comic.point}  chapter ${chapter.index}');
      final UserState user = dao.user;
      // TODO 用户token过期重登陆处理
      if (user.uid > 0 && user.token.length > 0 && dao.enough && dao.comic.point < chapter.index) {      // 余额足够,不是第一个付费章节,自动购买
        return _autoPay(true);
      } else {
        setState(() {
          recharge = RechargeCover(
              () { setState(() { recharge = null; });},
              () { setState(() {  recharge = null; });},
              _autoPay,
              EdgeInsets.only(top: height),
          );
        });
      }
    } else {
      print('~~~~~~~~do not need pay~~~~~~~~~~~~');
      setState(() {
        images.add(dao.chapter.max);
        widget.store.dispatch(ChangeChapter(payload: dao.next.index));
      });
    }
  }

  OnFinish _autoPay(bool result) {

    print('try auto pay');

    if (!result) {
      setState(() {recharge = null;} );
      return null;
    }

    setState(() {recharge = null; networking = true;} );

    Chapter chapter = dao.next;

    return FlutterComicClient.buy(API_HOSTNAME, dao, chapter.index,
      () {                           // 自动购买成功
            setState(() {
              widget.store.dispatch(ChangeChapter(payload: chapter.index));
              images.add(dao.chapter.max);
              networking = false;
            });
      },
      (error) {                     // 自动购买失败
            setState(() {
              networking = false;
            });
      });
  }

  @override
  Widget build(BuildContext context) {

    print('build chapter ${dao.chapter.index} with image $images');

    if (height == null) {
      final mediaQuery = MediaQuery.of(context);
      height = mediaQuery.size.height/2.5;
    }

    List<Widget> stacks = [
      RefreshIndicator(
        child: ListView.builder(
          controller: _controller,
          itemCount: _counts,
          itemBuilder: (context, index) => Container(
              constraints:  BoxConstraints(minHeight: 120.0),
              child: CachedPic(url: _translate(index))
          ),
        ),
        onRefresh: () => _fetchMore(last),// 上一章
      )
    ];


    if (recharge != null) {
      stacks.add(recharge);
    }

    return Scaffold(
//        appBar: AppBar(title: Text('第${dao.chapter.index}章'), backgroundColor: Colors.orangeAccent),
        appBar: AppBar(title: Text(S.of(context).ChapterPageNo(dao.chapter.index.toString())),
            backgroundColor: Colors.orangeAccent),
        body: Stack(
          children: stacks
        ),
    );
  }
}

class CachedPic extends StatefulWidget {

  final String url;
  static final String placeholder = "assets/empty.png";

  CachedPic({this.url});

  @override
  _CachedPicState createState() => _CachedPicState();
}

class _CachedPicState extends State<CachedPic> {

  OverlayEntry _scaleImg;
  bool showScale = false;

  Future<bool> _onWillPop() {
    if (showScale) {
      _scaleImg.remove();
      showScale = false;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();
    // 单图放大
    _scaleImg = OverlayEntry(builder: (context) {
      return GestureDetector(
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.only(top: 100.0, bottom: 100.0),
          child: PhotoView(imageProvider: CachedNetworkImageProvider(widget.url)),
        ),
        onTap: () {
          _scaleImg.remove();
          showScale = false;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: GestureDetector(
          child: CachedNetworkImage(imageUrl: widget.url, fit: BoxFit.fitWidth,
              placeholder: Image.asset(CachedPic.placeholder, fit: BoxFit.fitHeight)),
          onTap: () {
            Overlay.of(context).insert(_scaleImg);
            showScale = true;
          },
        ),
        onWillPop: _onWillPop
    );
  }
}
