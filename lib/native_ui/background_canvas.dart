import 'package:family_tree_0/modal/couple_modal.dart';
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
    }
  }

  @override
  bool shouldRepaint(BackgroundLinesCanvas oldDelegate) {
    // TODO: (very important) implement shouldRepaint
    return true;
  }
}

Offset getCoupleCenter(CoupleModal couple, double zoom, Offset center) {
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
        Colors.blue,
        Colors.red,
      ],
    );
  canvas.drawLine(startPos, endPos, paint);
}
