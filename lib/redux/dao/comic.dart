import 'package:redux/redux.dart';

import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/structs/main.dart';

class ComicsDao {
  final Store<MainReduxState> store;

  ComicsDao(this.store);

  Comic get comic => this.store.state.comic.comic;
  bool get loading => this.store.state.comic.loading;
  bool get enough => this.store.state.user.coins >= this.store.state.user.one;

  bool forbidden(chapter) => this.store.state.comic.chapters[chapter].key == '';
}
