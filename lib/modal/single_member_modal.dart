import 'package:flutter/material.dart';

class SingleMemberModal {
  final String id;
  final String name;
  final String gender;
  final String spouse;
  final List parents;
  final String bio;
  final String imageUrl;
  bool areParentsLoaded;

  SingleMemberModal({
    @required this.id,
    @required this.name,
    @required this.gender,
    @required this.spouse,
    @required this.bio,
    @required this.imageUrl,
    @required this.parents,
    @required this.areParentsLoaded,
  });

  factory SingleMemberModal.fromJson(rawData) {
    return SingleMemberModal(
      id: rawData['id'],
      name: rawData['name'],
      gender: rawData['gender'],
      spouse: rawData['spouse'],
      imageUrl: rawData['imageUrl'],
      bio: rawData['bio'],
      parents: rawData['parents'],
      areParentsLoaded: false,
    );
  }
}
