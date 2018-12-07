import 'package:flutter/foundation.dart';
import 'package:flutter_manhua/utils/timeutils.dart';

@immutable
class UserState {
  final String name;                         // name
  final int uid;                             // uid
  final int last;                            // 登陆时间
  final String token;                        // token
  final int coins;                           // 代币
  final List<Map<String, dynamic>> books;   // 书架
  final bool loading;                       // 加载中
  final int one;                            // 当前用户章节单价
  final Map<String, Map> platforms;         // 支付渠道信息
  final String msg;                         // 登陆信息


  UserState({this.name, this.uid, this.last,
    this.token, this.coins, this.books, this.loading,
    this.one, this.platforms, this.msg});

  UserState copyWith({String name, int uid, int last, String token,
    int coins, List<Map<String, dynamic>> books,
    bool loading, int one, Map<String, Map> platforms,
    String msg}) {
    return UserState(
        name: name ?? this.name,
        uid: uid ?? this.uid,
        last: last ?? this.last,
        token: token ?? this.token,
        coins: coins ?? this.coins,
        books: books ?? this.books,
        loading: loading ?? this.loading,
        one: one ?? this.one,
        platforms: platforms ?? this.platforms,
        msg: msg ?? this.msg,
    );
  }

  UserState login() {
    return UserState(
      name: this.name,
      uid: this.uid,
      last: this.last,
      token: this.token,
      coins: this.coins,
      books: this.books,
      loading: true,
      one: this.one,
      platforms: this.platforms,
      msg: '',
    );
  }

  UserState loginSuccess({@required String name, @required int uid,
    @required int last, @required String token, @required int coins,
    @required int one, @required Map<String, Map> platforms
  }) {
    return UserState(name: name, uid: uid,
        last: unixtime(), token: token, coins: coins, books: [],
        loading: false ,
        one: one, platforms: platforms,
        msg: 'Welecom back $name');
  }

  UserState loginFail({@required String name}) {
    return UserState(
      name: '',
      uid: 0,
      last: 0,
      token: '',
      coins: 0,
      books: [],
      loading: false,
      one: 0,
      platforms: {},
      msg: 'Login fail for $name',
    );
  }

  UserState getBooks() {
    return UserState(name: this.name, uid: this.uid,
        last: this.last, token: this.token,
        coins: this.coins, books: books, loading: this.loading,
        one: this.one,
        platforms: this.platforms, msg: '');
  }

  UserState getBooksSuccess({@required List<Map<String, dynamic>> books}) {
    return UserState(
        name: this.name,
        uid: this.uid,
        last: this.last,
        token: this.token,
        coins: this.coins,
        books: books,
        loading: this.loading,
        one: this.one,
        platforms: this.platforms,
        msg: 'Get books success');
  }

  UserState getBooksFail({@required String msg}) {
    return UserState(
      name: this.name,
      uid: this.uid,
      last: this.last,
      token: this.token,
      coins: this.coins,
      books: this.books,
      loading: this.loading,
      one: this.one,
      platforms: this.platforms,
      msg: 'Get books for $name fail $msg',
    );
  }

  UserState changeCoins({@required int coins}) {
    return UserState(
      name: this.name,
      uid: this.uid,
      last: this.last,
      token: this.token,
      coins: coins,
      books: this.books,
      loading: this.loading,
      one: this.one,
      platforms: this.platforms,
      msg: '',
    );
  }

  UserState.initialState()
      : name = '',
        uid = 0,
        last = 0,
        token = '',
        coins = 0,
        books = [],
        loading = false,
        one = 0,
        platforms = {},
        msg = '';

}
