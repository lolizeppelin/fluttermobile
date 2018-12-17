import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:sprintf/sprintf.dart';


import 'package:http/http.dart' as http;

import 'package:flutter_manhua/redux/store.dart';
//import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/structs/main.dart';
import 'package:flutter_manhua/redux/actions/comics.dart';
import 'package:flutter_manhua/redux/actions/comic.dart';
import 'package:flutter_manhua/redux/actions/user.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/redux/dao/books.dart';
import 'package:flutter_manhua/redux/dao/chapters.dart';


Uuid uuid = Uuid();


class FlutterComicClient {

  static const Map<String, String> TYPES = {'private': 'v1.0', 'public': 'n1.0'};

  static const users_path = '/fluttercomic/%s/users';
  static const user_path = '/fluttercomic/%s/users/%s';
  static const user_path_ex = '/fluttercomic/%s/users/%s/%s';

  static const comics_path = '/fluttercomic/%s/comics';
  static const comic_path = '/fluttercomic/%s/comics/%s';

  static const mark_path = '/fluttercomic/%s/comic/%s/user/%s';
  static const buy_path = '/fluttercomic/%s/comic/%s/chapter/%s/user/%s';
  static const chapter_path = '/fluttercomic/%s/comic/%s/chapters/%s';

  static const platforms = '/fluttercomic/orders/platforms';

  static const orders_path = '/fluttercomic/orders/platforms/%s';
  static const order_path = '/fluttercomic/orders/platforms/%s/%s';


  static String buildurl(String host, String path,
      List<String> args, String type) {
    final String version = TYPES[type];
    args.insert(0, type);
    final String url = sprintf('http://%s/%s%s', [host, version, sprintf(path, args)]);
    print('uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu');
    print(url);
    print('uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu');
    return url;
  }

  static Map<String, String> buildheader({Map<String, String> headers, bool fernet: true, String token: ''}) {
    final _headers = Map<String, String>.from(APIHEAD);
    if (headers != null) _headers.addAll(headers);
    if (fernet) _headers.addAll({FERNETHEAD: 'yes'});
    if (token.length > 0) {
      _headers.addAll({TOKENNAME: token});
    }
    return _headers;
  }


  static List getResult(http.Response response) {
    final Map raw = json.decode(response.body);
    if (raw['resultcode'] != 0) throw AssertionError('result code not 0');
    return raw['data'];
  }


  static login(String host, String name, String passwd) {
    final String url = buildurl(host, user_path_ex, [name, 'login'], 'public');
    return http.put(url, headers: buildheader(fernet: true),
        body: json.encode({'passwd': passwd}));
  }


  static register(String host, String name, String passwd) {
    final String url = buildurl(host, users_path, [], 'public');
    return http.post(url, headers: buildheader(fernet: true),
        body: json.encode({'name': name, 'passwd': passwd}));
  }


  static Future<bool> autologin(String host, String name, String passwd) async {
    SingletonStore.store.dispatch(Login(payload: 0));
    try {
      http.Response response = await login(host, name, passwd);
      Map<String, dynamic> userinfo = Map<String, dynamic>.from(FlutterComicClient.getResult(response)[0]);
      userinfo.addAll({'passwd': passwd});
      SingletonStore.store.dispatch(LoginSuccess(payload: userinfo));
      localbooks();
      return true;
    } catch(e) {
      SingletonStore.store.dispatch(LoginFail(payload: 'auto login catch error'));
      return false;
    }
  }


  static autoregister(String host, String name, String passwd) async {
    name = name ?? uuid.v1().replaceAll('-', '');
    passwd = passwd ?? uuid.v4().substring(0, 6);
    final SqliteDb sqlite = SingletonStore.sqlite;
    SingletonStore.store.dispatch(Login(payload: 0));
    try {
      http.Response response = await register(host, name, passwd);
      Map<String, dynamic> userinfo = Map<String, dynamic>.from(FlutterComicClient.getResult(response)[0]);
      print(userinfo);
      userinfo.addAll({'passwd': passwd});
      await sqlite.save(uid: userinfo['uid'], passwd: passwd, last: 0);
      SingletonStore.store.dispatch(LoginSuccess(payload: userinfo));
    } catch(e) {
      SingletonStore.store.dispatch(LoginFail(payload: 'auto register catch error'));
    }
  }


