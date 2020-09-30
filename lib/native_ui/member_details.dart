import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/main.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/member_details_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/native_ui/firestore_functions/firestore_family_function.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    _tabController = TabController(
      vsync: this,
      length: 5,
      initialIndex: 1,
    );

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
                'SPOUSE',
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
                ParentsDetails(
                  parentsId: widget.member.parents,
                ),
                PersonalDetails(
                  member: widget.member,
                ),
                RelationDetails(
                  couple: widget.couple,
                  member: widget.member,
                ),
                ChidrenDetails(
                  couple: widget.couple,
                ),
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
    @required this.member,
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

        print(snapshot.data.data());
        String birthday = DateFormat.yMMMd().format(
          memberDetails.bday.toDate(),
        );

        String anniversary = DateFormat.yMMMd().format(
          memberDetails.anniversery.toDate(),
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
              'ANNIVERSARY',
              anniversary,
              context,
              FontAwesomeIcons.heart,
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
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.rss,
                    color: Colors.orange,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.website)) {
                      await launch(details.personalLinks.website);
                    }
                  })
              : SizedBox.shrink(),
          details.personalLinks.instagram != null ||
                  details.personalLinks.instagram != ''
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.pink,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.instagram)) {
                      await launch(details.personalLinks.instagram);
                    }
                  })
              : SizedBox.shrink(),
          details.personalLinks.facebook != null ||
                  details.personalLinks.facebook != ''
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.facebook)) {
                      await launch(details.personalLinks.facebook);
                    }
                  })
              : SizedBox.shrink(),
          details.personalLinks.whatsapp != null ||
                  details.personalLinks.whatsapp != ''
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.whatsapp)) {
                      await launch(details.personalLinks.whatsapp);
                    }
                  })
              : SizedBox.shrink(),
          details.personalLinks.linkedin != null ||
                  details.personalLinks.linkedin != ''
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.linkedinIn,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.linkedin)) {
                      await launch(details.personalLinks.linkedin);
                    }
                  })
              : SizedBox.shrink(),
          details.personalLinks.twitter != null ||
                  details.personalLinks.twitter != ''
              ? IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.twitter,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () async {
                    if (await canLaunch(details.personalLinks.twitter)) {
                      await launch(details.personalLinks.twitter);
                    }
                  },
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

class ParentsDetails extends StatefulWidget {
  final List parentsId;

  const ParentsDetails({
    @required this.parentsId,
  });

  @override
  _ParentsDetailsState createState() => _ParentsDetailsState();
}

class _ParentsDetailsState extends State<ParentsDetails>
    with AutomaticKeepAliveClientMixin {
  Future<CoupleModal> parentCouple;

  @override
  void initState() {
    if (widget.parentsId.length != 0) parentCouple = loadParents();
    super.initState();
  }

  Future<CoupleModal> loadParents() {
    Future<CoupleModal> couple =
        getCoupleFromFirestore(id: widget.parentsId[0], x: null, y: null);
    return couple;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.parentsId.length == 0)
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              color: darkBlueColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                ],
              ),
              onPressed: () {},
            ),
          ),
        ],
      );

    return FutureBuilder(
      future: parentCouple,
      builder: (BuildContext context, AsyncSnapshot<CoupleModal> coupleAsy) {
        if (!coupleAsy.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );

        CoupleModal couple = coupleAsy.data;

        SingleMemberModal father =
            couple.member1.gender == 'm' ? couple.member1 : couple.member2;
        SingleMemberModal mother =
            couple.member1.gender == 'f' ? couple.member1 : couple.member2;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  father != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              "https://i.pravatar.cc/150?u=${father.name}",
                            ),
                          ),
                          title: Text(
                            'FATHER',
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                          subtitle: Text(
                            father.name,
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      color: blackDarkColor,
                                    ),
                          ),
                        )
                      : SizedBox.shrink(),
                  mother != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              "https://i.pravatar.cc/150?u=${mother.name}",
                            ),
                          ),
                          title: Text(
                            'MOTHER',
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                          subtitle: Text(
                            mother.name,
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      color: blackDarkColor,
                                    ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            _getAddButton(father, mother),
          ],
        );
      },
    );
  }

  _getAddButton(SingleMemberModal father, SingleMemberModal mother) {
    if (father != null && mother != null) return SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      height: 80,
      child: RaisedButton(
        color: darkBlueColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              father == null ? 'ADD FATHER' : 'ADD MOTHER',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.add,
              color: Colors.white,
            )
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RelationDetails extends StatelessWidget {
  final CoupleModal couple;
  final SingleMemberModal member;

  const RelationDetails({
    @required this.couple,
    @required this.member,
  });

  @override
  Widget build(BuildContext context) {
    SingleMemberModal spouse =
        couple.member1 == member ? couple.member2 : couple.member1;

    if (couple.member2 == null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            children: [
              SizedBox(
                height: 130,
              ),
              Text(
                'Single',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              color: darkBlueColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ADD SPOUSE',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                ],
              ),
              onPressed: () {},
            ),
          )
        ],
      );

    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              "https://i.pravatar.cc/150?u=${spouse.name}",
            ),
          ),
          title: Text(
            spouse.gender == 'm' ? 'HUSBAND' : 'WIFE',
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: Colors.grey,
                ),
          ),
          subtitle: Text(
            spouse.name,
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: blackDarkColor,
                ),
          ),
        ),
      ],
    );
  }
}

class ChidrenDetails extends StatefulWidget {
  final CoupleModal couple;

  const ChidrenDetails({
    this.couple,
  });

  @override
  _ChidrenDetailsState createState() => _ChidrenDetailsState();
}

class _ChidrenDetailsState extends State<ChidrenDetails>
    with AutomaticKeepAliveClientMixin {
  List<ListTile> childrenList;

  Future future;

  @override
  void initState() {
    future = getChildren();
    super.initState();
  }

  getChildren() async {
    List local = [];
    for (var i = 0; i < widget.couple.children.length; i++) {
      String childId = widget.couple.children[i];

      CoupleModal childCouple =
          await getCoupleFromFirestore(id: childId, x: null, y: null);

      SingleMemberModal childMember = childCouple.member1.id == childId
          ? childCouple.member1
          : childCouple.member2;

      local.add(
        _getFieldListTile(childMember.name, childMember.name, context),
      );
    }

    return local;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.couple.children.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            children: [
              SizedBox(
                height: 130,
              ),
              Text(
                'No children',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              color: darkBlueColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ADD CHILD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                ],
              ),
              onPressed: () {},
            ),
          )
        ],
      );
    }

    return FutureBuilder(
      future: future,
      builder: (BuildContext context, snap) {
        print(snap);
        if (!snap.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => snap.data[index],
              itemCount: snap.data.length,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              height: 80,
              child: RaisedButton(
                color: darkBlueColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ADD CHILD',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getFieldListTile(
    String imageUrl,
    String value,
    BuildContext context,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          "https://i.pravatar.cc/150?u=${imageUrl}",
        ),
      ),
      title: Text(
        'CHILD',
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
