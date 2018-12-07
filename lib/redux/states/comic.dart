import 'package:flutter/foundation.dart';
import 'package:flutter_manhua/structs/main.dart';


@immutable
class ComicState {

  final Comic comic;                        //当前漫画
  final int index;                          //当前章节LIST下表
  final List<Chapter> chapters;             //所有章节列表
  final bool loading;                       //加载中

  ComicState({this.comic, this.index, this.chapters, this.loading});

  ComicState copyWith({Comic comic, int index,
    List<Chapter> chapters, bool loading}) {

    return ComicState(
        comic: comic ?? this.comic,
        index: index ?? this.index,
        chapters: chapters ?? this.chapters,
        loading: loading ?? this.loading,
    );
  }

  ComicState.initialState()
      : comic = Comic.empty(),
        index = -1,
        chapters = [],
        loading = true;
}
