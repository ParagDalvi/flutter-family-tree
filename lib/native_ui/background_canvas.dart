import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/native_ui/native_family_tree.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../size_consts.dart';

class BackgroundLinesCanvas extends CustomPainter {
  final double zoom;
  final Offset offset;
  final List<CoupleModal> allCouples;

  BackgroundLinesCanvas({this.zoom, this.offset, this.allCouples});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Offset center = size.center(Offset.zero) * zoom + offset;

    for (var couple in allCouples) {
      Offset centerOfCouple = getCoupleCenter(couple, zoom, center);

      //this is just for reference
      canvas.drawCircle(
        Offset(
          centerOfCouple.dx,
          centerOfCouple.dy,
        ),
        3,
        paint..color = Colors.black,
      );

      drawHorizontalLineBetweenMembers(
        couple: couple,
        canvas: canvas,
        centerOfCouple: centerOfCouple,
        zoom: zoom,
        paint: paint,
      );

      // drawLinesToChildren(
      //   canvas: canvas,
      //   center: center,
      //   centerofParentCouple: centerOfCouple,
      //   paint: paint,
      //   parentCouple: couple,
      //   zoom: zoom,
      // );

      drawClassicLinesToChildren(
        canvas: canvas,
        center: center,
        centerofParentCouple: centerOfCouple,
        paint: paint,
        parentCouple: couple,
        zoom: zoom,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundLinesCanvas oldDelegate) {
    // TODO: (very important) implement shouldRepaint
    return true;
  }
}

Offset getCoupleCenter(
  CoupleModal couple,
  double zoom,
  Offset center,
) {
  double coupleX, coupleY;

  coupleY = ((center.dy + couple.y)) * zoom +
      ((25 + (MEMBER_CIRCLE_RADIUS / 2)) * zoom);

  if (couple.member2 == null)
    coupleX = ((center.dx + couple.x) * zoom) +
        ((MEMBER_CIRCLE_RADIUS + 50) / 2 * zoom);
  else
    coupleX =
        ((center.dx + couple.x) * zoom) + ((MEMBER_CIRCLE_RADIUS + 50) * zoom);

  return Offset(coupleX, coupleY);
}

void drawHorizontalLineBetweenMembers({
  @required CoupleModal couple,
  @required Offset centerOfCouple,
  @required double zoom,
  @required Canvas canvas,
  @required Paint paint,
}) {
  if (couple.member2 == null) return;

  double extraOffsetOnBothSides = ((MEMBER_CIRCLE_RADIUS + 50) / 2 * zoom);

  Offset startPos = Offset(
    centerOfCouple.dx - extraOffsetOnBothSides,
    centerOfCouple.dy,
  );

  Offset endPos = Offset(
    centerOfCouple.dx + extraOffsetOnBothSides,
    centerOfCouple.dy,
  );
  paint
    ..strokeWidth = 4
    ..shader = ui.Gradient.linear(
      startPos,
      endPos,
      [
        Colors.blue.withOpacity(0.4),
        Colors.red.withOpacity(0.4),
      ],
    );
  canvas.drawLine(startPos, endPos, paint);
}

void drawLinesToChildren({
  @required CoupleModal parentCouple,
  @required Offset centerofParentCouple,
  @required double zoom,
  @required Offset center,
  @required Canvas canvas,
  @required Paint paint,
}) {
  if (!parentCouple.areChildrenLoaded || parentCouple.children.length == 0)
    return;

  for (var i = 0; i < parentCouple.children.length; i++) {
    String childId = parentCouple.children[i];

    CoupleModal childCouple = allCouples.firstWhere(
      (cup) => cup.member1.id == childId || cup.member2?.id == childId,
    );

    Offset centerOfChildCouple = getCoupleCenter(childCouple, zoom, center);

    if (childCouple.member2 == null) {
      paint
        ..strokeWidth = 4
        ..shader = ui.Gradient.linear(
          centerofParentCouple,
          centerOfChildCouple,
          [
            Colors.pink.withOpacity(0.4),
            childCouple.member1.gender == 'm'
                ? Colors.blue.withOpacity(0.4)
                : Colors.red.withOpacity(0.4),
          ],
        );

      canvas.drawLine(
        centerofParentCouple,
        centerOfChildCouple,
        paint,
      );
    } else {
      double extraOffsetOnBothSides = ((MEMBER_CIRCLE_RADIUS + 50) / 2 * zoom);
      double childEndX;

      SingleMemberModal member = childCouple.member1.id == childId
          ? childCouple.member1
          : childCouple.member2;

      if (member.gender == 'm') {
        childEndX = centerOfChildCouple.dx - extraOffsetOnBothSides;
        paint
          ..strokeWidth = 4
          ..shader = ui.Gradient.linear(
            centerofParentCouple,
            Offset(childEndX, centerOfChildCouple.dy),
            [
              Colors.pink.withOpacity(0.4),
              Colors.blue.withOpacity(0.4),
            ],
          );
      } else {
        childEndX = centerOfChildCouple.dx + extraOffsetOnBothSides;
        paint
          ..strokeWidth = 4
          ..shader = ui.Gradient.linear(
            centerofParentCouple,
            Offset(childEndX, centerOfChildCouple.dy),
            [
              Colors.pink.withOpacity(0.4),
              Colors.red.withOpacity(0.4),
            ],
          );
      }

      canvas.drawLine(
        centerofParentCouple,
        Offset(childEndX, centerOfChildCouple.dy),
        paint,
      );
    }
  }
}

void drawClassicLinesToChildren({
  @required CoupleModal parentCouple,
  @required Offset centerofParentCouple,
  @required double zoom,
  @required Offset center,
  @required Canvas canvas,
  @required Paint paint,
}) {
  if (!parentCouple.areChildrenLoaded || parentCouple.children.length == 0)
    return;

  for (var i = 0; i < parentCouple.children.length; i++) {
    String childId = parentCouple.children[i];

    CoupleModal childCouple = allCouples.firstWhere(
      (cup) => cup.member1.id == childId || cup.member2?.id == childId,
    );

    Offset centerOfChildCouple = getCoupleCenter(childCouple, zoom, center);

    Path path = Path();

    path.moveTo(
      centerofParentCouple.dx,
      centerofParentCouple.dy,
    );

    //down line (vertical)
    path.lineTo(
      centerofParentCouple.dx,
      centerofParentCouple.dy + (COUPLE_VERTICAL_GAP / 2 * zoom),
    );

    if (childCouple.member2 == null) {
      paint
        ..strokeWidth = 4
        ..shader = ui.Gradient.linear(
          centerofParentCouple,
          centerOfChildCouple,
          [
            Colors.pink.withOpacity(0.4),
            childCouple.member1.gender == 'm'
                ? Colors.blue.withOpacity(0.4)
                : Colors.red.withOpacity(0.4),
          ],
        );

      //line to children (horizontal)
      path.lineTo(
        centerOfChildCouple.dx,
        centerofParentCouple.dy + (COUPLE_VERTICAL_GAP / 2 * zoom),
      );

      //final line to connect
      path.lineTo(
        centerOfChildCouple.dx,
        centerOfChildCouple.dy,
      );
    } else {
      double extraOffsetOnBothSides = ((MEMBER_CIRCLE_RADIUS + 50) / 2 * zoom);
      double childEndX;

      SingleMemberModal member = childCouple.member1.id == childId
          ? childCouple.member1
          : childCouple.member2;

      if (member.gender == 'm') {
        childEndX = centerOfChildCouple.dx - extraOffsetOnBothSides;
        paint
          ..strokeWidth = 4
          ..shader = ui.Gradient.linear(
            centerofParentCouple,
            Offset(childEndX, centerOfChildCouple.dy),
            [
              Colors.pink.withOpacity(0.4),
              Colors.blue.withOpacity(0.4),
            ],
          );
      } else {
        childEndX = centerOfChildCouple.dx + extraOffsetOnBothSides;
        paint
          ..strokeWidth = 4
          ..shader = ui.Gradient.linear(
            centerofParentCouple,
            Offset(childEndX, centerOfChildCouple.dy),
            [
              Colors.pink.withOpacity(0.4),
              Colors.red.withOpacity(0.4),
            ],
          );
      }

      //line to children (horizontal)
      path.lineTo(
        childEndX,
        centerofParentCouple.dy + (COUPLE_VERTICAL_GAP / 2 * zoom),
      );

      //final line to connect
      path.lineTo(
        childEndX,
        centerOfChildCouple.dy,
      );
    }

    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }
}
