import 'package:redux/redux.dart';

import 'package:flutter_manhua/utils/timeutils.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/structs/main.dart';

class ChaptersDao {
  final Store<MainReduxState> store;
  final sqlite = SingletonStore.sqlite;

  ChaptersDao(this.store);

  Comic get comic => this.store.state.comic.comic;

  UserState get user => this.store.state.user;
  bool get enough => this.store.state.user.coins >= this.store.state.user.one;
  int get one => this.store.state.user.one;
  List<Chapter> get chapters => this.store.state.comic.chapters;

  bool get loading => this.store.state.comic.loading || this.store.state.user.loading;

  int get index => this.store.state.comic.index;
  Chapter get chapter => this.store.state.comic.index >= 0 ? this.store.state.comic.chapters[this.store.state.comic.index] : null;
  Chapter get last => this.store.state.comic.index > 0 ? this.store.state.comic.chapters[this.store.state.comic.index-1] : null;
  Chapter get next => this.store.state.comic.index + 1 < this.chapters.length ? this.store.state.comic.chapters[this.store.state.comic.index+1] : null;


  bool get isMarked {
    if (this.user.uid == 0 || this.user.token.length == 0) return true;
    for (Map book in this.store.state.user.books) {
      if (book['cid'] == this.comic.cid) {
        return true;
      }
    }
    return false;
  }

  void addBook() {
    if (this.user.uid == 0 || this.user.token.length == 0) return null;
    this.store.state.user.books.insert(0, {
      'cid': this.comic.cid,
      'cname': this.comic.name,
      'author': this.comic.author,
      'ext': this.comic.ext,
      'mtime': unixtime(),
    });

    sqlite.favorite(this.user.uid,
        this.comic.cid, this.comic.name, this.comic.author, this.comic.ext);
  }

}
