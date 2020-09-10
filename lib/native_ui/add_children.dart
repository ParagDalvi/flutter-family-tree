import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/native_ui/native_family_tree.dart';
import 'package:flutter/material.dart';

import '../size_consts.dart';
import 'firestore_family_function.dart';

Future performAddChildren(CoupleModal selectedCouple) async {
  if (selectedCouple.children.length == 0 || selectedCouple.areChildrenLoaded)
    return null;

  moveExistingCouples(
    totalChildren: selectedCouple.children.length,
    centerX: selectedCouple.x,
    centerY: selectedCouple.y,
  );
  await addChildrenToList(
    childrenIds: selectedCouple.children,
    centerX: selectedCouple.x,
    centerY: selectedCouple.y,
  );

  selectedCouple.areChildrenLoaded = true;
}

void moveExistingCouples({
  @required int totalChildren,
  @required double centerX,
  @required double centerY,
}) {
  double startPosition;

  if (totalChildren % 2 == 0)
    startPosition = centerX -
        (totalChildren / 2 * COUPLE_HORIZONTAL_GAP) +
        COUPLE_HORIZONTAL_GAP / 2;
  else
    startPosition = centerX - (totalChildren ~/ 2 * COUPLE_HORIZONTAL_GAP);

  double endPosition =
      startPosition + ((totalChildren - 1) * COUPLE_HORIZONTAL_GAP);

  for (var i = 0; i < allCouples.length; i++) {
    CoupleModal couple = allCouples[i];

    if (couple.x < centerX) couple.x = couple.x + startPosition - centerX;

    if (couple.x > centerX) couple.x = couple.x + endPosition - centerX;
  }
}

Future addChildrenToList({
  @required List childrenIds,
  @required double centerX,
  @required double centerY,
}) async {
  double startPosition;

  if (childrenIds.length % 2 == 0)
    startPosition = centerX -
        (childrenIds.length / 2 * COUPLE_HORIZONTAL_GAP) +
        COUPLE_HORIZONTAL_GAP / 2; //this last addition is required
  else
    startPosition = centerX -
        // (childrenIds.length ~/ 2 * WIDTH_OF_COUPLE) -
        (childrenIds.length ~/ 2 * COUPLE_HORIZONTAL_GAP);

  for (var i = 0; i < childrenIds.length; i++) {
    String childId = childrenIds[i];

    CoupleModal couple = await getCoupleFromFirestore(
      id: childId,
      x: startPosition + (i * COUPLE_HORIZONTAL_GAP),
      y: centerY + COUPLE_VERTICAL_GAP,
    );

    //to mark the children's parents are loaded..
    couple.member1.id == childId
        ? couple.member1.areParentsLoaded = true
        : couple.member2.areParentsLoaded = true;

    allCouples.add(couple);
  }
}
