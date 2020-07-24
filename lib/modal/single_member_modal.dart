import 'package:flutter/material.dart';

class SingleMemberModal {
  final String id;
  final String name;
  final String spouse;
  final String parent;

  SingleMemberModal({
    @required this.id,
    @required this.name,
    @required this.spouse,
    @required this.parent,
  });

  factory SingleMemberModal.fromJson(rawData) {
    return SingleMemberModal(
      id: rawData['id'],
      name: rawData['name'],
      spouse: rawData['spouse'],
      parent: rawData['parent'],
    );
  }
}
