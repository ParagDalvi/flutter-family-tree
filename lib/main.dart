import 'package:family_tree_0/family_tree.dart';

import 'data.dart';
import 'package:flutter/material.dart';

const MEMBER_RADIUS = 20.0;
const HORIZONTAL_GAP = 70.0;
const VERTICAL_GAP = 60.0;

class MemberRaw {
  double x, y;
  final String id, name, spouse;
  final List children;
  bool areChildrenLoaded;

  MemberRaw({
    @required this.id,
    @required this.x,
    @required this.y,
    @required this.name,
    @required this.children,
    @required this.spouse,
    @required this.areChildrenLoaded,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: MyHomePage(),
      home: FamilyTree(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double panX = 0;
  double panY = 0;

  double oldPointX = 0;
  double oldPointY = 0;

  List<MemberRaw> membersList = [];

  @override
  void initState() {
    super.initState();

    var top = members.where((element) => element['id'] == '1').toList()[0];
    membersList.add(
      MemberRaw(
        id: top['id'],
        name: top['name'],
        children: top['children'],
        spouse: top['spouse'],
        x: 200,
        y: 100,
        areChildrenLoaded: false,
      ),
    );
    //if spouse present add spouse
    if (top['spouse'] != null) {
      var spouse = members
          .where((element) => element['id'] == top['spouse'])
          .toList()[0];
      membersList.add(
        MemberRaw(
          id: spouse['id'],
          name: spouse['name'],
          children: spouse['children'],
          spouse: top['spouse'],
          x: 200 + HORIZONTAL_GAP,
          y: 100,
          areChildrenLoaded: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          panX += oldPointX - details.globalPosition.dx;
          panY += oldPointY - details.globalPosition.dy;
          setState(() {});
          oldPointX = details.globalPosition.dx;
          oldPointY = details.globalPosition.dy;
        },
        onPanDown: (details) {
          List<MemberRaw> temp = [];
          membersList.forEach((element) {
            if (details.globalPosition.dx + panX >= (element.x - 40) &&
                details.globalPosition.dx + panX <= (element.x + 40) &&
                details.globalPosition.dy + panY >= (element.y - 40) &&
                details.globalPosition.dy + panY <= (element.y + 40)) {
              temp.addAll(performMemberClick(element));
            }
          });

          membersList.addAll(temp);
          setState(() {});

          oldPointX = details.globalPosition.dx;
          oldPointY = details.globalPosition.dy;
        },
        child: CustomPaint(
          painter: ShapePainter(panX, panY, membersList),
          child: Container(),
        ),
      ),
    );
  }

  List<MemberRaw> performMemberClick(MemberRaw member) {
    print('top---- ${member.name} ${member.areChildrenLoaded}');
    if (member.children.length == 0 || member.areChildrenLoaded) return [];

    List<MemberRaw> temp = [];

    double startPositionX;

    if (member.children.length % 2 == 0)
      startPositionX = member.x -
          ((member.children.length) / 2 * HORIZONTAL_GAP) +
          HORIZONTAL_GAP / 2;
    else
      startPositionX =
          member.x - ((member.children.length) ~/ 2 * HORIZONTAL_GAP);

    double endPositionX =
        startPositionX + ((member.children.length - 1) * HORIZONTAL_GAP);

    //change x positions of all members
    for (var i = 0; i < membersList.length; i++) {
      MemberRaw mem = membersList[i];
      if (mem.x < member.x) mem.x = mem.x + startPositionX - member.x;
      if (mem.x > member.x) mem.x = mem.x + endPositionX - member.x;
      int index = membersList.indexOf(membersList[i]);
      membersList[index] = mem;
    }

    //actually adding children
    for (var i = 0; i < member.children.length; i++) {
      String childId = member.children[i];

      List child =
          members.where((element) => element['id'] == childId).toList();

      temp.add(
        MemberRaw(
          id: child[0]['id'],
          name: child[0]['name'],
          children: child[0]['children'],
          spouse: child[0]['spouse'],
          x: startPositionX + (i * HORIZONTAL_GAP),
          y: member.y + VERTICAL_GAP,
          areChildrenLoaded: false,
        ),
      );
      if (child[0]['spouse'] != null) {
        List spouse = members
            .where((element) => element['id'] == child[0]['spouse'])
            .toList();

        temp.add(
          MemberRaw(
            id: spouse[0]['id'],
            name: spouse[0]['name'],
            children: spouse[0]['children'],
            spouse: spouse[0]['spouse'],
            x: startPositionX + (i * HORIZONTAL_GAP) + HORIZONTAL_GAP,
            y: member.y + VERTICAL_GAP,
            areChildrenLoaded: false,
          ),
        );
      }
    }

    //changing areChildrenLoaded flag to true
    MemberRaw newMember = member;
    newMember.areChildrenLoaded = true;
    int index = membersList.indexOf(member);
    membersList[index] = newMember;

    //TODO: this is not efficient
    MemberRaw spouse =
        membersList.where((element) => element.id == member.spouse).toList()[0];
    MemberRaw spouseNewMember = spouse;
    spouseNewMember.areChildrenLoaded = true;
    index = membersList.indexOf(spouse);
    print(
        'bottom----- ${spouseNewMember.name} ${spouseNewMember.areChildrenLoaded}');
    membersList[index] = spouseNewMember;

    //return list and add it after completing the forEach which is above
    return temp;
  }
}

class ShapePainter extends CustomPainter {
  final panX, panY;
  final List<MemberRaw> memberList;

  ShapePainter(this.panX, this.panY, this.memberList);

  @override
  void paint(Canvas canvas, Size size) {
    memberList.forEach((element) {
      drawCircle(
        canvas,
        element,
        panX,
        panY,
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  drawCircle(Canvas canvas, MemberRaw member, panX, panY) {
    //TODO: return if position not on screen
    var paint = Paint();

    //lines
    if (member.areChildrenLoaded) {
      paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 4;

      //vertical first line
      // var p1 = Offset(
      //   member.x - panX,
      //   member.y + MEMBER_RADIUS - panY,
      // );
      // var p2 = Offset(
      //   member.x - panX,
      //   member.y + MEMBER_RADIUS + (VERTICAL_GAP / 8) - panY,
      // );
      // canvas.drawLine(p1, p2, paint);

      var p1 = Offset(member.x - panX, member.y - panY);
      for (var i = 0; i < member.children.length; i++) {
        String childId = member.children[i];
        MemberRaw child =
            memberList.where((element) => element.id == childId).toList()[0];
        var p2 = Offset(child.x - panX, child.y - panY);
        canvas.drawLine(p1, p2, paint);
      }
    }

    //circle
    paint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    double xp = member.x - panX;
    double yp = member.y - panY;
    Offset center = Offset(xp, yp);
    canvas.drawCircle(center, MEMBER_RADIUS, paint);

    //text
    TextSpan span = new TextSpan(
      style: new TextStyle(color: Colors.blue[800]),
      // text: '${member.x}, ${member.y}',
      text: '${member.name}',
    );
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(xp, yp + MEMBER_RADIUS));
  }
}
