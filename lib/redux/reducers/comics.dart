import 'package:flutter_manhua/redux/actions/main.dart';
import 'package:flutter_manhua/redux/actions/comics.dart';

import 'package:flutter_manhua/redux/states/main.dart';


ComicsState reducer(ComicsState state, ActionType action) {

  print('reducer comics with ${action.runtimeType}');

  switch (action.runtimeType) {
    case ListComic:               //列出漫画
      return state.copyWith(loading: true);
    case ListComicFinish:        //列出漫画完成
      List<Map<String, dynamic>> comics = List<Map<String, dynamic>>.from(action.payload);
      return state.copyWith(loading: false, comics: comics);
    case ListComicFail:          //列出漫画失败
      return state.copyWith(loading: false);
  }

  return state;
}
