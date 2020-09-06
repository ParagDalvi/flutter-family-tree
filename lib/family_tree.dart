import 'package:family_tree_0/data.dart';
import 'package:family_tree_0/canvas/family_canvas.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

class FamilyTree extends StatefulWidget {
  @override
  _FamilyTreeState createState() => _FamilyTreeState();
}

class _FamilyTreeState extends State<FamilyTree> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  List<CoupleModal> allCouples = [];
  Image some;

  @override
  void initState() {
    super.initState();
    CoupleModal topCouple = findAndGetCouple('1', 100, 100);
    allCouples.add(topCouple);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _zoom = _previousZoom * details.scale;
    setState(() {
      _zoom = _zoom.clamp(0.7, 1.7430);

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = details.focalPoint - normalizedOffset * _zoom;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onTapDown: _handleTap,
          child: CustomPaint(
            child: Container(),
            painter: FamilyCanvas(
              zoom: _zoom,
              offset: _offset,
              allCouples: allCouples,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    Offset position = details.globalPosition;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Size size = Size(width, height);

    final Offset center = size.center(Offset.zero) * _zoom + _offset;
    final double radius = size.width / 20 * _zoom;

    for (var i = 0; i < allCouples.length; i++) {
      CoupleModal couple = allCouples[i];
      Offset offset = center + Offset(couple.x, couple.y);

      if (position.dx <= offset.dx + radius &&
          position.dx >= offset.dx - radius &&
          position.dy >= offset.dy - radius &&
          position.dy <= offset.dy + radius) {
        print('clicked on ${couple.member1.name}');
      }
    }
  }

  void checkIfClickedOnCouple(
    double currentX,
    double currentY,
  ) {
    List<CoupleModal> clickedCouple = allCouples.where((couple) {
      double xMax = couple.x + WIDTH_OF_COUPLE / 2;
      double xMin = couple.x - WIDTH_OF_COUPLE / 2;
      double yMax = couple.y + HEIGHT_OF_COUPLE / 2;
      double yMin = couple.y - HEIGHT_OF_COUPLE / 2;

      return currentX >= xMin &&
          currentX <= xMax &&
          currentY >= yMin &&
          currentY <= yMax;
    }).toList();

    if (clickedCouple.length == 0) return;

    CoupleModal selectedCouple = clickedCouple[0];

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

    //load parents button constraints for single person
    double parentsButtonXMax = selectedCouple.x + BUTTON_CIRCLE_RADIUS;
    double parentsButtonXMin = selectedCouple.x - BUTTON_CIRCLE_RADIUS;
    double parentsButtonYMax = selectedCouple.y - MEMBER_CIRCLE_RADIUS;
    double parentsButtonYMin =
        selectedCouple.y - MEMBER_CIRCLE_RADIUS - (2 * BUTTON_CIRCLE_RADIUS);

    //conditions for parent button of first member
    if (currentX >= parentsButtonXMin &&
        currentX <= parentsButtonXMax &&
        currentY >= parentsButtonYMin &&
        currentY <= parentsButtonYMax) {
      performAddParents(
        selectedCouple,
        selectedCouple.member1.gender, //member1 because this relation is single
      );
      selectedCouple.member1.areParentsLoaded = true;
      return;
    }

    //load parents button constraints of first member
    parentsButtonXMax =
        selectedCouple.x - MEMBER_HORIZONTAL_GAP + BUTTON_CIRCLE_RADIUS;
    parentsButtonXMin =
        selectedCouple.x - MEMBER_HORIZONTAL_GAP - BUTTON_CIRCLE_RADIUS;
    parentsButtonYMax = selectedCouple.y - MEMBER_CIRCLE_RADIUS;
    parentsButtonYMin =
        selectedCouple.y - MEMBER_CIRCLE_RADIUS - (2 * BUTTON_CIRCLE_RADIUS);

    //conditions for parent button of male
    if (currentX >= parentsButtonXMin &&
        currentX <= parentsButtonXMax &&
        currentY >= parentsButtonYMin &&
        currentY <= parentsButtonYMax) {
      performAddParents(
        selectedCouple,
        'm',
      );
      selectedCouple.member1.gender == 'm'
          ? selectedCouple.member1.areParentsLoaded = true
          : selectedCouple.member2.areParentsLoaded = true;
    }

    //load parents button constraints of female
    parentsButtonXMax =
        selectedCouple.x + MEMBER_HORIZONTAL_GAP + BUTTON_CIRCLE_RADIUS;
    parentsButtonXMin =
        selectedCouple.x + MEMBER_HORIZONTAL_GAP - BUTTON_CIRCLE_RADIUS;
    parentsButtonYMax = selectedCouple.y - MEMBER_CIRCLE_RADIUS;
    parentsButtonYMin =
        selectedCouple.y - MEMBER_CIRCLE_RADIUS - (2 * BUTTON_CIRCLE_RADIUS);

    //conditions for parent button of second member
    if (currentX >= parentsButtonXMin &&
        currentX <= parentsButtonXMax &&
        currentY >= parentsButtonYMin &&
        currentY <= parentsButtonYMax) {
      performAddParents(
        selectedCouple,
        'f',
      );
      selectedCouple.member1.gender == 'f'
          ? selectedCouple.member1.areParentsLoaded = true
          : selectedCouple.member2.areParentsLoaded = true;
    }
  }

  void performAddChildren(
    CoupleModal selectedCouple,
  ) {
    if (selectedCouple.children.length == 0 || selectedCouple.areChildrenLoaded)
      return;

    moveExistingCouplesForChildren(
      childrenIds: selectedCouple.children,
      coupleCenterX: selectedCouple.x,
      coupleCenterY: selectedCouple.y,
    );

    addChildrenToList(
      childrenIds: selectedCouple.children,
      coupleCenterX: selectedCouple.x,
      coupleCenterY: selectedCouple.y,
    );

    selectedCouple.areChildrenLoaded = true;
  }

  void moveExistingCouplesForChildren({
    List childrenIds,
    double coupleCenterX,
    double coupleCenterY,
  }) {
    double startPosition;

    int length = childrenIds.length;

    if (childrenIds.length % 2 == 0)
      startPosition = coupleCenterX -
          (length / 2 * COUPLE_HORIZONTAL_GAP) +
          COUPLE_HORIZONTAL_GAP / 2;
    else
      startPosition = coupleCenterX - (length ~/ 2 * COUPLE_HORIZONTAL_GAP);

    double endPosition = startPosition + ((length - 1) * COUPLE_HORIZONTAL_GAP);

    for (var i = 0; i < allCouples.length; i++) {
      CoupleModal couple = allCouples[i];
      if (couple.x < coupleCenterX)
        couple.x = couple.x + startPosition - coupleCenterX;

      if (couple.x > coupleCenterX)
        couple.x = couple.x + endPosition - coupleCenterX;
    }
  }

  void addChildrenToList({
    List childrenIds,
    double coupleCenterX,
    double coupleCenterY,
  }) {
    double startPosition;

    if (childrenIds.length % 2 == 0)
      startPosition = coupleCenterX -
          (childrenIds.length / 2 * COUPLE_HORIZONTAL_GAP) +
          COUPLE_HORIZONTAL_GAP / 2; //this last addition is required
    else
      startPosition = coupleCenterX -
          // (childrenIds.length ~/ 2 * WIDTH_OF_COUPLE) -
          (childrenIds.length ~/ 2 * COUPLE_HORIZONTAL_GAP);

    for (var i = 0; i < childrenIds.length; i++) {
      String childId = childrenIds[i];
      CoupleModal couple = findAndGetCouple(
        childId,
        startPosition + (i * COUPLE_HORIZONTAL_GAP),
        coupleCenterY + COUPLE_VERTICAL_GAP,
      );

      //to mark the children's parents are loaded..
      couple.member1.id == childId
          ? couple.member1.areParentsLoaded = true
          : couple.member2.areParentsLoaded = true;

      allCouples.add(couple);
    }
    setState(() {});
  }

  void performAddParents(
    CoupleModal selectedCouple,
    String whichMember,
  ) {
    String parentId;

    SingleMemberModal loadParentsOfThisMember =
        selectedCouple.member1.gender == whichMember
            ? selectedCouple.member1
            : selectedCouple.member2;

    if (loadParentsOfThisMember.parents.length == 0 ||
        loadParentsOfThisMember.areParentsLoaded) return;
    parentId = loadParentsOfThisMember.parents[0];

    CoupleModal parentCouple = moveExistingCouplesForParents(
      selectedCouple,
      parentId,
      whichMember,
    );

    addParentsToList(selectedCouple, parentId, whichMember, parentCouple);
  }

  CoupleModal moveExistingCouplesForParents(
    CoupleModal selectedCouple,
    String parentId,
    String gender,
  ) {
    double siblingEndPositionX;
    double siblingStartPositionX = selectedCouple.x;

    CoupleModal parentCouple = findAndGetCouple(
      parentId,
      null,
      null,
    );

    if (gender == 'f') {
      siblingEndPositionX = selectedCouple.x;

      siblingEndPositionX = siblingEndPositionX +
          ((COUPLE_HORIZONTAL_GAP) * (parentCouple.children.length - 1));
    }
    if (gender == 'm') {
      siblingEndPositionX = selectedCouple.x;

      siblingEndPositionX = siblingEndPositionX -
          ((COUPLE_HORIZONTAL_GAP) * (parentCouple.children.length - 1));
    }

    double xFactorMul =
        (parentCouple.children.length - 1) * COUPLE_HORIZONTAL_GAP;

    //move couples in x
    List allCouplesBelowY =
        allCouples.where((cup) => cup.y >= selectedCouple.y).toList();

    for (var i = 0; i < allCouplesBelowY.length; i++) {
      CoupleModal couple = allCouplesBelowY[i];

      //dont move selected couple's children:
      bool flag = false;
      selectedCouple.children.forEach((childId) {
        if (childId == couple.member1.id || childId == couple.member2?.id)
          flag = true;
      });
      if (flag) continue;

      //same y
      if (couple.x > siblingStartPositionX && gender == 'f') {
        //members on right
        // couple.x = siblingEndPositionX - siblingStartPositionX + couple.x;
        couple.x = couple.x + xFactorMul;
      }
      if (couple.x < siblingStartPositionX && gender == 'm') {
        //members on left
        // couple.x = couple.x - (siblingEndPositionX + siblingStartPositionX);
        couple.x = couple.x - xFactorMul;
      }
    }

    //abjust parent above selectedCouple
    allCouples.where((cup) => cup.y < selectedCouple.y).forEach((couple) {
      //move couple up
      couple.y -= COUPLE_VERTICAL_GAP;

      //adjust their position according to children

      if (couple.areChildrenLoaded) {
        double firstChildPosX = allCouples
            .firstWhere((cup) =>
                cup.member1.id == couple.children[0] ||
                cup.member2?.id == couple.children[0])
            .x;
        double lastChildPosX = allCouples
            .firstWhere((cup) =>
                cup.member1.id == couple.children[couple.children.length - 1] ||
                cup.member2?.id == couple.children[couple.children.length - 1])
            .x;

        //this condition is required as couple may have only one child
        if (firstChildPosX != lastChildPosX) {
          couple.x = (lastChildPosX + firstChildPosX) / 2;
        }
      }
    });

    return parentCouple;
  }

  void addParentsToList(
    CoupleModal selectedCouple,
    String parentId,
    String gender,
    CoupleModal parentCouple,
  ) {
    //add children of parentCouple except the existing one
    double sinblingPositionX;
    if (gender == 'f')
      sinblingPositionX = selectedCouple.x + COUPLE_HORIZONTAL_GAP;
    else
      sinblingPositionX = selectedCouple.x - COUPLE_HORIZONTAL_GAP;

    double parentX = selectedCouple.x;
    int count = 0;

    for (var i = 0; i < parentCouple.children.length; i++) {
      String childId = parentCouple.children[i];

      if (childId == selectedCouple.member1.id ||
          childId == selectedCouple.member2.id) continue;

      if (gender == 'f')
        sinblingPositionX = sinblingPositionX + (count * COUPLE_HORIZONTAL_GAP);
      else
        sinblingPositionX = sinblingPositionX - (count * COUPLE_HORIZONTAL_GAP);
      count++;

      CoupleModal childCouple = findAndGetCouple(
        childId,
        sinblingPositionX,
        selectedCouple.y,
      )..member1.areParentsLoaded = true;
      allCouples.add(childCouple);
    }

    if (gender == 'f')
      parentX = parentX + ((count / 2) * COUPLE_HORIZONTAL_GAP);
    else
      parentX = parentX - ((count / 2) * COUPLE_HORIZONTAL_GAP);

    parentCouple.x = parentX;
    parentCouple.y = selectedCouple.y - COUPLE_VERTICAL_GAP;
    parentCouple.areChildrenLoaded = true;
    allCouples.add(parentCouple);
    setState(() {});
  }
}

CoupleModal findAndGetCouple(
  String id,
  double x,
  double y,
) {
  var membersRawData = members.firstWhere((member) => member['id'] == id);
  List children = membersRawData['children'];
  SingleMemberModal mainMember = SingleMemberModal.fromJson(membersRawData);
  if (mainMember.spouse == null)
    return CoupleModal(
      member1: mainMember,
      member2: null,
      children: children,
      areChildrenLoaded: false,
      x: x,
      y: y,
    );

  var spouseRawData =
      members.firstWhere((member) => member['id'] == mainMember.spouse);
  SingleMemberModal spouse = SingleMemberModal.fromJson(spouseRawData);
  return CoupleModal(
    //TODO: thinkk about couple id
    member1: mainMember,
    member2: spouse,
    children: children,
    areChildrenLoaded: false,
    x: x,
    y: y,
  );
}
