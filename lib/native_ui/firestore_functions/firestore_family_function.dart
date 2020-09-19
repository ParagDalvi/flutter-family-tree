import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

Future<CoupleModal> getCoupleFromFirestore({
  @required String id,
  @required double x,
  @required double y,
}) async {
  CoupleModal couple;
  DocumentSnapshot mainMemberRaw =
      await firestoreInstance.collection('alpha_test').doc(id).get();
  SingleMemberModal mainMember =
      SingleMemberModal.fromJson(mainMemberRaw.data());

  if (mainMember.spouse == '')
    couple = CoupleModal(
      areChildrenLoaded: false,
      children: mainMemberRaw.data()['children'],
      member1: mainMember,
      member2: null,
      x: x,
      y: y,
    );
  else {
    DocumentSnapshot spouseMemberRaw = await firestoreInstance
        .collection('alpha_test')
        .doc(mainMember.spouse)
        .get();
    SingleMemberModal spouseMember =
        SingleMemberModal.fromJson(spouseMemberRaw.data());
    couple = CoupleModal(
      areChildrenLoaded: false,
      children: mainMemberRaw.data()['children'],
      member1: mainMember,
      member2: spouseMember,
      x: x,
      y: y,
    );
  }
  return couple;
}
