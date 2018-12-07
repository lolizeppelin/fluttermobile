import 'package:redux/redux.dart';

import 'package:flutter_manhua/redux/states/main.dart';

class ComicsDao {
  final Store<MainReduxState> store;

  ComicsDao(this.store);

  List<Map<String, dynamic>> get comics => this.store.state.comics.comics;
  bool get loading => this.store.state.comics.loading;

}
