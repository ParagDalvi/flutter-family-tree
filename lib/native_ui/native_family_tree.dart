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
    allCouples.add(await getCoupleFromFirestore(
      id: '0',
      x: 0,
      y: 0,
    ));
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
              ),
            ),
            Stack(
              children: allCouples.map((couple) {
                return IndividualCoupleTransform(
                  couple: couple,
                  offset: _offset,
                  zoom: _zoom,
                  addChildrenToList: addCoupleToList,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void addCoupleToList({String childId, double x, double y}) async {
    allCouples.add(await getCoupleFromFirestore(
      id: childId,
      x: x,
      y: y,
    )
      ..member1.areParentsLoaded = true);

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
        addCoupleToList: addChildrenToList,
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
    @required this.addCoupleToList,
    @required this.offset,
  }) : super(key: key);

  final double zoom;
  final CoupleModal couple;
  final Function addCoupleToList;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        couple.member2 == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      margin: EdgeInsets.only(right: 10 * zoom),
                      child: _singleMember(
                        couple.member1.gender == 'm'
                            ? couple.member1
                            : couple.member2,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 8 * zoom),
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
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 8 * zoom),
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
      onTap: () {
        print(
            (couple.x * zoom).toString() + ',' + (couple.y * zoom).toString());

        addCoupleToList(
          childId: couple.children[0],
          x: couple.x,
          y: couple.y + 150,
        );

        couple.areChildrenLoaded = true;
      },
      child: Icon(
        Icons.arrow_downward,
        size: 25 * zoom,
      ),
    );
  }
}

class MyTempPainter extends CustomPainter {
  final zoom;
  final offset;
  final allCouples;

  MyTempPainter({this.zoom, this.offset, this.allCouples});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero) * zoom + offset;

    for (var couple in allCouples) {
      canvas.drawCircle(
        Offset(
          ((center.dx + couple.x) * zoom),
          (center.dy + couple.y) * zoom,
        ),
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
