import 'package:redux/redux.dart';

import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/structs/main.dart';

class UsersDao {
  final Store<MainReduxState> store;

  UsersDao(this.store);

  String get name => this.store.state.user.name;
  int get uid => this.store.state.user.uid;
  int get coins => this.store.state.user.coins;
  int get last => this.store.state.user.last;
  int get one => this.store.state.user.one;
  Map<String, Map> get platforms => this.store.state.user.platforms;
  bool get enough => this.store.state.user.coins >= this.store.state.user.one;
  bool get loading => this.store.state.user.loading;
  String get msg => this.store.state.user.msg;
  String get token => this.store.state.user.token;
  int get cid => this.store.state.comic.comic.cid;

}
