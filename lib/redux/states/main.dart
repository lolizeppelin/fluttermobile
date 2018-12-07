import 'package:flutter/foundation.dart';
import 'package:flutter_manhua/redux/states/comics.dart';
import 'package:flutter_manhua/redux/states/comic.dart';
import 'package:flutter_manhua/redux/states/user.dart';

export 'package:flutter_manhua/redux/states/comics.dart';
export 'package:flutter_manhua/redux/states/comic.dart';
export 'package:flutter_manhua/redux/states/user.dart';

@immutable
class MainReduxState {

  final UserState user;
  final ComicState comic;
  final ComicsState comics;

  const MainReduxState({this.user, this.comic, this.comics});

}
