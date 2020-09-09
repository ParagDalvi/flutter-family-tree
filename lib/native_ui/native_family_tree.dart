import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_0/family_tree.dart';
import 'package:family_tree_0/main.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

import 'firestore_family_function.dart';

List<CoupleModal> allCouples = [];

class NavtiveFamilyTree extends StatefulWidget {
  @override
  _NavtiveFamilyTreeState createState() => _NavtiveFamilyTreeState();
}

class _NavtiveFamilyTreeState extends State<NavtiveFamilyTree> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    allCouples.add(await getCoupleFromFirestore('0', -250.0, -100.0));
    setState(() {});
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _zoom = _previousZoom * details.scale;
    setState(() {
      _zoom = _zoom.clamp(0.7, 1.7430);

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = details.focalPoint - normalizedOffset * _zoom;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Tree'),
      ),
      body: Builder(
        builder: (context) => GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          child: Container(
            color: Color(0xFFF0EFEF),
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: allCouples.map((couple) {
                return IndividualCoupleTransform(
                  couple: couple,
                  offset: _offset,
                  zoom: _zoom,
                  addChildrenToList: addCoupleToList,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void addCoupleToList(String childId, Offset offset) async {
    allCouples.add(await getCoupleFromFirestore(childId, offset.dx, offset.dy));
    setState(() {});
  }
}

class IndividualCoupleTransform extends StatelessWidget {
  const IndividualCoupleTransform({
    Key key,
    @required this.zoom,
    @required this.offset,
    @required this.couple,
    @required this.addChildrenToList,
  }) : super(key: key);

  final double zoom;
  final Offset offset;
  final CoupleModal couple;
  final Function addChildrenToList;

  @override
  Widget build(BuildContext context) {
    Size size = Size(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    final Offset center = size.center(Offset.zero) * zoom + offset;

    return Transform(
      transform: Matrix4.translationValues(
        (center.dx + couple.x) * zoom,
        (center.dy + couple.y) * zoom,
        0,
      ),
      child: IndividualCoupleUI(
        zoom: zoom,
        couple: couple,
        addChildrenToList: addChildrenToList,
      ),
    );
  }
}

class IndividualCoupleUI extends StatelessWidget {
  const IndividualCoupleUI({
    Key key,
    @required this.zoom,
    @required this.couple,
    @required this.addChildrenToList,
  }) : super(key: key);

  final double zoom;
  final CoupleModal couple;
  final Function addChildrenToList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        couple.member2 == null
            ? Container(
                margin: EdgeInsets.only(right: 10 * zoom),
                child: _singleMember(
                  couple.member1.gender == 'm'
                      ? couple.member1
                      : couple.member2,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 10 * zoom),
                      child: _singleMember(
                        couple.member1.gender == 'm'
                            ? couple.member1
                            : couple.member2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10 * zoom),
                      child: _singleMember(
                        couple.member2.gender == 'f'
                            ? couple.member2
                            : couple.member1,
                      ),
                    ),
                  ),
                ],
              ),
        SizedBox(
          height: 8 * zoom,
        ),
        _getChildrenButton(couple),
      ],
    );
  }

  Widget _singleMember(SingleMemberModal member) {
    return Column(
      children: [
        _getParentsButton(member),
        _getImageOfMember(member),
        _getNameOfMember(member),
      ],
    );
  }

  Widget _getParentsButton(SingleMemberModal member) {
    if (member.areParentsLoaded || member.parents.length == 0)
      return SizedBox(
        height: 25 * zoom,
      );
    return Icon(
      Icons.arrow_upward,
      size: 25 * zoom,
    );
  }

  Widget _getImageOfMember(SingleMemberModal member) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: member.gender == 'm' ? Colors.blue : Colors.pink,
          ),
          width: 4 * MEMBER_CIRCLE_RADIUS * zoom,
          height: 4 * MEMBER_CIRCLE_RADIUS * zoom,
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange,
            image: DecorationImage(
              image: NetworkImage(
                "https://i.pravatar.cc/150?u=${member.name}",
              ),
            ),
          ),
          width: 3 * MEMBER_CIRCLE_RADIUS * zoom,
          height: 3 * MEMBER_CIRCLE_RADIUS * zoom,
        ),
      ],
    );
  }

  Widget _getNameOfMember(SingleMemberModal member) {
    return Text(
      member.name.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20 * zoom,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _getChildrenButton(CoupleModal couple) {
    if (couple.areChildrenLoaded || couple.children.length == 0)
      return SizedBox.shrink();
    return Icon(
      Icons.arrow_downward,
      size: 25 * zoom,
    );
  }
}
