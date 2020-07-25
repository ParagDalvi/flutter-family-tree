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
    CoupleModal topCouple = findAndGetCouple('4', 100, 100);
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

  void checkIfClickedOnCouple(double currentX, double currentY) {
    List<CoupleModal> clickedCoupleList = allCouples.where((couple) {
      double xMax = couple.x + WIDTH_OF_COUPLE / 2;
      double xMin = couple.x - WIDTH_OF_COUPLE / 2;
      double yMax = couple.y + HEIGHT_OF_COUPLE / 2;
      double yMin = couple.y - HEIGHT_OF_COUPLE / 2;

      return currentX >= xMin &&
          currentX <= xMax &&
          currentY >= yMin &&
          currentY <= yMax;
    }).toList();

    if (clickedCoupleList.length == 0) return;

    CoupleModal selectedCouple = clickedCoupleList[0];

    //load children button constraints
    double childButtonXMax = selectedCouple.x + BUTTON_CIRCLE_RADIUS;
    double childButtonXMin = selectedCouple.x - BUTTON_CIRCLE_RADIUS;
    double childButtonYMax =
        selectedCouple.y + MEMBER_CIRCLE_RADIUS + (2 * BUTTON_CIRCLE_RADIUS);
    double childButtonYMin = selectedCouple.y + MEMBER_CIRCLE_RADIUS;

    //conditions for children button
    if (currentX >= childButtonXMin &&
        currentX <= childButtonXMax &&
        currentY >= childButtonYMin &&
        currentY <= childButtonYMax) {
      performAddChildren(
        selectedCouple,
      );
      return;
    }

    //load parents button constraints
    double parentsButtonXMax =
        selectedCouple.x + MEMBER_HORIZONTAL_GAP + BUTTON_CIRCLE_RADIUS;
    double parentsButtonXMin =
        selectedCouple.x + MEMBER_HORIZONTAL_GAP - BUTTON_CIRCLE_RADIUS;
    double parentsButtonYMax = selectedCouple.y - MEMBER_CIRCLE_RADIUS;
    double parentsButtonYMin =
        selectedCouple.y - MEMBER_CIRCLE_RADIUS - (2 * BUTTON_CIRCLE_RADIUS);

    //conditions for parent button
    if (currentX >= parentsButtonXMin &&
        currentX <= parentsButtonXMax &&
        currentY >= parentsButtonYMin &&
        currentY <= parentsButtonYMax) {
      performAddParents(
        selectedCouple,
        currentX,
        currentY,
      );
    }
  }

  void addChildrenToList(CoupleModal selectedCouple) {
    double centerY = selectedCouple.y;

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

  void moveExistingCouplesForChildren(CoupleModal selectedCouple) {
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

  void performAddChildren(
    CoupleModal selectedCouple,
  ) {
    moveExistingCouplesForChildren(selectedCouple);
    addChildrenToList(selectedCouple);
  }

  void performAddParents(
    CoupleModal selectedCouple,
    double currentX,
    double currentY,
  ) {
    moveExistingCouplesForParents(selectedCouple);
    addParentsToList(selectedCouple);
  }

  void moveExistingCouplesForParents(
    CoupleModal selectedCouple,
  ) {}

  void addParentsToList(
    CoupleModal selectedCouple,
  ) {
    String parentId = selectedCouple.member2.parents[0];
    CoupleModal parents = findAndGetCouple(
        parentId, selectedCouple.x + 20, selectedCouple.y - 100);
    allCouples.add(parents);
    performAddChildren(parents);
  }
}

CoupleModal findAndGetCouple(String id, double x, double y) {
  var membersRawData =
      members.where((member) => member['id'] == id).toList()[0];
  List children = membersRawData['children'];
  SingleMemberModal mainMember = SingleMemberModal.fromJson(membersRawData);
  mainMember.areParentsLoaded = true;
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
