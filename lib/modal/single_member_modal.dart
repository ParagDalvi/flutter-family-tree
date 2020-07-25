import 'package:flutter/material.dart';

class SingleMemberModal {
  final String id;
  final String name;
  final String spouse;
  final List parents;
  bool areParentsLoaded;

  SingleMemberModal({
    @required this.id,
    @required this.name,
    @required this.spouse,
    @required this.parents,
    @required this.areParentsLoaded,
  });

  factory SingleMemberModal.fromJson(rawData) {
    return SingleMemberModal(
      id: rawData['id'],
      name: rawData['name'],
      spouse: rawData['spouse'],
      parents: rawData['parents'],
      areParentsLoaded: false,
    );
  }
}
