import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:flutter/material.dart';

class CoupleModal {
  final String coupleId;
  final SingleMemberModal member1;
  final SingleMemberModal member2;
  final List children;
  double x, y;
  bool areChildrenLoaded;

  CoupleModal({
    @required this.coupleId,
    @required this.member1,
    @required this.member2,
    @required this.children,
    @required this.x,
    @required this.y,
    @required this.areChildrenLoaded,
  });
}
