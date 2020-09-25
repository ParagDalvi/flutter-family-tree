import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'native_ui/native_family_tree.dart';

final firestoreInstance = FirebaseFirestore.instance;

Color darkBlueColor = Color(0xff309abb);
Color lightBlueColor = Color(0xff8ed0e2);
Color blackDarkColor = Color(0xff1c1c1c);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: NavtiveFamilyTree(),
    );
  }
}
