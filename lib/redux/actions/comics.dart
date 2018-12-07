import 'package:flutter_manhua/redux/actions/main.dart';

class ListComic extends ActionType {
  final int payload;
  ListComic({this.payload}) : super(payload: payload);
}

class ListComicFinish extends ActionType {
  final List payload;
  ListComicFinish({this.payload}) : super(payload: payload);
}

class ListComicFail extends ActionType {
  final int payload;
  ListComicFail({this.payload}) : super(payload: payload);
}
