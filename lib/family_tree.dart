import 'package:family_tree_0/data.dart';
import 'package:family_tree_0/family_canvas.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

class FamilyTree extends StatefulWidget {
  @override
  _FamilyTreeState createState() => _FamilyTreeState();
}

class _FamilyTreeState extends State<FamilyTree> {
  double panX = 0;
  double panY = 0;
  double oldPointX = 0;
  double oldPointY = 0;

  List<CoupleModal> allCouples = [];

  @override
  void initState() {
    super.initState();
    CoupleModal topCouple = findAndGetCouple('1', 100, 100);
    allCouples.add(topCouple);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        child: GestureDetector(
          onPanUpdate: (details) {
            double currentX = details.globalPosition.dx;
            double currentY = details.globalPosition.dy;

            setState(() {
              panX += oldPointX - currentX;
              panY += oldPointY - currentY;
            });

            oldPointX = currentX;
            oldPointY = currentY;
          },
          onPanDown: (details) {
            double currentX = details.globalPosition.dx + panX;
            double currentY = details.globalPosition.dy + panY;

            //-pan because i have added pan at to the current value at the top
            oldPointX = currentX - panX;
            oldPointY = currentY - panY;

            checkIfClickedOnCouple(currentX, currentY);

            List<CoupleModal> clickedCouple =
                getCouplesThatAreClicked(currentX, currentY);

            moveExistingCouples(clickedCouple);

            addChildren(clickedCouple, currentX, currentY);
          },
          child: CustomPaint(
            child: Container(),
            painter: FamilyCanvas(
              panX: panX,
              panY: panY,
              allCouples: allCouples,
            ),
          ),
        ),
      ),
    );
  }

  List<CoupleModal> getCouplesThatAreClicked(double currentX, double currentY) {
    List<CoupleModal> clickedCouple = allCouples.where((couple) {
      return currentX >= couple.x - MEMBER_HORIZONTAL_GAP - CIRCLE_RADIUS &&
          currentX <= couple.x + MEMBER_HORIZONTAL_GAP + CIRCLE_RADIUS &&
          currentY >= couple.y - CIRCLE_RADIUS &&
          currentY <= couple.y + CIRCLE_RADIUS;
    }).toList();
    return clickedCouple;
  }

  void addChildren(
      List<CoupleModal> clickedCouple, double currentX, double currentY) {
    if (clickedCouple.length == 0 ||
        (clickedCouple[0].areChildrenLoaded) ||
        clickedCouple[0].children.length == 0) return;
    CoupleModal selectedCouple = clickedCouple[0];
    double centerX = selectedCouple.x;
    double centerY = selectedCouple.y;

    //relation -> single
    if (selectedCouple.member1 == null || selectedCouple.member2 == null) {
      //if not clicked of single member
      if (currentX > centerX + CIRCLE_RADIUS ||
          currentX < centerX - CIRCLE_RADIUS) return;
    }
    double startPosition;

    List childrenIds = selectedCouple.children;
    if (childrenIds.length % 2 == 0)
      startPosition = selectedCouple.x -
          (childrenIds.length / 2 * WIDTH_OF_COUPLE) -
          (childrenIds.length / 2 * COUPLE_HORIZONTAL_GAP / 2) +
          WIDTH_OF_COUPLE / 2;
    else
      startPosition = selectedCouple.x -
          (childrenIds.length ~/ 2 * WIDTH_OF_COUPLE) -
          (childrenIds.length ~/ 2 * COUPLE_HORIZONTAL_GAP);

    for (var i = 0; i < childrenIds.length; i++) {
      if (i == selectedCouple.children.length - 1)
        print(
            'end ${startPosition + (i * WIDTH_OF_COUPLE) + (i * COUPLE_HORIZONTAL_GAP)}');
      String childId = childrenIds[i];
      allCouples.add(
        findAndGetCouple(
          childId,
          startPosition + (i * WIDTH_OF_COUPLE) + (i * COUPLE_HORIZONTAL_GAP),
          centerY + COUPLE_VERTICAL_GAP,
        ),
      );
    }
    selectedCouple.areChildrenLoaded = true;
    setState(() {});
  }

  void moveExistingCouples(List<CoupleModal> clickedCouple) {
    if (clickedCouple.length == 0 ||
        (clickedCouple[0].areChildrenLoaded) ||
        clickedCouple[0].children.length == 0) return;
    CoupleModal selectedCouple = clickedCouple[0];

    double startPosition;

    List childrenIds = selectedCouple.children;
    int length = childrenIds.length;

    if (childrenIds.length % 2 == 0)
      startPosition = selectedCouple.x -
          (length / 2 * WIDTH_OF_COUPLE) -
          (length / 2 * COUPLE_HORIZONTAL_GAP / 2) +
          WIDTH_OF_COUPLE / 2;
    else
      startPosition = selectedCouple.x -
          (length ~/ 2 * WIDTH_OF_COUPLE) -
          (length ~/ 2 * COUPLE_HORIZONTAL_GAP);

    double endPosition = startPosition +
        ((length - 1) * WIDTH_OF_COUPLE) +
        ((length - 1) * COUPLE_HORIZONTAL_GAP);

    for (var i = 0; i < allCouples.length; i++) {
      CoupleModal couple = allCouples[i];
      if (couple.x < selectedCouple.x)
        couple.x = couple.x + startPosition - selectedCouple.x;

      if (couple.x > selectedCouple.x)
        couple.x = couple.x + endPosition - selectedCouple.x;
    }
  }

  checkIfClickedOnCouple(double currentX, double currentY) {}
}

CoupleModal findAndGetCouple(String id, double x, double y) {
  var membersRawData =
      members.where((member) => member['id'] == id).toList()[0];
  List children = membersRawData['children'];
  SingleMemberModal mainMember = SingleMemberModal.fromJson(membersRawData);
  if (mainMember.spouse == null)
    return CoupleModal(
      coupleId: mainMember.id,
      member1: mainMember,
      member2: null,
      children: children,
      areChildrenLoaded: false,
      x: x,
      y: y,
    );

  var spouseRawData =
      members.where((member) => member['id'] == mainMember.spouse).toList()[0];
  SingleMemberModal spouse = SingleMemberModal.fromJson(spouseRawData);
  return CoupleModal(
    //TODO: thinkk about couple id
    coupleId: mainMember.id,
    member1: mainMember,
    member2: spouse,
    children: children,
    areChildrenLoaded: false,
    x: x,
    y: y,
  );
}
