import 'package:family_tree_0/family_tree.dart';
import 'package:family_tree_0/modal/couple_modal.dart';
import 'package:family_tree_0/modal/single_member_modal.dart';
import 'package:family_tree_0/size_consts.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;
  List<CoupleModal> allCouples = [];

  @override
  void initState() {
    super.initState();
    allCouples.add(findAndGetCouple('3', -250.0, -100.0));
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
                  addChildrenToList: addChildrenToList,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void addChildrenToList(String childId, Offset offset) {
    allCouples.add(findAndGetCouple(childId, offset.dx, offset.dy));
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(right: 10 * zoom),
              child: _singleMember(
                couple.member1.gender == 'm' ? couple.member1 : couple.member2,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10 * zoom),
              child: _singleMember(
                couple.member2.gender == 'f' ? couple.member2 : couple.member1,
              ),
            ),
          ],
        ),
        _getChildrenButton(couple),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: (MEMBER_CIRCLE_RADIUS + 60) * zoom,
              width: (MEMBER_CIRCLE_RADIUS + 60) * zoom,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  ),
                ],
                color: couple.member1.gender == 'm'
                    ? Colors.lightBlue
                    : Colors.pinkAccent,
              ),
            ),
            Container(
              height: (MEMBER_CIRCLE_RADIUS + 50) * zoom,
              width: (MEMBER_CIRCLE_RADIUS + 50) * zoom,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent,
                border: Border.all(
                  color: Colors.black,
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    // "https://api.adorable.io/avatars/285/${couple.member1.name}.png",
                    // "https://avatars.dicebear.com/api/avataaars/${couple.member1.name}.svg",
                    "https://i.pravatar.cc/150?u=${couple.member1.name}",
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            couple.member1.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              shadows: [
                BoxShadow(
                  offset: Offset(
                    0,
                    1,
                  ),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        !couple.areChildrenLoaded && couple.children.length != 0
            ? FlatButton(
                child: Icon(Icons.arrow_downward),
                onPressed: () {
                  if (couple.areChildrenLoaded) return;

                  double startPosition;

                  if (couple.children.length % 2 == 0)
                    startPosition = couple.x -
                        (couple.children.length / 2 * COUPLE_HORIZONTAL_GAP) +
                        COUPLE_HORIZONTAL_GAP /
                            2; //this last addition is required
                  else
                    startPosition = couple.x -
                        (couple.children.length ~/ 2 * COUPLE_HORIZONTAL_GAP);

                  for (var i = 0; i < couple.children.length; i++) {
                    String childId = couple.children[i];

                    addChildrenToList(
                      childId,
                      Offset(
                        startPosition + (i * COUPLE_HORIZONTAL_GAP),
                        couple.y + COUPLE_VERTICAL_GAP + 40,
                      ),
                    );
                  }
                  couple.areChildrenLoaded = true;
                  // setState(() {});
                },
              )
            : SizedBox.shrink(),
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
      return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * zoom),
      child: Icon(
        Icons.arrow_upward,
        size: 25 * zoom,
      ),
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
    );
  }

  Widget _getChildrenButton(CoupleModal couple) {
    if (couple.areChildrenLoaded || couple.children.length == 0)
      return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 8 * zoom),
      child: Icon(
        Icons.arrow_downward,
        size: 25 * zoom,
      ),
    );
  }
}
