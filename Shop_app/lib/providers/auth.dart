import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
class Auth with ChangeNotifier {
    String _token;
    DateTime _expiryDate;
    String _userId;
    Timer _authTimer;

    bool get isAuth {
      return token != null;
    }

    String get token {
      if(_expiryDate != null && _token != null && _expiryDate.isAfter(DateTime.now())) {
        return _token;
      }
      return null;
    }

    String get userID {
      return _userId;
    }

    Future<void> _authenticate (String email, String passWord, String urlSegment) async {
      final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAc7R9XwaghZrdGGBCASlpL730lgNQiGW0');
      // okay
      try {
        final response = await http.post(
          url,
          body: json.encode(
            {
              'email': email,
              'password': passWord,
              'returnSecureToken': true,
            },
          ),
        );

        final responseData =json.decode(response.body);

        if(responseData['error'] != null){
          throw HTTPException(responseData['error']['message']);
        }

        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn']
            ),
          )
        );
        _autoLogOut();
        notifyListeners();
        final preferences = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        });
        preferences.setString('userData', userData);
      } catch (error) {
        throw error;
      }
    }

    Future<void> signUp (String email, String passWord) async {
      return _authenticate(email, passWord, 'signUp');
    }

    Future<void> logIn (String email, String passWord) async {
      return _authenticate(email, passWord, 'signInWithPassword');
    }

    Future<bool> tryAutoLogin() async{
      final preferences = await SharedPreferences.getInstance();
      if(!preferences.containsKey('userData')){
        return false;
      }

      final extractedUserData = json.decode(preferences.getString('userData')) as Map<String, Object>;
      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
      if(expiryDate.isBefore(DateTime.now())){
        return false;
      }
      _token = extractedUserData['token'];
      _userId = extractedUserData['userId'];
      _expiryDate = expiryDate;
      notifyListeners();
      _autoLogOut();
      return true;
    }

    Future<void> logOut() async{
      _userId = null;
      _expiryDate = null;
      _token = null;
      if(_authTimer != null){
        _authTimer.cancel();
        _authTimer = null;
      }
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      //prefs.remove('userData');
      prefs.clear();
    }

    void _autoLogOut () {

      if(_authTimer != null) {
        _authTimer.cancel();
      }
      final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(
        Duration(
          seconds: timeToExpire,
        ),
        logOut,
      );
    }
}