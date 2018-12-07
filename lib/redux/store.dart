import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:redux/redux.dart';

import 'package:mutex/mutex.dart';

import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/redux/states/main.dart';
import 'package:flutter_manhua/redux/states/user.dart';
import 'package:flutter_manhua/redux/states/comic.dart';
import 'package:flutter_manhua/redux/states/comics.dart';

import 'package:flutter_manhua/redux/reducers/main.dart';
import 'package:flutter_manhua/utils/timeutils.dart';


Future<Database> open() async {
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, DBFILE);

  Database database = await openDatabase(path, version: 2,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute("CREATE TABLE users (uid INTEGER PRIMARY KEY, name TEXT, passwd TEXT, last BIGINT)");
        await db.execute("CREATE TABLE books (uid INTEGER, cid INTEGER, cname TEXT, author TEXT, ext TEXT, mtime INTEGER, PRIMARY KEY (uid, cid))");
      });
  return database;

}


class SqliteDb {

  Database _db;
  final _lock = new ReadWriteMutex();

  Future<Null> save({uid, name, passwd, last}) async {
    _lock.acquireWrite();
    try {
      if (_db == null) _db = await open();
      await _db.delete('users');
      await _db.insert('users', {'uid': uid, 'name': name,
        'passwd': passwd, 'last': last});
    } finally {
      _lock.release();
    }
  }

  Future<Null> newpass(int uid, String passwd) async {
    // 更新本地密码
    _lock.acquireWrite();
    try {
      if (_db == null) _db = await open();
      await _db.update('users', { 'last': 0, 'passwd': passwd},
          where: 'uid = ?', whereArgs: [uid]);
    } finally {
      _lock.release();
    }
  }

  Future<Null> lastup(int uid) async {
    // 更新本地最后登陆时间
    _lock.acquireWrite();
    try {
      if (_db == null) _db = await open();
      await _db.update('users', { 'last': 0 }, where: 'uid = ?', whereArgs: [uid]);
    } finally {
      _lock.release();
    }
  }


  Future<List<Map>> getUsers() async {
    _lock.acquireRead();
    try {
      if (_db == null) _db = await open();
      List<Map> maps = await _db.query('users', columns: ["*"],
          orderBy: "last desc");
      return maps;
    } finally {
      _lock.release();
    }
  }

  Future<Map<String, dynamic>> getUser(String name) async {
    _lock.acquireRead();
    try {
      if (_db == null) _db = await open();
      List<Map> users = await _db.query('users', columns: ["*"],
          where: "name = ?", whereArgs: [name],
          orderBy: "last desc");
      if (users.length > 0) return users[0];
      return null;
    } finally {
      _lock.release();
    }
  }

  Future<List<Map>> getBooks() async {
    _lock.acquireRead();
    try {
      if (_db == null) _db = await open();
      List<Map> maps = await _db.query('books', columns: ["*"],
          orderBy: "mtime desc");
      return maps;
    } finally {
      _lock.release();
    }
  }


  Future<Map<String, dynamic>> one() async {
    _lock.acquireRead();
    try {
      if (_db == null) _db = await open();
      List<Map<String, dynamic> >users = await getUsers();
      if (users.length > 0) return users[0];
      return null;
    } finally {
      _lock.release();
    }
  }

  Future<Null> favorite(int uid, int cid, String cname, String author, String ext) async {
    _lock.acquireWrite();
    try {
      if (_db == null) _db = await open();
      await _db.insert('books', {'uid': uid, 'cid': cid, 'cname': cname,
        'author': author, 'ext': ext, 'mtime': unixtime()});
    } finally {
      _lock.release();
    }
  }

  Future<Null> unFavorite(int uid, int cid) async {
    _lock.acquireWrite();
    try {
      if (_db == null) _db = await open();
      await _db.delete('books', where: 'uid = ? and cid = ?',
          whereArgs: [uid, cid]);
    } finally {
      _lock.release();
    }
  }


  Future<Null> clean() async {
    _lock.acquireRead();
    try {
      if (_db == null) _db = await open();
      await _db.delete('users');
      await _db.delete('books');
      return null;
    } finally {
      _lock.release();
    }
  }

}


class SingletonStore {

  static final SingletonStore _store = SingletonStore._internal();

  static final Store<MainReduxState> store = Store<MainReduxState>(
      reduxReducer,
      initialState: MainReduxState(
          user: UserState.initialState(),
          comic: ComicState.initialState(),
          comics: ComicsState.initialState()
      )
  );

  static final SqliteDb sqlite = SqliteDb();

  factory SingletonStore() => _store;

  SingletonStore._internal();

}