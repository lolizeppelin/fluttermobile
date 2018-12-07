import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';

import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/redux/dao/books.dart';

import 'package:flutter_manhua/pages/comic.dart';
import 'package:flutter_manhua/pages/login.dart';

import 'package:flutter_manhua/utils/requests.dart';


class BooksPage extends StatefulWidget {    // 用户收藏书架页面

  final Store<MainReduxState> store = SingletonStore.store;
  final TabController tabController;

  BooksPage(this.tabController);


  @override
  _BooksPageState createState() => _BooksPageState();
}


class _BooksPageState extends State<BooksPage> {

  static String cdnTranslate(BooksDao dao, int index) {
    Map<String, dynamic> _book = dao.books[index];
    return 'http://$CDN_HOSTNAME/${_book['cid']}/main.${_book['ext']}';
  }

  @override
  void initState() {
    print('init books!!!!');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print('build books');

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: Center(child: Text(S.of(context).MyBooks)),
        ),
        body: StoreConnector<MainReduxState, BooksDao>(
            converter: (store) => BooksDao(store),
            builder: (context, dao) {
              if (dao.loading) return  Center(child: CircularProgressIndicator());
              if (!dao.logined) {
                return Center(
                  child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(left: 24.0,right: 24.0),
                      children: <Widget>[
                        Hero(
                          tag: 'login',
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 48.0,
                            child: Image.asset('assets/pg.png'),
                          ),
                        ),
                        Center(
                            child: Text(S.of(context).GoToLogin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))
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
                                Navigator
                                    .of(context)
                                    .push(MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                              child: Text(S.of(context).GoToLogin, style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        )
                      ]
                  ),
                );
              }

              if (dao.books.length == 0 ) {
                return Center(
                  child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                          child: Image.asset('assets/pg.png'),
                        ),
                        Center(
                            child: Text(S.of(context).BooksIsEmpty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.grey))
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          child: Container(
                            width: 140,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              border: Border.all(color: Colors.orangeAccent)
                            ),
                            child: Center(
                              child: Text(S.of(context).FindBooks, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0, color: Colors.orangeAccent)),
                            )
                          ),
                          onTap: (){widget.tabController.index = 0;},
                        ),
                      ]
                  ),
                );
              }

              return Container(
                child: ListView.builder(
                    itemCount: dao.books.length,
                    itemBuilder: (_context, index) {
                      return Container(
                        height: 145.0,
                        padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  height: 130.0,
                                  child: GestureDetector(
                                    onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => ComicPage(cid: dao.books[index]['cid'])));},
                                    child: AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: CachedNetworkImage(imageUrl: cdnTranslate(dao, index), fit: BoxFit.fitHeight)
                                    ),
                                  )
                                ),
                                SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(dao.books[index]['cname']),
                                    SizedBox(height: 8.0),
                                    Text(dao.books[index]['author']),
                                    SizedBox(height: 8.0),
                                    Text(dao.books[index]['mtime'].toString()),
                                  ],
                                ),
                                Expanded(
                                    child: Container()
                                ),
                                Card(
                                  elevation: 2.0,
                                  color: Colors.orangeAccent,
                                  child: Container(
                                    width: 60.0,
                                    height: 40.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: _context,
                                          builder: (context) => AlertDialog(
                                            title: Text(S.of(context).AreYouSure),
                                            content: Text(S.of(context).DeleteFromFavors),
                                            actions: <Widget>[
                                              FlatButton(
                                                onPressed: () =>  Navigator.of(context).pop(),
                                                child: Text(S.of(context).NO),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    print('delete book');
                                                    dao.delBook(dao.books[index]['cid']);
                                                  });
                                                },
                                                child: Text(S.of(context).YES),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Center(
                                        child: Text(S.of(context).CANCEL),
                                      ),
                                    )
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 8.0)
                          ],
                        ),
                      );
                    }
                ),
              );
            }
        )
    );
  }
}
