import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

void startDrawing({
  CoupleModal couple,
  Offset center,
  double zoom,
  double radius,
  Canvas canvas,
  Paint paint,
}) {
  SingleMemberModal member1 = couple.member1;
  SingleMemberModal member2 = couple.member2;

  //single
  if (member2 == null) {
    drawMember(
      member1,
      couple.x,
      couple.y,
      center,
      radius,
      canvas,
      paint,
    );
    return;
  }

  //couple
  if (member1.gender == 'm') {
    drawMember(
      member1,
      couple.x - MEMBER_HORIZONTAL_GAP * zoom,
      couple.y,
      center,
      radius,
      canvas,
      paint,
    );
    drawMember(
      member2,
      couple.x + MEMBER_HORIZONTAL_GAP * zoom,
      couple.y,
      center,
      radius,
      canvas,
      paint,
    );
  } else {
    drawMember(
      member1,
      couple.x + MEMBER_HORIZONTAL_GAP * zoom,
      couple.y,
      center,
      radius,
      canvas,
      paint,
    );
    drawMember(
      member2,
      couple.x - MEMBER_HORIZONTAL_GAP * zoom,
      couple.y,
      center,
      radius,
      canvas,
      paint,
    );
  }

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: radius,
  );
  final textSpan = TextSpan(
    text: '${center + Offset(couple.x, couple.y)}',
    style: textStyle,
  );
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(
    minWidth: 0,
    maxWidth: 2000,
  );

  textPainter.paint(canvas, center + Offset(couple.x, couple.y + 20));

  canvas.drawCircle(center + Offset(couple.x, couple.y), 1, paint);
}

void drawMember(
  SingleMemberModal member,
  double x,
  double y,
  Offset center,
  double radius,
  Canvas canvas,
  Paint paint,
) {
  Offset position = center + Offset(x, y);

  canvas.drawCircle(position, radius, paint);
}
