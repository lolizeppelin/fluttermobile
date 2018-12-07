import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/pages/comic.dart';

import 'package:flutter_manhua/constant/common.dart';

import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/redux/dao/comics.dart';
import 'package:flutter_manhua/utils/requests.dart';

import 'package:cached_network_image/cached_network_image.dart';

class HotPage extends StatefulWidget {   // 热门漫画页面,主页面，显示漫画列表

  final Store<MainReduxState> store = SingletonStore.store;

  HotPage() {
    print('new HotPage');
  }

  @override
  _HotPageState createState() => _HotPageState();
}


class _HotPageState extends State<HotPage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  static String cdnTranslate(ComicsDao dao, int index) {
    Map<String, dynamic> _comic = dao.comics[index];
    return 'http://$CDN_HOSTNAME/${_comic['cid']}/main.${_comic['ext']}';
  }

  @override
  void initState() {
    print('init hot!!!!');
    super.initState();
  }

  @override
  void dispose() {
    print('wtf  dispose hot?');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('build hot');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Center(child: Text(S.of(context).AppName)),
      ),
      body: StoreConnector<MainReduxState, ComicsDao>(
        converter: (store) => ComicsDao(store),
        builder: (context, dao) {
          if (dao.loading) return Center(child: CircularProgressIndicator());
          if (dao.comics.length == 0 ) {
            return Center(
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 24.0,right: 24.0),
                  children: <Widget>[
                    Hero(
                      tag: 'nocomic',
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 48.0,
                        child: Image.asset('assets/pg.png'),
                      ),
                    ),
                    Center(
                        child: Text(S.of(context).ComicIsEmpty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(32.0),
                        shadowColor: Colors.lightBlueAccent.shade100,
                        color: Colors.lightBlueAccent,
                        elevation: 5.0,
                        child: MaterialButton(
                          minWidth: 200.0,
                          height: 42.0,
                          onPressed: (){
                            FlutterComicClient.comics(API_HOSTNAME);
                          },
                          child: Text(S.of(context).REFRESH, style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    )

                  ]
              ),
            );
          }
          return StaggeredGridView.countBuilder(
            primary: false,
            crossAxisCount: 3,
            mainAxisSpacing: 3.0,
            crossAxisSpacing: 3.0,
            itemCount: dao.comics.length,
            itemBuilder: (context, index) =>
                GestureDetector(
                    child: Container(
                      height: 200.0,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
//                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 3 / 4,
                                child: CachedNetworkImage(imageUrl: cdnTranslate(dao, index), fit: BoxFit.cover),
                              ),
                              Text(dao.comics[index]['name'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text(dao.comics[index]['author'], style: TextStyle(color: Color.fromARGB(255, 129, 133, 137)), overflow: TextOverflow.ellipsis, ),
                            ]
                        ),
                      )
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ComicPage(cid: dao.comics[index]['cid'])));
                    },
                  ),
            staggeredTileBuilder: (index) => StaggeredTile.fit(1),
          );
        }
      )
    );
  }
}
