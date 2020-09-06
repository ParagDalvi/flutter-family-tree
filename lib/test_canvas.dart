import 'package:flutter/material.dart';

class TestCanvas extends StatefulWidget {
  @override
  _TestCanvasState createState() => _TestCanvasState();
}

class _TestCanvasState extends State<TestCanvas> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  List circles = [
    {
      'name': 'fathe',
      'position': Offset(0, 0),
    },
    {
      'name': 'son',
      'position': Offset(0, 100),
    },
  ];

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
      // appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleScaleReset,
        child: Icon(Icons.gps_not_fixed),
      ),
      body: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onTapDown: (details) {
          Offset position = details.globalPosition;
          var x = MediaQuery.of(context).size.width;
          var y = MediaQuery.of(context).size.height;
          Size size = Size(x, y);
          final Offset center = size.center(Offset.zero) * _zoom + _offset;
          final double radius = size.width / 20.0 * _zoom;

          for (var circle in circles) {
            Offset off = Offset(
                  circle['position'].dx + center.dx,
                  circle['position'].dy + center.dy,
                ) *
                _zoom;

            print('at: $off and clicke at: $position');

            if (position.dx <= off.dx + radius &&
                position.dx >= off.dx - radius &&
                position.dy >= off.dy - radius &&
                position.dy <= off.dy + radius) {
              print('clicked on ${circle['name']}');
            }
          }
        },
        // onDoubleTap: _handleScaleReset,
        child: CustomPaint(
          painter: _GesturePainter(
            zoom: _zoom,
            offset: _offset,
            circles: circles,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}

class _GesturePainter extends CustomPainter {
  const _GesturePainter({
    @required this.zoom,
    @required this.offset,
    @required this.circles,
  });

  final double zoom;
  final Offset offset;
  final List circles;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero) * zoom + offset;
    // final double radius = size.width / 20.0 * zoom;
    final double radius = 20;

    canvas.scale(zoom);

    for (var circle in circles) {
      canvas.drawCircle(
        center + circle['position'],
        radius,
        Paint()..color = Colors.orange,
      );

      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: radius,
      );
      final textSpan = TextSpan(
        text: '${circle["name"]} ${center + circle["position"]}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      textPainter.paint(canvas, center + circle['position']);
    }
  }

  @override
  bool shouldRepaint(_GesturePainter oldPainter) {
    return oldPainter.zoom != zoom || oldPainter.offset != offset;
  }
}
