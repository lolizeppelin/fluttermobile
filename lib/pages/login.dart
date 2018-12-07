/*
copy from https://github.com/suyie001/flutter-login-ui
*/



import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';


import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';

import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/utils/requests.dart';

import 'package:flutter_manhua/redux/dao/users.dart';


class LoginPage extends StatefulWidget {// 登陆用页面, 输入账号密码的地方

  final sqlite = SingletonStore.sqlite;

  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {     // 登陆用页面, 输入账号密码的地方

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    passwdController.dispose();
  }

  @override
  void initState() {
    print('init login page');
    super.initState();
    widget.sqlite.one().then((user) {
      if (user != null) {
        setState(() {
          nameController.text =  user['name'];
          passwdController.text =  user['passwd'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/pg.png'),
      ),
    );

    final email = TextFormField(
      autofocus: false,
      controller: nameController,
      decoration: InputDecoration(
          hintText: S.of(context).NAME,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0)
          )
      ),
    );

    final password = TextFormField(
      autofocus: false,
      controller: passwdController,
      obscureText: true,
      decoration:  InputDecoration(
          hintText: S.of(context).PASSWORD,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0)
          )
      ),
    );


    final forgetLabel = FlatButton(
      onPressed: (){
        showDialog(
          context: context,
          builder: (BuildContext ctxt) {
            return AlertDialog(
                content: Text(S.of(context).LoginCleanThenRegister),
                actions:  <Widget>[
                  FlatButton(
                      onPressed: () {
                          widget.sqlite.clean();
                          nameController.text =  '';
                          passwdController.text = '';
                          FlutterComicClient.autoregister(API_HOSTNAME, null, null);
                          Navigator.pop(ctxt);
                          Navigator.pop(ctxt);
                        },
                      child: Text(S.of(context).YES)
                  ),
                  FlatButton(
                      onPressed: () {Navigator.pop(ctxt);},
                      child: Text(S.of(context).NO)
                  )
                ]
            );
          },
        );
      },
      child: Text('Auto register',style: TextStyle(color: Colors.black54),),
    );

    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).LoginTitle)),
        backgroundColor: Colors.white,
        body: StoreConnector<MainReduxState, UsersDao>(
          converter: (store) => UsersDao(store),
          builder: (context, dao) {
            if (dao.loading) return  Center(child: CircularProgressIndicator());
            return Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0,right: 24.0),
                children: <Widget>[
                  logo,
                  SizedBox(height: 24.0),
                  Center(
                    child: Text(dao.msg),
                  ),
                  SizedBox(height: 48.0),
                  email,
                  SizedBox(height: 8.0),
                  password,
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(32.0),
                      shadowColor: Colors.lightBlueAccent.shade100,
                      elevation: 5.0,
                      color : Colors.lightBlueAccent,
                      child: MaterialButton(
                        minWidth: 200.0,
                        height: 42.0,
                        onPressed: (nameController.text.length >= 3 && passwdController.text.length >= 6)
                            ? () {
                                    FlutterComicClient.autologin(API_HOSTNAME, nameController.text, passwdController.text)
                                        .then((success) {
                                          if (success) {
                                            Navigator.pop(context);
                                          } else {
                                            Scaffold.of(context).showSnackBar(SnackBar(content: new Text(S.of(context).LoginFail)));
                                          }
                                    });
                                }
                            : () { Scaffold.of(context).showSnackBar(SnackBar(content: new Text(S.of(context).LoginFailWithSize)));},
                        child: Text(S.of(context).Login, style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                  forgetLabel
                ],
              ),
            );
          }
        )
    );
  }
}