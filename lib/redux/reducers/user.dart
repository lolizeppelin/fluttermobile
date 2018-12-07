import 'package:flutter_manhua/constant/common.dart';

import 'package:flutter_manhua/utils/timeutils.dart';

import 'package:flutter_manhua/redux/actions/main.dart';
import 'package:flutter_manhua/redux/actions/user.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/redux/store.dart';


UserState reducer(UserState state, ActionType action) {

  print('reducer user with ${action.runtimeType}');

  switch (action.runtimeType) {
    case Login:
      return state.login();
    case LoginOut:
      return UserState.initialState();
    case LoginSuccess:
      {
        final int last = unixtime() + TOKENEXPIRE;
        final int uid = action.payload['uid'];
        final String name = action.payload['name'];
        final String token = action.payload['token'];
        final int coins = action.payload['coins'];
        print(action.payload);
        final int one = action.payload['one'];
        final Map<String, Map> platforms = Map<String, Map>.from(action.payload['platforms']);
        SingletonStore.sqlite.save(uid: uid, name: name, passwd: action.payload['passwd']);
        return state.loginSuccess(name: name, uid: uid, token: token, coins: coins, last: last, one: one, platforms: platforms);
      }
    case LoginFail:
      return UserState.initialState();
    case FlushToken:
      Map<String, dynamic> userinfo = Map<String, dynamic>.from(action.payload);
      final int last = unixtime() + TOKENEXPIRE;
      return state.copyWith(token: userinfo['token'], last: last);
    case GetBooks:
      return state.getBooks();
    case  GetBooksFail:
        return state.getBooksFail(msg: action.payload);
    case GetBooksSuccess:
      {
        List<Map<String, dynamic>> books = [];
        action.payload.forEach((v) => books.add(Map<String, dynamic>.from(v)));
        return state.getBooksSuccess(books: books);
      }
    case ChangeCoins:
      return state.changeCoins(coins: state.coins+action.payload);
  }
  return state;
}
