import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';


import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/redux/dao/users.dart';


import 'package:flutter_manhua/pages/login.dart';

import 'package:flutter_manhua/pages/pay/platforms.dart';


class CurvedEdge extends CustomClipper<Path>{      // 弧形

  final double curved;

  CurvedEdge(this.curved);

  @override
  Path getClip(Size size) {

    Path path = Path();
    path.lineTo(0.0, size.height);

    Offset cPoint = Offset(size.width/2, size.height-curved);
    Offset endPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(cPoint.dx, cPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0.0, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CurvedEdge oldClipper) {
    return false;
  }

}


class UserPage extends StatefulWidget {              // 用户信息页面

  final Store<MainReduxState> store = SingletonStore.store;
  final SqliteDb sqlite = SingletonStore.sqlite;

  @override
  _UserPageState createState() => _UserPageState();
}


class _UserPageState extends State<UserPage> {

  @override
  Widget build(BuildContext context) {

    print('build user');

    return Scaffold(
        backgroundColor: Colors.white,
        body: StoreConnector<MainReduxState, UsersDao>(
            converter: (store) => UsersDao(store),
            builder: (context, dao) {
              if (dao.loading) return  Center(child: CircularProgressIndicator());
              if (dao.name.length == 0 || dao.token.length == 0) {
                return Center(
                  child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        Center(
                          child: Container(
                            height: 120.0,
                            child: Image.asset('assets/pg.png'),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Center(
                          child: Text(S.of(context).GoToLogin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(32.0),
                            shadowColor: Colors.lightBlueAccent.shade100,
                            color: Colors.lightBlueAccent,
                            elevation: 5.0,
                            child: MaterialButton(
                              minWidth: 200.0,
                              height: 42.0,
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                              child: Text(S.of(context).GoToLogin, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ]
                  ),
                );
              }

              return Center(
                child: Column(
//                  padding: EdgeInsets.only(left: 24.0,right: 24.0),
                  children: <Widget>[
                    Container(
                      height: 260,
                      child: Stack(
                        children: <Widget>[
                          ClipPath(
                              clipper: CurvedEdge(65),
                              child: Container(
                                height: 200,
                                color: Colors.orangeAccent,
                              )
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 100.0),
                              Center(
                                child: Container(
                                  height: 120.0,
                                  child: ClipOval(
                                    child: Image.asset('assets/pg.png', fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Center(
                                child: Text(S.of(context).UserLeft + ': ' + dao.coins.toString() + ' ' + S.of(context).CoinName,
                                    style: TextStyle(color: Colors.deepOrange, fontSize: 18.0, fontWeight: FontWeight.w400)),
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                    Opacity(opacity: 0.15, child: Container(color: Colors.grey, height: 5.0)),
                    SizedBox(height: 5.0),
                    PlateFormChoice(null, null, null),
                  ],
                ),
              );
            }
        )
    );
  }
}
