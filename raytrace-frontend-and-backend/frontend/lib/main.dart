import 'dart:io';

import 'package:flutter/material.dart';

import 'homepage.dart';

void main() async {
  // ..close();

  // var sock = await ServerSocket.bind('localhost', 9999).then((x) {
  //   print('connected');
  //   return x;
  // });
  print('run app');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Final Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
