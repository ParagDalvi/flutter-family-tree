import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/native_ui/load_children.dart';
import 'package:family_tree_0/native_ui/load_parents.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

import 'firestore_family_function.dart';

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
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
              painter: MyTempPainter(
                zoom: _zoom,
                offset: _offset,
                allCouples: allCouples,
                statusBarHeight: statusBarHeight,
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        couple.member2 == null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      child: _singleMember(
                        couple.member1,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 4 * zoom),
                      child: _singleMember(
                        couple.member1.gender == 'm'
                            ? couple.member1
                            : couple.member2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 4 * zoom),
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
        _getChildrenButton(couple, context),
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

  Widget _getChildrenButton(CoupleModal couple, BuildContext context) {
    if (couple.areChildrenLoaded || couple.children.length == 0)
      return SizedBox.shrink();
    return GestureDetector(
      onTap: () => loadChildren(couple),
      child: Icon(
        Icons.arrow_downward,
        size: 25 * zoom,
      ),
    );
  }

  void loadParents(CoupleModal couple, String gender) async {
    await performLoadParents(selectedCouple: couple, gender: gender);
    setParentState();
    print('dome');
  }

  void loadChildren(CoupleModal cuple) async {
    await performLoadChildren(couple);
    setParentState();
    print('done');
  }
}

class MyTempPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final List<CoupleModal> allCouples;
  final double statusBarHeight;

  MyTempPainter(
      {this.statusBarHeight, this.zoom, this.offset, this.allCouples});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero) * zoom + offset;

    for (var couple in allCouples) {
      canvas.drawCircle(
        Offset(
            ((center.dx + couple.x) * zoom) + ((size.width / 2)),
            // ((center.dy + couple.y) * zoom) +
            //     ((appbar.preferredSize.height)) -
            //     ((statusBarHeight)),
            (center.dy + couple.y) * zoom),
        5,
        Paint()..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