  static fluthToken(String host, String name, String passwd) async {
    try {
      http.Response response = await login(host, name, passwd);
      Map<String, dynamic> userinfo = Map<String, dynamic>.from(FlutterComicClient.getResult(response)[0]);
      SingletonStore.store.dispatch(FlushToken(payload: userinfo));
    } catch(e) {
      print('flush token fail');
    }
  }


  static comics(String host) {
    print('get comics');
    String url = buildurl(host, comics_path, [], 'public');
    SingletonStore.store.dispatch(ListComic(payload: 0));
    http.get(url,  headers: buildheader())
        .then((response) {
          List _comics = getResult(response);
          SingletonStore.store.dispatch(ListComicFinish(payload: _comics));
    })
        .catchError((error) {
      SingletonStore.store.dispatch(ListComicFail(payload: 0));
    });
  }


  static comic(String host, int cid) {
    String url = buildurl(host, comic_path, [cid.toString()], 'public');
    SingletonStore.store.dispatch(InToComic(payload: Comic.empty()));
    http.get(url,  headers: buildheader(token: SingletonStore.store.state.user.token))
        .then((response) {
      Map _comic = getResult(response)[0];
      print('reslut of show $_comic');
      SingletonStore.store.dispatch(InToComicSuccess(payload: _comic));
    })
        .catchError((error) {
      SingletonStore.store.dispatch(InToComicFail(payload: 0));
    });
  }


  static books(String host, BooksDao dao) {

    if (dao.logined && !dao.loading) {
      final String url = buildurl(host, user_path_ex, [dao.uid.toString(), 'books'], 'private');
      SingletonStore.store.dispatch(GetBooks(payload: 0));
      http.get(url,  headers: buildheader(token: SingletonStore.store.state.user.token))
          .then((response) {
            List _books = getResult(response);
            SingletonStore.store.dispatch(GetBooksSuccess(payload: _books));})
          .catchError((error) {
            SingletonStore.store.dispatch(GetBooksFail(payload: error.toString()));
          });
    }
  }


  static Future localbooks() {

    return SingletonStore.sqlite.getBooks()
        .then((books) { SingletonStore.store.dispatch(GetBooksSuccess(payload: books));})
        .catchError((e) { });
  }


  static buy(String host, ChaptersDao dao, int chapter, onSuccess, onFail) {

    if (!dao.loading) {
      final String url = buildurl(host, buy_path, [dao.comic.cid.toString(), chapter.toString(), dao.user.uid.toString()], 'private');
      SingletonStore.store.dispatch(BuyChapter(payload: 0));
      return http.post(url, headers: buildheader(token: SingletonStore.store.state.user.token))
          .then((response) {
        Map comic = getResult(response)[0];
        SingletonStore.store.dispatch(BuyChapterSuccess(payload: comic));
        SingletonStore.store.dispatch(ChangeCoins(payload: -dao.one));
        onSuccess();
      })
          .catchError((error) {
        SingletonStore.store.dispatch(BuyChapterFail(payload: 0));
        onFail(error);
      });
    }
  }


  static Future<Map<String, dynamic>> weixinOrder(String host, int uid, int money, int cid, int chapter) async {
    final String url = buildurl(host, orders_path, ['weixin'], 'public');
    Map<String, dynamic> result;
    await http.post(url,
      headers: FlutterComicClient.buildheader(),
      body: {
        'money': money,
        'cid': cid,
        'chapter': chapter,
        'uid': uid,
      },
    ).then((response) {
      result = Map<String, dynamic>.from(FlutterComicClient.getResult(response)[0]);
    });
    return result;
  }


  static Future<Map<String, dynamic>> esureWeiXinOrder(String host, int oid) async {
    final String url = buildurl(host, order_path, ['weixin', oid.toString()], 'public');
    Map<String, dynamic> result;
    await http.get(url,
      headers: FlutterComicClient.buildheader(token: SingletonStore.store.state.user.token),
    ).then((response) {
      result = Map<String, dynamic>.from(FlutterComicClient.getResult(response)[0]);
    });
    return result;
  }

}