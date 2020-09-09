import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/family_tree.dart';
import 'package:flutter/material.dart';

import 'native_ui/native_family_tree.dart';

final firestoreInstance = FirebaseFirestore.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: MyHomePage(),
      // home: FamilyTree(),
      home: NavtiveFamilyTree(),
    );
  }
}
