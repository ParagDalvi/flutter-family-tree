import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/native_ui/firestore_family_function.dart';
import 'package:flutter/material.dart';

import '../size_consts.dart';
import 'native_family_tree.dart';

Future performLoadParents({
  @required CoupleModal selectedCouple,
  @required String gender,
}) async {
  SingleMemberModal member = selectedCouple.member1.gender == gender
      ? selectedCouple.member1
      : selectedCouple.member2;

  if (member.areParentsLoaded || member.parents.length == 0) return null;

  String parentId = member.parents[0];

  CoupleModal parentCouple = await moveExistingCouples(
    selectedCouple: selectedCouple,
    gender: gender,
    parentId: parentId,
  );

  await addParentsToList(
    selectedCouple: selectedCouple,
    parentCouple: parentCouple,
    parentId: parentId,
    gender: gender,
  );

  selectedCouple.member1 == member
      ? selectedCouple.member1.areParentsLoaded = true
      : selectedCouple.member2.areParentsLoaded = true;
}

Future<CoupleModal> moveExistingCouples({
  @required CoupleModal selectedCouple,
  @required String parentId,
  @required String gender,
}) async {
  double siblingEndPositionX;
  double siblingStartPositionX = selectedCouple.x;

  CoupleModal parentCouple = await getCoupleFromFirestore(
    id: parentId,
    x: null,
    y: null,
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

  allCouples.where((cup) => cup.y < selectedCouple.y).forEach((couple) {
    //move couple up
    couple.y -= COUPLE_VERTICAL_GAP;

    //adjust their position according to children

    if (couple.areChildrenLoaded) {
      // double firstChildPosX = allCouples
      //     .firstWhere((cup) =>
      //         cup.member1.id == couple.children[0] ||
      //         cup.member2?.id == couple.children[0])
      //     .x;
      // double lastChildPosX = allCouples
      //     .firstWhere((cup) =>
      //         cup.member1.id == couple.children[couple.children.length - 1] ||
      //         cup.member2?.id == couple.children[couple.children.length - 1])
      //     .x;

      List<CoupleModal> listOfAllHisChildren = [];

      for (var i = 0; i < couple.children.length; i++) {
        String childId = couple.children[i];
        CoupleModal cup = allCouples.firstWhere(
            (cup) => cup.member1.id == childId || cup.member2?.id == childId);
        listOfAllHisChildren.add(cup);
      }

      listOfAllHisChildren.sort((a, b) => a.x.compareTo(b.x));

      double firstChildPosX = listOfAllHisChildren[0].x;
      double lastChildPosX = listOfAllHisChildren.last.x;

      //this condition is required as couple may have only one child
      if (firstChildPosX != lastChildPosX) {
        couple.x = (lastChildPosX + firstChildPosX) / 2;
      }
    }
  });

  return parentCouple;
}

Future addParentsToList({
  @required CoupleModal selectedCouple,
  @required String parentId,
  @required String gender,
  @required CoupleModal parentCouple,
}) async {
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
        childId == selectedCouple.member2?.id) continue;

    if (gender == 'f')
      sinblingPositionX = sinblingPositionX + (count * COUPLE_HORIZONTAL_GAP);
    else
      sinblingPositionX = sinblingPositionX - (count * COUPLE_HORIZONTAL_GAP);
    count++;

    CoupleModal childCouple = await getCoupleFromFirestore(
      id: childId,
      x: sinblingPositionX,
      y: selectedCouple.y,
    )
      ..member1.areParentsLoaded = true;
    allCouples.add(childCouple);
  }

  //if there is only 1 child
  if (parentCouple.children.length == 1) {
    if (gender == 'f')
      parentX = selectedCouple.x + COUPLE_HORIZONTAL_GAP / 2;
    else
      parentX = selectedCouple.x - COUPLE_HORIZONTAL_GAP / 2;
  }
  // parentX = selectedCouple.x;
  else if (gender == 'f')
    parentX = parentX + ((count / 2) * COUPLE_HORIZONTAL_GAP);
  else
    parentX = parentX - ((count / 2) * COUPLE_HORIZONTAL_GAP);

  parentCouple.x = parentX;
  parentCouple.y = selectedCouple.y - COUPLE_VERTICAL_GAP;
  parentCouple.areChildrenLoaded = true;
  allCouples.add(parentCouple);
}
