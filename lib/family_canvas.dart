import 'dart:ui';
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
      paint
        ..color = Colors.black
        ..style = PaintingStyle.stroke;

      //center position
      canvas.drawCircle(Offset(couple.x - panX, couple.y - panY), 1, paint);

      drawBoundary(
        centerX: couple.x - panX,
        centerY: couple.y - panY,
        canvas: canvas,
        paint: paint,
      );

      paint
        ..color = Colors.orange
        ..style = PaintingStyle.fill;

      //this will draw member circles for both couple and single
      //this will also draw line btw the couple
      drawMemberCircles(
        couple,
        canvas,
        paint,
      );

      paint
        ..color = Colors.red
        ..style = PaintingStyle.stroke;

      //this is the button that will load children
      drawLoadChildrenButton(
        couple: couple,
        paint: paint,
        canvas: canvas,
      );

      paint
        ..color = Colors.red
        ..style = PaintingStyle.stroke;
      //this is the button that will load parents
      drawLoadParentsButton(
        couple: couple,
        paint: paint,
        canvas: canvas,
      );

      paint
        ..color = Colors.black
        ..style = PaintingStyle.stroke;
      //lines for the children
      drawChildrenLines(
        couple: couple,
        canvas: canvas,
        paint: paint,
      );

      //text of couple
      drawTextOfCouple(
        couple: couple,
        paint: paint,
        canvas: canvas,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  drawBoundary({
    @required double centerX,
    @required double centerY,
    @required Canvas canvas,
    @required Paint paint,
  }) {
    Offset offset = Offset(
      centerX,
      centerY,
    );

    Rect rect = Rect.fromCenter(
      center: offset,
      width: WIDTH_OF_COUPLE,
      height: HEIGHT_OF_COUPLE,
    );

    canvas.drawRect(rect, paint);
  }

  drawCircle({
    @required double x,
    @required double y,
    @required double radius,
    @required Paint paint,
    @required Canvas canvas,
  }) {
    Offset center = Offset(x, y);
    canvas.drawCircle(center, radius, paint);
  }

  drawTextOfCouple({
    @required CoupleModal couple,
    @required Paint paint,
    @required Canvas canvas,
  }) {
    //single person
    if (couple.member1 == null || couple.member2 == null) {
      SingleMemberModal member =
          couple.member1 == null ? couple.member2 : couple.member1;
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
      tp.paint(
        canvas,
        Offset(
          couple.x - panX,
          couple.y + 25 - panY, //TODO: hard coded
        ),
      );
      return;
    }

    TextSpan span;
    TextPainter tp;
    //couple
    if (couple.member1.gender == 'm') {
      //members1 is male
      String text = couple.member1.name;
      span = TextSpan(
        style: TextStyle(
          color: Colors.black,
        ),
        text: text,
      );
      tp = TextPainter(
        text: span,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      //member1 text
      tp.paint(
        canvas,
        Offset(
          couple.x - MEMBER_HORIZONTAL_GAP - panX,
          couple.y + MEMBER_CIRCLE_RADIUS + 25 - panY, //TODO: hard coded
        ),
      );

      text = couple.member2.name;
      span = TextSpan(
        style: TextStyle(
          color: Colors.black,
        ),
        text: text,
      );
      tp = TextPainter(
        text: span,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      tp.paint(
        canvas,
        Offset(
          couple.x + MEMBER_HORIZONTAL_GAP - panX,
          couple.y + MEMBER_CIRCLE_RADIUS + 25 - panY, //TODO: hard coded
        ),
      );
    } else {
      //member2 is female
      String text = couple.member2.name;
      span = TextSpan(
        style: TextStyle(
          color: Colors.black,
        ),
        text: text,
      );
      tp = TextPainter(
        text: span,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      //member1 text
      tp.paint(
        canvas,
        Offset(
          couple.x - MEMBER_HORIZONTAL_GAP - panX,
          couple.y + MEMBER_CIRCLE_RADIUS + 25 - panY, //TODO: hard coded
        ),
      );

      text = couple.member1.name;
      span = TextSpan(
        style: TextStyle(
          color: Colors.black,
        ),
        text: text,
      );
      tp = TextPainter(
        text: span,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      tp.paint(
        canvas,
        Offset(
          couple.x + MEMBER_HORIZONTAL_GAP - panX,
          couple.y + MEMBER_CIRCLE_RADIUS + 20 - panY, //TODO: hard coded
        ),
      );
    }
  }

  drawLine({
    @required double startX,
    @required double startY,
    @required double endX,
    @required double endY,
    @required Paint paint,
    @required Canvas canvas,
  }) {
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

  drawChildrenLines({
    @required CoupleModal couple,
    @required Paint paint,
    @required Canvas canvas,
  }) {
    if (couple.children.length == 0 || !couple.areChildrenLoaded) return;

    //vertical half line
    drawLine(
      startX: couple.x,
      startY: couple.y,
      endX: couple.x,
      endY: couple.y + COUPLE_VERTICAL_GAP / 2,
      paint: paint,
      canvas: canvas,
    );

    double previous, current;
    for (var i = 0; i < couple.children.length; i++) {
      String childId = couple.children[i];
      CoupleModal child = allCouples.firstWhere(
        (cup) => cup.member1.id == childId || cup.member2?.id == childId,
      );
      SingleMemberModal member =
          child.member1.id == childId ? child.member1 : child.member2;

      double x = child.x; //same position for single

      //this condition means that couple is a couple.. lul
      if (child.member1 != null && child.member2 != null) {
        if (member.gender == 'm')
          x = x - MEMBER_HORIZONTAL_GAP;
        else
          x = x + MEMBER_HORIZONTAL_GAP;
      }

      //vertical line
      drawLine(
        startX: x,
        startY: child.y,
        endX: x,
        endY: couple.y + COUPLE_VERTICAL_GAP / 2,
        paint: paint,
        canvas: canvas,
      );

      //long horizontal line
      previous = x;
      if (i == 0) {
        current = x;
        continue;
      }
      drawLine(
        startX: previous,
        startY: couple.y + COUPLE_VERTICAL_GAP / 2,
        endX: current,
        endY: couple.y + COUPLE_VERTICAL_GAP / 2,
        paint: paint,
        canvas: canvas,
      );
      current = x;
    }
  }

  drawLoadChildrenButton({
    @required CoupleModal couple,
    @required Paint paint,
    @required Canvas canvas,
  }) {
    if (couple.children.length == 0 || couple.areChildrenLoaded) return;

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
      startX: couple.x,
      startY: couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS,
      endX: couple.x + 5, //TODO: hard code
      endY: couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS -
          3, //TODO: hard code
      paint: paint,
      canvas: canvas,
    );

    drawLine(
      startX: couple.x,
      startY: couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS,
      endX: couple.x - 5, //TODO: hard code
      endY: couple.y +
          MEMBER_CIRCLE_RADIUS +
          BUTTON_CIRCLE_RADIUS -
          3, //TODO: hard code
      paint: paint,
      canvas: canvas,
    );
  }

  void drawMemberCircles(CoupleModal couple, Canvas canvas, Paint paint) {
    if (couple.member1 == null || couple.member2 == null) {
      // this person is single
      drawCircle(
        x: couple.x - panX,
        y: couple.y - panY,
        radius: MEMBER_CIRCLE_RADIUS,
        canvas: canvas,
        paint: paint,
      );
      return;
    }

    //left side member (male)
    drawCircle(
      x: couple.x - MEMBER_HORIZONTAL_GAP - panX,
      y: couple.y - panY,
      radius: MEMBER_CIRCLE_RADIUS,
      paint: paint,
      canvas: canvas,
    );

    //right side member (male)
    drawCircle(
      x: couple.x + MEMBER_HORIZONTAL_GAP - panX,
      y: couple.y - panY,
      radius: MEMBER_CIRCLE_RADIUS,
      paint: paint,
      canvas: canvas,
    );

    //line between them
    drawLine(
      startX: couple.x - MEMBER_HORIZONTAL_GAP,
      endX: couple.x + MEMBER_HORIZONTAL_GAP,
      startY: couple.y,
      endY: couple.y,
      canvas: canvas,
      paint: paint,
    );
  }

  void drawLoadParentsButton({
    @required CoupleModal couple,
    @required Paint paint,
    @required Canvas canvas,
  }) {
    if (couple.member1 == null || couple.member2 == null) {
      SingleMemberModal member =
          couple.member1 == null ? couple.member2 : couple.member1;
      if (member.parents.length == 0 || member.areParentsLoaded) return;

      drawCircle(
        x: couple.x - panX,
        y: couple.y - MEMBER_CIRCLE_RADIUS - BUTTON_CIRCLE_RADIUS - panY,
        radius: BUTTON_CIRCLE_RADIUS,
        paint: paint,
        canvas: canvas,
      );
      return;
    }

    SingleMemberModal maleMember =
        couple.member1.gender == 'm' ? couple.member1 : couple.member2;
    SingleMemberModal femaleMember =
        couple.member1.gender == 'f' ? couple.member1 : couple.member2;

    //member 1 parents button (male)
    if (maleMember.parents.length != 0 && !maleMember.areParentsLoaded) {
      drawCircle(
        x: couple.x - MEMBER_HORIZONTAL_GAP - panX,
        y: couple.y - MEMBER_CIRCLE_RADIUS - BUTTON_CIRCLE_RADIUS - panY,
        radius: BUTTON_CIRCLE_RADIUS,
        paint: paint,
        canvas: canvas,
      );
    }

    //member 2 parents button (female)
    if (femaleMember.parents.length != 0 && !femaleMember.areParentsLoaded) {
      drawCircle(
        x: couple.x + MEMBER_HORIZONTAL_GAP - panX,
        y: couple.y - MEMBER_CIRCLE_RADIUS - BUTTON_CIRCLE_RADIUS - panY,
        radius: BUTTON_CIRCLE_RADIUS,
        paint: paint,
        canvas: canvas,
      );
    }
  }
}
