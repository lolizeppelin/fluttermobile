import 'package:flutter_manhua/redux/actions/main.dart';
import 'package:flutter_manhua/redux/actions/comic.dart';

import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/structs/main.dart';


ComicState reducer(ComicState state, ActionType action) {

  print('reducer comic with ${action.runtimeType}');

  switch (action.runtimeType) {
    case InToComic:
      return state.copyWith(comic: Comic.empty(), index: -1, loading: true);
    case InToComicSuccess:
      Map<String, dynamic> comicinfo = Map<String, dynamic>.from(action.payload);
      final Comic comic = Comic(cid: comicinfo['cid'], name: comicinfo['name'], author: comicinfo['author'], type: comicinfo['type'], ext: comicinfo['ext'], point: comicinfo['point']);
      final List<Chapter> chapters = [];
      comicinfo['chapters'].forEach((v) => chapters.add(Chapter(index: v['index'], key: v['key'], name: '第${v['index']}章', max: v['max'])));
      return state.copyWith(comic: comic, chapters: chapters, loading: false);
    case InToComicFail:
      return state.copyWith(chapters: [], loading: false);
    case OutComic:
      return state.copyWith(comic: Comic.empty(), index: -1, chapters: [], loading: false);
    case ChangeChapter:
      return state.copyWith(index: action.payload);
    case BuyChapter:
      return state.copyWith(comic: state.comic, chapters: state.chapters, loading: true);
    case BuyChapterSuccess:
      Map<String, dynamic> comicinfo = Map<String, dynamic>.from(action.payload);
      final List<Chapter> chapters = [];
      comicinfo['chapters'].forEach((v) => chapters.add(Chapter(index: v['index'], key: v['key'], name: '第${v['index']}章', max: v['max'])));
      return state.copyWith(chapters: chapters, loading: false);
    case BuyChapterFail:
      return state.copyWith(loading: false);
  }
  return state;
}




