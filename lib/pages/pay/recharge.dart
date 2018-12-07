import 'package:flutter/material.dart';

import 'package:redux/redux.dart';


import 'package:flutter_manhua/generated/i18n.dart';
import 'package:flutter_manhua/constant/common.dart';
import 'package:flutter_manhua/redux/store.dart';
import 'package:flutter_manhua/redux/states/main.dart';

import 'package:flutter_manhua/redux/dao/chapters.dart';

import 'package:flutter_manhua/pages/login.dart';
import 'package:flutter_manhua/pages/pay/platforms.dart';

class RechargeCover extends StatefulWidget {

  final Store<MainReduxState> store = SingletonStore.store;

  final Confirm confirmCallback;
  final Cancel cancelCallback;
  final OnFinish finishCallback;

  final EdgeInsets edgeInsert;


  RechargeCover(Confirm confirmCallback, Cancel cancelCallback,
      OnFinish finishCallback, EdgeInsets edgeInsert)
      : confirmCallback = confirmCallback,
        cancelCallback = cancelCallback,
        finishCallback = finishCallback,
        edgeInsert = edgeInsert ?? EdgeInsets.only(left: 30.0, right: 30.0, top: 120.0, bottom: 120.0);



  @override
  _RechargeCoverState createState() => _RechargeCoverState();
}


class _RechargeCoverState extends State<RechargeCover> {

  final String cdnhost = CDN_HOSTNAME;
  ChaptersDao dao;

  @override
  void initState() {
    super.initState();
    dao = ChaptersDao(widget.store);
  }

  Widget _loginWidget() {

    return ListView(
      children: <Widget>[
        SizedBox(height: 12.0),
        Center(child: Text(S.of(context).GoToLogin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))),
        SizedBox(height: 24.0),
        Material(
            borderRadius: BorderRadius.circular(32.0),
            shadowColor: Colors.lightBlueAccent.shade100,
            color: Colors.lightBlueAccent,
            elevation: 5.0,
            child: MaterialButton(
              minWidth: 200.0,
              height: 42.0,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(S.of(context).Login, style: TextStyle(color: Colors.white)),
            )
        ),
        SizedBox(height: 24.0),
        Material(
            borderRadius: BorderRadius.circular(32.0),
            shadowColor: Colors.lightBlueAccent.shade100,
            color: Colors.lightBlueAccent,
            elevation: 5.0,
            child: MaterialButton(
              minWidth: 200.0,
              height: 42.0,
              onPressed: () {
                if (widget.cancelCallback != null) widget.cancelCallback();
              },
              child: Text(S.of(context).GoBack, style: TextStyle(color: Colors.white),),
            )
        ),
      ],
    );
  }

  Widget _rechargeWidget() {


    return Column(
      children: <Widget>[
        Container(
          height: 50.0,
          child: Stack(
            children: <Widget>[
              Center(child: Text(S.of(context).AfterPay, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black54))),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  SizedBox(height: 35.0, width: 35.0,
                      child: GestureDetector(
                        child: Icon(Icons.clear, color: Colors.grey),
                        onTap: () {
                          if (widget.cancelCallback != null) widget.cancelCallback();
                          },
                  ))
                ],
              )
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 8.0),
              child: Text(S.of(context).NEED + S.of(context).Pay + ':', style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0, color: Colors.deepOrangeAccent))
            )),
            Container(
              padding: EdgeInsets.only(left: 2.0, right: 2.5),
              child: Text('${dao.one}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0, color: Colors.deepOrangeAccent))
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(S.of(context).CoinName, style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0, color: Colors.deepOrangeAccent))
              ),
            )
          ],
        ),

        Container(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  !dao.enough
                      ? PlateFormChoice(widget.confirmCallback, widget.cancelCallback, widget.finishCallback)
                      : Material(
                    type: MaterialType.button,
                    borderRadius: BorderRadius.circular(32.0),
                    shadowColor: Colors.lightBlueAccent.shade100,
                    color: Colors.lightBlueAccent,
                    elevation: 5.0,
                    child: MaterialButton(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        onPressed: () {
                          widget.finishCallback(true);
                        },
                        child: Text(S.of(context).PayBuyCoin, style: TextStyle(color: Colors.white))),
                  ),
                  SizedBox(height: 10.0),
                  !dao.enough
                      ? Container()
                      : Material(
                    type: MaterialType.button,
                    borderRadius: BorderRadius.circular(32.0),
                    shadowColor: Colors.lightBlueAccent.shade100,
                    color: Colors.lightBlueAccent,
                    elevation: 5.0,
                    child: MaterialButton(
                        padding: EdgeInsets.all(25.0),
                        onPressed: () {
                          if (widget.cancelCallback != null) widget.cancelCallback();
                        },
                        child: Text(S.of(context).CANCEL, style: TextStyle(color: Colors.white))),
                  ),
                ],
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 5.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(S.of(context).UserLeft + ':', style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0, color: Colors.deepOrangeAccent))
              )),
              Container(
                  padding: EdgeInsets.only(left: 2.0, right: 2.5),
                  child: Text('${dao.user.coins}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0, color: Colors.deepOrangeAccent))
              ),
              Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(S.of(context).CoinName, style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0, color: Colors.deepOrangeAccent))
                ),
              )
            ],
          ),
        )
      ],
    );

  }


  @override
  Widget build(BuildContext context) {

    print('build RechargeCover');
    bool login = (dao.user.uid > 0 && dao.user.token.length > 0);

    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            child: Opacity(opacity: 0.5, child: Container(color: Colors.grey)),
            onTap: () { if (widget.cancelCallback != null) widget.cancelCallback(); },
          ),
        ),
        Container(
            height: login ? 410.0: 250.0,
            child: Stack(
              children: <Widget>[
                Opacity(opacity: 1.0, child: Container(color: Colors.white)),
                login ?  _rechargeWidget() : _loginWidget()
              ],
            )
        )
      ],
    );
  }
}