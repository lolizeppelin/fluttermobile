import 'package:flutter_manhua/redux/actions/main.dart';

import 'package:flutter_manhua/structs/main.dart';


class InToComic extends ActionType {
  final Comic payload;
  InToComic({this.payload}) : super(payload: payload);
}

class InToComicSuccess extends ActionType {
  final Map payload;
  InToComicSuccess({this.payload}) : super(payload: payload);
}

class InToComicFail extends ActionType {
  final int payload;
  InToComicFail({this.payload}) : super(payload: payload);
}


class OutComic extends ActionType {
  final int payload;
  OutComic({this.payload}) : super(payload: payload);
}

class ChangeChapter extends ActionType {
  final int payload;
  ChangeChapter({this.payload}) : super(payload: payload);
}


class BuyChapter extends ActionType {
  final int payload;
  BuyChapter({this.payload}) : super(payload: payload);
}


class BuyChapterSuccess extends ActionType {
  final Map payload;
  BuyChapterSuccess({this.payload}) : super(payload: payload);
}


class BuyChapterFail extends ActionType {
  final int payload;
  BuyChapterFail({this.payload}) : super(payload: payload);
}

