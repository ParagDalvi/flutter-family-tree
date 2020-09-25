import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberDetailsModal {
  final String gender, contact, whatsapp, email, address;
  final Timestamp bday, anniversery;
  final PersonalLinks personalLinks;

  MemberDetailsModal({
    @required this.personalLinks,
    @required this.gender,
    @required this.bday,
    @required this.anniversery,
    @required this.contact,
    @required this.whatsapp,
    @required this.email,
    @required this.address,
  });

  factory MemberDetailsModal.fronJson(
    Map<String, dynamic> snap,
    String gender,
  ) {
    return MemberDetailsModal(
      address: snap['address'],
      anniversery: snap['anniversery'],
      bday: snap['bday'],
      contact: snap['contact'],
      email: snap['email'],
      gender: gender,
      personalLinks: PersonalLinks(
        whatsapp: snap['whatsapp'],
        instagram: snap['instagram'],
        facebook: snap['facebook'],
        website: snap['website'],
        twitter: snap['twitter'],
        linkedin: snap['linkedin'],
      ),
      whatsapp: snap['whatsapp'],
    );
  }
}

class PersonalLinks {
  final String whatsapp, instagram, facebook, website, twitter, linkedin;

  PersonalLinks({
    @required this.whatsapp,
    @required this.instagram,
    @required this.facebook,
    @required this.website,
    @required this.twitter,
    @required this.linkedin,
  });
}
