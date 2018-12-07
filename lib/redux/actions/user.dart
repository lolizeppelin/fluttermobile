import 'package:flutter_manhua/redux/actions/main.dart';

class Login extends ActionType {
  final int payload;
  Login({this.payload}) : super(payload: payload);
}

class LoginOut extends ActionType {
  final int payload;
  LoginOut({this.payload}) : super(payload: payload);
}

class LoginSuccess extends ActionType {
  final Map<String, dynamic> payload;
  LoginSuccess({this.payload}) : super(payload: payload);
}

class FlushToken extends ActionType {
  final Map<String, dynamic> payload;
  FlushToken({this.payload}) : super(payload: payload);
}


class LoginFail extends ActionType {
  final String payload;
  LoginFail({this.payload}) : super(payload: payload);
}

class GetBooks extends ActionType {
  final int payload;
  GetBooks({this.payload}) : super(payload: payload);
}

class GetBooksSuccess extends ActionType {
  final List payload;
  GetBooksSuccess({this.payload}) : super(payload: payload);
}


class GetBooksFail extends ActionType {
  final String payload;
  GetBooksFail({this.payload}) : super(payload: payload);
}

class ChangeCoins extends ActionType {
  final int payload;
  ChangeCoins({this.payload}) : super(payload: payload);
}