import 'package:family_tree_0/family_tree.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  double panX = 0, panY = 0, oldX = 0, oldY = 0;

  List<CoupleModal> allCouples = [];
  bool isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    allCouples.add(findAndGetCouple('1', 100.0, 100.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Tree'),
      ),
      body: Builder(
        builder: (context) => GestureDetector(
          onPanDown: (details) {
            oldX = details.globalPosition.dx;
            oldY = details.globalPosition.dy;
            if (isBottomSheetOpen) {
              Navigator.pop(context);
              isBottomSheetOpen = false;
            }
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
            // color: Color(0xFFF0EFEF),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    // "https://i.pinimg.com/originals/0d/2d/f4/0d2df432e90873c838c9bbbb86273bc2.jpg",
                    // "https://www.autodesk.com/products/eagle/blog/wp-content/uploads/2017/02/EAGLE-Academy.jpg",
                    "https://as2.ftcdn.net/jpg/01/78/94/85/500_F_178948534_0SrSJhmWypuN2QRDZ8XA6f7nG1sp6Jfx.jpg"),
              ),
            ),
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: allCouples.map((couple) {
                return Transform(
                  transform: Matrix4.translationValues(
                    couple.x - panX,
                    couple.y - panY,
                    0,
                  ),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              height: MEMBER_CIRCLE_RADIUS + 60,
                              width: MEMBER_CIRCLE_RADIUS + 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                                color: couple.member1.gender == 'm'
                                    ? Colors.lightBlue
                                    : Colors.pinkAccent,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: EdgeInsets.only(top: 20),
                                    color: Colors.orangeAccent,
                                    height: 250,
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "https://i.pravatar.cc/150?u=${couple.member1.name}",
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          title: Text(
                                            couple.member1.name.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            couple.member1.gender == 'm'
                                                ? "Male"
                                                : "Female",
                                          ),
                                        ),
                                        ListTile(
                                          title: Text('9916715023'),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'CCB 13, new goods shed road, Belgaum',
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            '${couple.children.length} Children',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                isBottomSheetOpen = true;
                              },
                              child: Container(
                                height: MEMBER_CIRCLE_RADIUS + 50,
                                width: MEMBER_CIRCLE_RADIUS + 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orangeAccent,
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      // "https://api.adorable.io/avatars/285/${couple.member1.name}.png",
                                      // "https://avatars.dicebear.com/api/avataaars/${couple.member1.name}.svg",
                                      "https://i.pravatar.cc/150?u=${couple.member1.name}",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            couple.member1.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              shadows: [
                                BoxShadow(
                                  offset: Offset(
                                    0,
                                    1,
                                  ),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        !couple.areChildrenLoaded && couple.children.length != 0
                            ? FlatButton(
                                child: Icon(Icons.arrow_downward),
                                onPressed: () {
                                  if (couple.areChildrenLoaded) return;

                                  double startPosition;

                                  if (couple.children.length % 2 == 0)
                                    startPosition = couple.x -
                                        (couple.children.length /
                                            2 *
                                            COUPLE_HORIZONTAL_GAP) +
                                        COUPLE_HORIZONTAL_GAP /
                                            2; //this last addition is required
                                  else
                                    startPosition = couple.x -
                                        (couple.children.length ~/
                                            2 *
                                            COUPLE_HORIZONTAL_GAP);

                                  for (var i = 0;
                                      i < couple.children.length;
                                      i++) {
                                    String childId = couple.children[i];
                                    allCouples.add(findAndGetCouple(
                                      childId,
                                      startPosition +
                                          (i * COUPLE_HORIZONTAL_GAP),
                                      couple.y + COUPLE_VERTICAL_GAP + 40,
                                    ));
                                  }

                                  couple.areChildrenLoaded = true;
                                  setState(() {});
                                },
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
