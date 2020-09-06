import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SingleMemberModal {
  final String id;
  final String name;
  final String gender;
  final String spouse;
  final List parents;
  ui.Image image;
  final String imageUrl;
  bool areParentsLoaded;

  SingleMemberModal({
    @required this.id,
    @required this.name,
    @required this.gender,
    @required this.spouse,
    @required this.parents,
    @required this.areParentsLoaded,
    @required this.image,
    @required this.imageUrl,
  });

  factory SingleMemberModal.fromJson(rawData) {
    return SingleMemberModal(
      id: rawData['id'],
      name: rawData['name'],
      gender: rawData['gender'],
      spouse: rawData['spouse'],
      parents: rawData['parents'],
      areParentsLoaded: false,
      image: null,
      imageUrl: rawData['imageUrl'],
    );
  }
}
