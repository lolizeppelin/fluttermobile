import 'package:flutter/foundation.dart';

@immutable
class Comic {                   //漫画
  final int cid;                 //漫画ID
  final String name;            //漫画名
  final String author;          //作者
  final String summary;         //说明
  final String type;            //漫画类型
  final String ext;             //漫画图片扩展名字
  final int point;              //漫画收费章节

  Comic({this.cid, this.name, this.author, this.summary, this.type, this.ext, this.point});

  Comic.empty()
      : cid = 0,
        name = 'unkonwn',
        author = 'unkonwn',
        summary = 'unkonwn',
        type = 'unkonwn',
        ext = 'webp',
        point = 0;

}


@immutable
class Chapter {               //漫画章节
  final int index;            //章节
  final String key;           //加密KEY
  final String name;          //章节名
  final int max;              //章节最大页

  Chapter({this.index, this.key, this.name, this.max});

  update(String key) => Chapter(index: this.index,
      key: key, name: this.name, max: this.max);

}

@immutable
class User {                   //用户
  final int uid;               // 用户ID
  final String name;           // 用户名
  final String token;          // 用户TOKEN
  final int last;              // 最后登陆时间

  User({this.uid, this.name, this.token, this.last});

  newtoken(String token, int last) => User(uid: this.uid,
      name: this.name, token: token, last: this.last);

}