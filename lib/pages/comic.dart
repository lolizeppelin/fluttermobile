import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/structs/main.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/redux/dao/chapters.dart';
import 'package:flutter_manhua/redux/dao/users.dart';
import 'package:flutter_manhua/redux/actions/comic.dart';

import 'package:flutter_manhua/pages/chapter.dart';
import 'package:flutter_manhua/utils/requests.dart';


import 'package:flutter_manhua/pages/pay/recharge.dart';



typedef void AUTOPAY();


class ComicPage extends StatefulWidget {  // 漫画页面,列表显示章节

  final int cid;

  ComicPage({this.cid}){
    print('new comic page cid $cid');
  }

  @override
  _ComicPageState createState() => _ComicPageState();

}


class _ComicPageState extends  State<ComicPage> {

  final Store<MainReduxState> store = SingletonStore.store;
  BuildContext _context;
  Widget recharge;

  @override
  void initState() {
    print('init state comic');
    super.initState();
    FlutterComicClient.comic(API_HOSTNAME, widget.cid);
  }

  BuildContext get c => this._context;

  @override
  void dispose() {
    print('comic dispose');
    super.dispose();
    _context = null;
  }

  Widget _loading_button() {     // 章节数量空为空的刷新按钮
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () => FlutterComicClient.comic(API_HOSTNAME, widget.cid),
          child: Text(S.of(context).REFRESH, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _sliver_overlap_absorber(context, ChaptersDao dao) {     // 章节简介部分
    final String poster = 'http://$CDN_HOSTNAME/${dao.comic.cid}/main.${dao.comic.ext}';
    return
      SliverOverlapAbsorber(
      handle: NestedScrollView
          .sliverOverlapAbsorberHandleFor(context),
      child: SliverAppBar(
        backgroundColor: Colors.orange,
        title: Text(dao.comic.name),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(poster))
            ),
            child: ComicCover(comic: dao.comic, poster: poster),
          ),
        ),
        expandedHeight: 270.0,
        pinned: true,
      ),
    );
  }

  Widget _one_chapter_show_box(Chapter chapter, Comic comic) {    // 章节按钮

    bool needPay = chapter.index >= comic.point;
    bool beenPay = chapter.key.length > 0;

    return Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(200, 181,181,181), width: 1.0),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child:  Center(
                child: Text("${chapter.index}",   // 章节显示名
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0)),
              ),
            ),
          ),
          Container(
            alignment: Alignment(1.0, -0.9),
            child: needPay
                ? beenPay
                  ? Icon(Icons.lock_open, color: Colors.lightGreen)
                  : Icon(Icons.lock_outline, color: Colors.orangeAccent)
                : Container(),
          ),
        ]
    );
  }

  void unconver() {

    print('on cancel');

    setState(() {
      recharge = null;
    });
  }

  GestureDetector _need_pay_chapter_touch(UserState user, Chapter chapter,
      Comic comic, AUTOPAY autoPay) {

    return GestureDetector(
        onTap: () {

          if (user.uid <= 0 || user.token.length == 0 || user.coins < user.one) {          // 未登陆, 或者余额不足,打开充值遮罩
            setState(() {
              recharge = RechargeCover(
                unconver,
                unconver,
                (bool result) {unconver(); if (result) autoPay();},
                null,
              );
            });
            return null;
          }

          if (chapter.index == comic.point) {                                                                   // 第一个付费章节,需要用户确认才购买
            showDialog(
              context: c,
              builder: (BuildContext ctxt) {
                return AlertDialog(
//                    content: Text("支付 $ONE 购买章节(账户剩余${user.coins})"),
                    content: Text(S.of(context).PayWithUserLeft(user.one.toString(), user.coins.toString())),
                    actions:  <Widget>[
                      FlatButton(
                          onPressed: () {Navigator.pop(ctxt);},
                          child: Text(S.of(context).NO)
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(ctxt);
                            autoPay();
                          },
                          child: Text(S.of(context).YES)
                      )
                    ]
                );
              },
            );
            return null;
          }
          autoPay();
        },
        child: _one_chapter_show_box(chapter, comic)
    );
  }

  ListView _chapters(BuildContext context, ChaptersDao dao) {

   return ListView(
        children: <Widget>[
          SizedBox(height: 70.0),
          GridView.builder(
            itemCount: dao.chapters.length,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final Comic comic = dao.comic;
              final UserState user = dao.user;
              final Chapter chapter = dao.chapters[index];
              final Chapter last = index > 0 ? dao.chapters[index-1] : null;


              final bool needPay = chapter.key.length == 0 ? true : false;
              final bool lastPay = (index > 0 && last.key.length == 0) ? false : true;

              if (!needPay) {
                return GestureDetector(
                  onTap: () {
                    store.dispatch(ChangeChapter(payload: index));
                    Navigator.of(c).push(MaterialPageRoute(builder: (_) => ChapterPage()));      // 已付费或不需要付费
                  },
                  child: _one_chapter_show_box(chapter, comic)
                );
              }

              if (!lastPay) {                                                                   // 需要先购买上一章节
                return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: c,
                        builder: (BuildContext ctxt) {
                          return AlertDialog(
                              content: Text(S.of(context).LastPageNoPayed),
                              actions:  <Widget>[
                                FlatButton(
                                    onPressed: () {Navigator.pop(ctxt);},
                                    child: Text(S.of(context).SURE)
                                )
                              ]
                          );
                        },
                      );
                    },
                    child: _one_chapter_show_box(chapter, comic)
                );
              }


              AUTOPAY autoPay = () {                                                                              // 自动支付的闭包
                FlutterComicClient.buy(API_HOSTNAME, dao, chapter.index,
                        () {
                          if (recharge != null) recharge = null;
                          store.dispatch(ChangeChapter(payload: index));                                                // 自动购买成功
                          Navigator.of(c).push(MaterialPageRoute(builder: (_) =>  ChapterPage()));
                        },
                        (error) {                                                                                   // 自动购买失败
                          if (recharge != null) recharge = null;
                          showDialog(
                            context: c,
                            builder: (BuildContext ctxt) {
                              return AlertDialog(
                                  content: Text(S.of(context).PayFail),
                                  actions:  <Widget>[
                                    FlatButton(
                                        onPressed: () {Navigator.pop(ctxt);},
                                        child: Text(S.of(context).SURE)
                                    )
                                  ]
                              );
                            },
                          );
                    }
                );
              };

              return _need_pay_chapter_touch(user, chapter, comic, autoPay);
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 4 / 3,
                crossAxisCount: 4,
                crossAxisSpacing: 0.0),
          )
        ]);

  }


  Future<bool> _onWillPop() {

    ChaptersDao dao = ChaptersDao(store);

    if (dao.isMarked) {
      store.dispatch(OutComic(payload: 0));
      Navigator.of(_context).pop(true);
      return null;
    }

    return showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).AreYouSure),
        content: Text(S.of(context).AddToFavors),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              store.dispatch(OutComic(payload: 0));
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).NO),
          ),
          FlatButton(
            onPressed: () {
              dao.addBook();
              store.dispatch(OutComic(payload: 0));
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).YES),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    print('build comic');

    _context = context;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StoreConnector<MainReduxState, ChaptersDao>(
            converter: (store) => ChaptersDao(store),
            builder: (context, dao) {
              if (dao.loading) return Center(child: CircularProgressIndicator());

              List<Widget> stacks = [
                NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[_sliver_overlap_absorber(context, dao)];
                    },
                    body: dao.chapters.length == 0
                        ? _loading_button()
                        : _chapters(context, dao)
                )
              ];

              if (recharge !=null ) stacks.add(recharge);

              return Stack(
                children: stacks,
              );
            }
        ),
      )
    );
  }

}


