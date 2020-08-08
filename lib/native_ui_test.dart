import 'package:family_tree_0/family_tree.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  double panX = 0, panY = 0, oldX = 0, oldY = 0;

  List allCouples = [];

  @override
  void initState() {
    super.initState();
    allCouples.add(findAndGetCouple('1', 100.0, 100.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onPanDown: (details) {
          oldX = details.globalPosition.dx;
          oldY = details.globalPosition.dy;
        },
        onPanUpdate: (details) {
          setState(() {
            panX += oldX - details.globalPosition.dx;
            panY += oldY - details.globalPosition.dy;
          });
          oldX = details.globalPosition.dx;
          oldY = details.globalPosition.dy;
        },
        child: Container(
          color: Colors.amber,
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: allCouples.map((e) {
              return Transform(
                transform:
                    Matrix4.translationValues(e['x'] - panX, e['y'] - panY, 0),
                child: GestureDetector(
                  onTap: () => print('clicked'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.lightGreen,
                      // image: DecorationImage(
                      //   image: NetworkImage(
                      //       "https://pub.dev/static/img/pub-dev-logo-2x.png?hash=umitaheu8hl7gd3mineshk2koqfngugi"),
                      // ),
                    ),
                    child: Center(child: Text('POPO')),
                    height: 200,
                    width: 200,
                    // color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
