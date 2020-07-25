import 'dart:ui';
import 'package:family_tree_0/data.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

class FamilyCanvas extends CustomPainter {
  final double panX, panY;
  final List<CoupleModal> allCouples;

  FamilyCanvas({
    @required this.panX,
    @required this.panY,
    @required this.allCouples,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var i = 0; i < allCouples.length; i++) {
      CoupleModal couple = allCouples[i];
      paint..color = Colors.black;
      canvas.drawCircle(Offset(couple.x - panX, couple.y - panY), 1, paint);

      if (couple.member2 == null) {
        drawBoundary(couple.x, couple.y, canvas, paint);

        drawCircle(
          couple.x,
          couple.y,
          MEMBER_CIRCLE_RADIUS,
          paint,
          canvas,
        );

        drawChildrenLines(
          couple,
          paint,
          canvas,
        );

        drawLoadChildrenButton(
          couple,
          paint,
          canvas,
        );

        drawText(
          couple.member1,
          couple.x - MEMBER_CIRCLE_RADIUS,
          couple.y + MEMBER_CIRCLE_RADIUS / 2 + 25, //TODO: hardcodeed 20
          paint,
          canvas,
        );
      } else {
        drawCouple(couple, paint, canvas);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  drawCouple(CoupleModal couple, Paint paint, Canvas canvas) {
    drawBoundary(couple.x, couple.y, canvas, paint);

    //member1
    drawCircle(
      couple.x - MEMBER_HORIZONTAL_GAP,
      couple.y,
      MEMBER_CIRCLE_RADIUS,
      paint,
      canvas,
    );
    //member2
    drawCircle(
      couple.x + MEMBER_HORIZONTAL_GAP,
      couple.y,
      MEMBER_CIRCLE_RADIUS,
      paint,
      canvas,
    );

    //button circles for parent
    if (couple.member2.parents != null && !couple.member2.areParentsLoaded) {
      paint
        ..color = Colors.red
        ..style = PaintingStyle.stroke;

      Offset center = Offset(couple.x + MEMBER_HORIZONTAL_GAP - panX,
          couple.y - MEMBER_CIRCLE_RADIUS - BUTTON_CIRCLE_RADIUS - panY);
      canvas.drawCircle(center, BUTTON_CIRCLE_RADIUS, paint);
    }

    //horizotal line btw couple
    drawLine(
      couple.x + MEMBER_HORIZONTAL_GAP - MEMBER_CIRCLE_RADIUS,
      couple.y,
      couple.x - MEMBER_HORIZONTAL_GAP + MEMBER_CIRCLE_RADIUS,
      couple.y,
      paint,
      canvas,
    );

    //lines for children
    drawChildrenLines(
      couple,
      paint,
      canvas,
    );

    //load children button
    drawLoadChildrenButton(couple, paint, canvas);

    drawText(
      couple.member1,
      couple.x - MEMBER_HORIZONTAL_GAP - MEMBER_CIRCLE_RADIUS,
      couple.y + MEMBER_CIRCLE_RADIUS / 2 + 25, //TODO: hardcodeed 20
      paint,
      canvas,
    );
    drawText(
      couple.member2,
      couple.x + MEMBER_HORIZONTAL_GAP - MEMBER_CIRCLE_RADIUS,
      couple.y + MEMBER_CIRCLE_RADIUS / 2 + 25, //TODO: hardcodeed 20
      paint,
      canvas,
    );
  }

  drawBoundary(double x, double y, Canvas canvas, Paint paint) {
    paint
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    Offset offset = Offset(
      x - panX,
      y - panY,
    );

    Rect rect = Rect.fromCenter(
      center: offset,
      width: WIDTH_OF_COUPLE,
      height: HEIGHT_OF_COUPLE,
    );

    canvas.drawRect(rect, paint);
  }

  drawCircle(double x, double y, double radius, Paint paint, Canvas canvas) {
    paint
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    Offset center = Offset(x - panX, y - panY);
    canvas.drawCircle(center, radius, paint);
  }

  drawText(SingleMemberModal member, double x, double y, Paint paint,
      Canvas canvas) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: Colors.black,
      ),
      // text: '${x + CIRCLE_RADIUS - panX}, ${y - panY - CIRCLE_RADIUS}',
      text: '${member.name}',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - panX, y - panY));
  }

  drawLine(double startX, double startY, double endX, double endY, Paint paint,
      Canvas canvas) {
    Offset start = Offset(
      startX - panX,
      startY - panY,
    );
    Offset end = Offset(
      endX - panX,
      endY - panY,
    );
    canvas.drawLine(start, end, paint);
  }

  drawChildrenLines(CoupleModal couple, Paint paint, Canvas canvas) {
    if (!couple.areChildrenLoaded) return;

    //vertical half line
    drawLine(
      couple.x,
      couple.y,
      couple.x,
      couple.y + COUPLE_VERTICAL_GAP / 2,
      paint,
      canvas,
    );

    double startPosition, endPosition;

    //TODO: not correct

    //line for all child
    for (var i = 0; i < couple.children.length; i++) {
      String childId = couple.children[i];
      CoupleModal childCouple =
          allCouples.where((cup) => cup.coupleId == childId).toList()[0];

      if (i == couple.children.length - 1) endPosition = childCouple.x;
      if (i == 0) startPosition = childCouple.x;

      double endX;

      if (childCouple.member1 == null || childCouple.member2 == null) {
        endX = childCouple.x;
      } else {
        endX = childCouple.x - MEMBER_HORIZONTAL_GAP;
      }

      drawLine(
        endX,
        couple.y + COUPLE_VERTICAL_GAP / 2,
        endX,
        childCouple.y,
        paint,
        canvas,
      );
    }

    //horizontal long line
    drawLine(
      startPosition,
      couple.y + COUPLE_VERTICAL_GAP / 2,
      endPosition,
      couple.y + COUPLE_VERTICAL_GAP / 2,
      paint,
      canvas,
    );
  }

  drawLoadChildrenButton(CoupleModal couple, Paint paint, Canvas canvas) {
    if (couple.children.length == 0 || couple.areChildrenLoaded) return;
    paint
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(
        couple.x - panX,
        couple.y + MEMBER_CIRCLE_RADIUS + BUTTON_CIRCLE_RADIUS - panY,
      ),
      BUTTON_CIRCLE_RADIUS,
      paint,
    );

    paint
      ..color = Colors.black
      ..strokeWidth = 1.2;

    //draw arrow

    drawLine(
      couple.x,
      couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS,
      couple.x + 5, //TODO: hard code
      couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS -
          3, //TODO: hard code
      paint,
      canvas,
    );

    drawLine(
      couple.x,
      couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS,
      couple.x - 5, //TODO: hard code
      couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS -
          3, //TODO: hard code
      paint,
      canvas,
    );
  }
}
