import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/main.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:flutter/material.dart';

class MemberDetails extends StatelessWidget {
  final SingleMemberModal member;

  const MemberDetails({
    @required this.member,
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

  const MainContent({
    @required this.member,
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
      length: 4,
      initialIndex: 1,
    );
    super.initState();
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
            unselectedLabelColor: Colors.black,
            isScrollable: true,
            tabs: [
              Text(
                'Parents',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Personal',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Children',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Media',
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

class PersonalDetails extends StatelessWidget {
  final SingleMemberModal member;

  const PersonalDetails({
    this.member,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreInstance
          .collection('alpha_test_details')
          .doc(member.id)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) return Text('loading');

        return Text(snapshot.data.data().toString());
      },
    );
  }
}
