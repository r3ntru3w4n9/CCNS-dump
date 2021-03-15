import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todo/DummyData.dart';

import 'package:todo/pages/Home.dart';
import 'package:todo/pages/Add.dart';
import 'package:todo/objects/TodoObject.dart';

// import 'package:todo/DummyData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List> getTodo(database) async => await database.get().then((v) {
      v.docs.map((e) {
        print(e);
        return e;
      });
    });

// FIXME: UGLY HACK (also, it's that i'm rich as firestore charges by the amout of read and writes!!!)
uglyWriteAll(database) {
  dummy
      .asMap()
      .forEach((idx, value) => database.doc(idx.toString()).set(value.toMap()));

  print('written');
}

List uglyGetAll(database) {
  var todos = <TodoObject>[];
  var foreach = (QueryDocumentSnapshot doc) {
    if (doc.exists) {
      print(doc.data());
    }
  };
  var callback =
      (QuerySnapshot querySnapshot) => {querySnapshot.docs.forEach(foreach)};
  database.get().then(callback);

  print('gotten');
  return todos;
}

main() => runApp(App());

class Load extends StatelessWidget {
  static Future<List<TodoObject>> initAndGet() async {
    await Firebase.initializeApp();

    var collection = FirebaseFirestore.instance.collection('hw5');

    return uglyGetAll(collection);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initAndGet(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            exit(1);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            print('firebase connected');

            return HomePage();
          }

          return Container(
              child: Scaffold(
                  backgroundColor: Colors.blue,
                  body:
                      Center(child: SpinKitChasingDots(color: Colors.white))));
        });
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var add = Add();
    var load = Load();
    return MaterialApp(
      title: 'Flutter TODO',
      initialRoute: '/home',
      routes: {
        '/home': (_) => load,
        '/add': (_) => add,
      },
    );
  }
}
