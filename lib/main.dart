import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/pages/main.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/redux/store.dart';

void main() {
  final Store<MainReduxState> store = SingletonStore.store;
  final SqliteDb sqlite = SingletonStore.sqlite;
  runApp(ComicApp(store: store, sqlite: sqlite,));
}

class ComicApp extends StatelessWidget {
  final Store<MainReduxState> store;
  final SqliteDb sqlite;

  ComicApp({this.store, this.sqlite});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<MainReduxState>(
        store: store,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
//          debugShowCheckedModeBanner: true,
          theme: ThemeData(
            primaryColor: Colors.orangeAccent
          ),
          home: TabPage(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
        ));
  }
}
