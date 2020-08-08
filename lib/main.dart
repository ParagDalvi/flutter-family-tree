import 'package:family_tree_0/family_tree.dart';
import 'package:flutter/material.dart';

import 'native_ui_test.dart';

const MEMBER_RADIUS = 20.0;
const HORIZONTAL_GAP = 70.0;
const VERTICAL_GAP = 60.0;

class MemberRaw {
  double x, y;
  final String id, name, spouse;
  final List children;
  bool areChildrenLoaded;

  MemberRaw({
    @required this.id,
    @required this.x,
    @required this.y,
    @required this.name,
    @required this.children,
    @required this.spouse,
    @required this.areChildrenLoaded,
  });
}

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
      // home: FamilyTree(),
      home: Test(),
    );
  }
}
