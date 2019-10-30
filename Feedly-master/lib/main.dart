import 'package:flutter/material.dart';
import 'package:flutter_feedly/pages/loginPage.dart';
import 'package:flutter_feedly/pages/signupPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blueGrey,
      ),
      home: LoginPage(),
    );
  }
}