import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/redux/reducers/user.dart' as user;
import 'package:flutter_manhua/redux/reducers/comic.dart' as comic;
import 'package:flutter_manhua/redux/reducers/comics.dart' as comics;


MainReduxState reduxReducer(MainReduxState state, action) => MainReduxState(
    user: user.reducer(state.user, action),
    comic: comic.reducer(state.comic, action),
    comics: comics.reducer(state.comics, action)
);
