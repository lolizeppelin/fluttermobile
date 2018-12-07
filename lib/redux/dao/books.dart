import 'package:redux/redux.dart';

import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/structs/main.dart';

class BooksDao {
  final Store<MainReduxState> store;
  final sqlite = SingletonStore.sqlite;

  BooksDao(this.store);

  List<Map<String, dynamic>> get books => this.store.state.user.books;
  int get uid => this.store.state.user.uid;
  String get token => this.store.state.user.token;
  String get name => this.store.state.user.name;
  bool get loading => this.store.state.user.loading;
  bool get logined => this.store.state.user.name.length > 0 && this.store.state.user.token.length > 0;
  Comic get comic => this.store.state.comic.comic;

  void delBook(int cid) {
    if (this.uid == 0 || this.token.length == 0) return null;

    print('delete !');

    for (Map<String, dynamic> book in this.store.state.user.books) {
      if (book['cid'] == cid) {
        this.store.state.user.books.remove(book);
        sqlite.unFavorite(this.uid, cid);
        break;
      }
    }
  }

}
