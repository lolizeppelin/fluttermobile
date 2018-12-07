import 'package:flutter/foundation.dart';
import 'package:flutter_manhua/structs/main.dart';


@immutable
class ComicsState {

  final List<Map<String, dynamic>> comics; //漫画列表
  final int index;                          //漫画列表所在位置
  final bool loading;                       //加载中

  ComicsState({this.comics, this.index, this.loading});

  ComicsState copyWith({List<Map<String, dynamic>> comics, int, index, bool loading}) {

    return ComicsState(
        comics: comics ?? this.comics,
        index: index ?? this.index,
        loading: loading ?? this.loading);
  }

  ComicsState.initialState()
      : comics = [],
        index = 0,
        loading = false;

}
