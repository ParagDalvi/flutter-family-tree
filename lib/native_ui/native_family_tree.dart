import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/native_ui/firestore_functions/load_children.dart';
import 'package:family_tree_0/native_ui/firestore_functions/load_parents.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

import 'background_canvas.dart';
import 'firestore_functions/firestore_family_function.dart';

List<CoupleModal> allCouples = [];
AppBar appbar = AppBar(
  title: Text('Family Tree'),
);

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
    allCouples.add(await getCoupleFromFirestore(
      id: '0',
      x: 0,
      y: 0,
    ));
    setState(() {});
    print('added');
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
      _zoom = _zoom.clamp(0.1, 1.0);

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
      floatingActionButton: FloatingActionButton(onPressed: _handleScaleReset),
      // appBar: appbar,
      body: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        child: Stack(
          children: [
            CustomPaint(
              child: Container(),
              painter: BackgroundLinesCanvas(
                zoom: _zoom,
                offset: _offset,
                allCouples: allCouples,
              ),
            ),
            Stack(
              children: allCouples.map((couple) {
                return IndividualCoupleTransform(
                  couple: couple,
                  offset: _offset,
                  zoom: _zoom,
                  setParentState: setParentState,
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey,
                      offset: Offset(0, 1),
                      spreadRadius: 1,
                    ),
                  ],
                  color: Colors.orange,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Family Tree',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                width: double.infinity,
                height: 56 + MediaQuery.of(context).padding.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setParentState() {
    setState(() {});
  }
}

class IndividualCoupleTransform extends StatelessWidget {
  const IndividualCoupleTransform({
    Key key,
    @required this.zoom,
    @required this.offset,
    @required this.couple,
    @required this.setParentState,
  }) : super(key: key);

  final double zoom;
  final Offset offset;
  final CoupleModal couple;
  final Function setParentState;

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
        setParentState: setParentState,
        offset: offset,
      ),
    );
  }
}

class IndividualCoupleUI extends StatelessWidget {
  const IndividualCoupleUI({
    Key key,
    @required this.zoom,
    @required this.couple,
    @required this.setParentState,
    @required this.offset,
  }) : super(key: key);

  final double zoom;
  final CoupleModal couple;
  final Function setParentState;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        couple.member2 == null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: (MEMBER_CIRCLE_RADIUS + 50) * zoom,
                    child: _singleMember(
                      couple.member1,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: Colors.red),
                    // ),
                    width: (MEMBER_CIRCLE_RADIUS + 50) * zoom,
                    child: _singleMember(
                      couple.member1.gender == 'm'
                          ? couple.member1
                          : couple.member2,
                    ),
                  ),
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: Colors.red),
                    // ),
                    width: (MEMBER_CIRCLE_RADIUS + 50) * zoom,
                    child: _singleMember(
                      couple.member2.gender == 'f'
                          ? couple.member2
                          : couple.member1,
                    ),
                  ),
                ],
              ),
        SizedBox(
          height: 8 * zoom,
        ),
        _getChildrenButton(couple, zoom),
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
    return GestureDetector(
      onTap: () => loadParents(couple, member.gender),
      child: Icon(
        Icons.arrow_upward,
        size: 25 * zoom,
      ),
    );
  }

  Widget _getImageOfMember(SingleMemberModal member) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: member.gender == 'm' ? Colors.blue : Colors.pink,
          width: 4 * zoom,
        ),
        shape: BoxShape.circle,
        color: Colors.orange,
        image: DecorationImage(
          image: NetworkImage(
            "https://i.pravatar.cc/150?u=${member.name}",
          ),
        ),
      ),
      width: MEMBER_CIRCLE_RADIUS * zoom,
      height: MEMBER_CIRCLE_RADIUS * zoom,
    );
  }

  Widget _getNameOfMember(SingleMemberModal member) {
    return Text(
      member.name.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15 * zoom,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _getChildrenButton(CoupleModal couple, double zoom) {
    if (couple.areChildrenLoaded || couple.children.length == 0)
      return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: (MEMBER_CIRCLE_RADIUS + 40) * zoom),
      // padding: EdgeInsets.all(0),
      child: GestureDetector(
        onTap: () => loadChildren(couple),
        child: Icon(
          Icons.arrow_downward,
          size: 25 * zoom,
        ),
      ),
    );
  }

  void loadParents(CoupleModal couple, String gender) async {
    print('load parents clicked');
    await performLoadParents(selectedCouple: couple, gender: gender);
    setParentState();
    print('dome');
  }

  void loadChildren(CoupleModal cuple) async {
    print('load children clicked');
    await performLoadChildren(couple);
    setParentState();
    print('done');
  }
}