class ComicCover extends StatelessWidget {    // 封面信息

  final Comic comic;
  final String poster;

  ComicCover({this.comic, this.poster});

  @override
  Widget build(context) {
    return Container(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: 80.0,
                    left: 8.0,
                    right: 8.0,
                    bottom: 30.0,
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Hero(
                            tag: poster,
                            child: Card(
                              color: Colors.white.withAlpha(100),
                              elevation: 5.0,
                              child: AspectRatio(
                                  aspectRatio: 3 / 4,
//                                  child: Image.network(poster, fit: BoxFit.cover)
                                  child: CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(comic.name, overflow: TextOverflow.ellipsis,  maxLines: 2,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                                ),
                                SizedBox(height: 10.0),
                                Text(comic.author ?? "", overflow: TextOverflow.ellipsis, maxLines: 1),
                                SizedBox(height: 3.0),
                                Text(comic.type ?? "", overflow: TextOverflow.ellipsis, maxLines: 1),
                                SizedBox(height: 3.0),
                                Expanded(
                                  child: Container(),
                                )
//                                Expanded(
//                                  child: Text('码发发码发发发码发发码发发发码发发码发发发码发发码发发发码发发码发发发码发发码发发发码发发码发发发码发发码发发发码发发码发发发', overflow: TextOverflow.ellipsis, maxLines: 4),
//                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.25)),
        ),
      ),
    );
  }
}