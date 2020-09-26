import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/main.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/member_details_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MemberDetails extends StatelessWidget {
  final SingleMemberModal member;
  final CoupleModal couple;

  const MemberDetails({
    @required this.member,
    @required this.couple,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.width / 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: MainContent(
              member: member,
              couple: couple,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: member.id,
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width / 6,
                  ),
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    color: Color(0xff0ed0e2),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 8),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        "https://i.pravatar.cc/150?u=${member.name}",
                      ),
                    ),
                  ),
                  width: 100,
                  height: 110,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 35, left: 25),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Color(0xff0ed0e2).withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  // onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 35, right: 25),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  color: Color(0xff0ed0e2).withOpacity(0.3),
                ),
                padding: const EdgeInsets.all(15),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                // onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatefulWidget {
  final SingleMemberModal member;
  final CoupleModal couple;

  const MainContent({
    @required this.member,
    @required this.couple,
  });

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent>
    with TickerProviderStateMixin {
  TabController _tabController;

  SingleMemberModal spouse;

  @override
  void initState() {
    _tabController = TabController(
      vsync: this,
      length: 4,
      initialIndex: 1,
    );

    spouse = widget.couple.member1 == widget.member
        ? widget.couple.member2
        : widget.couple.member1;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Center(
            child: Text(
              widget.member.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          Center(
            child: Text(
              'Profession/Bio/Des',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          widget.couple?.member2 != null
              ? ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://i.pravatar.cc/150?u=${spouse.name}',
                    ),
                  ),
                  title: Text(spouse.name),
                  subtitle:
                      spouse.gender == 'm' ? Text('Husband') : Text('Wife'),
                  trailing: spouse.gender == 'm'
                      ? FaIcon(FontAwesomeIcons.male)
                      : FaIcon(FontAwesomeIcons.female),
                )
              : SizedBox.shrink(),
          TabBar(
            indicatorColor: lightBlueColor,
            controller: _tabController,
            labelColor: darkBlueColor,
            unselectedLabelColor: blackDarkColor,
            isScrollable: true,
            tabs: [
              Text(
                'PARENTS',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'PERSONAL',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'CHILDREN',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'MEDIA',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Icon(Icons.directions_car),
                PersonalDetails(member: widget.member),
                Icon(Icons.directions_transit),
                Icon(Icons.perm_media),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalDetails extends StatefulWidget {
  final SingleMemberModal member;

  const PersonalDetails({
    this.member,
  });

  @override
  _PersonalDetailsState createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails>
    with AutomaticKeepAliveClientMixin<PersonalDetails> {
  Future<DocumentSnapshot> personalDataDoc;

  @override
  void initState() {
    personalDataDoc = loadDoc();
    super.initState();
  }

  Future<DocumentSnapshot> loadDoc() async {
    DocumentSnapshot doc = await firestoreInstance
        .collection('alpha_test_details')
        .doc(widget.member.id)
        .get();

    return doc;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //need this line
    return FutureBuilder(
      future: personalDataDoc,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );

        MemberDetailsModal memberDetails = MemberDetailsModal.fronJson(
          snapshot.data.data(),
          widget.member.gender,
        );

        String birthday = DateFormat.yMMMd().format(
          memberDetails.bday.toDate(),
        );

        return ListView(
          children: [
            _getFieldListTile(
              'BIRTHDAY',
              birthday,
              context,
              FontAwesomeIcons.birthdayCake,
            ),
            _getFieldListTile(
              'EMAIL',
              memberDetails.email,
              context,
              FontAwesomeIcons.envelope,
            ),
            _getFieldListTile(
              'CONTACT NUMBER',
              memberDetails.contact,
              context,
              FontAwesomeIcons.phone,
            ),
            _getFieldListTile(
              'WHATSAPP NUMBER',
              memberDetails.whatsapp,
              context,
              FontAwesomeIcons.whatsapp,
            ),
            _getPersonalLinks(memberDetails),
          ],
        );
      },
    );
  }

  _getPersonalLinks(MemberDetailsModal details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          details.personalLinks.website != null ||
                  details.personalLinks.website != ''
              ? FaIcon(
                  FontAwesomeIcons.rss,
                  color: Colors.orange,
                )
              : SizedBox.shrink(),
          details.personalLinks.instagram != null ||
                  details.personalLinks.instagram != ''
              ? FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.pink,
                )
              : SizedBox.shrink(),
          details.personalLinks.facebook != null ||
                  details.personalLinks.facebook != ''
              ? FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.blue,
                )
              : SizedBox.shrink(),
          details.personalLinks.whatsapp != null ||
                  details.personalLinks.whatsapp != ''
              ? FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                )
              : SizedBox.shrink(),
          details.personalLinks.linkedin != null ||
                  details.personalLinks.linkedin != ''
              ? FaIcon(
                  FontAwesomeIcons.linkedinIn,
                  color: Colors.lightBlue,
                )
              : SizedBox.shrink(),
          details.personalLinks.twitter != null ||
                  details.personalLinks.twitter != ''
              ? FaIcon(
                  FontAwesomeIcons.twitter,
                  color: Colors.lightBlueAccent,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _getFieldListTile(
    String title,
    String value,
    BuildContext context,
    IconData icon,
  ) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.grey,
            ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: blackDarkColor,
            ),
      ),
      trailing: FaIcon(
        icon,
        color: darkBlueColor,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
