import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_pictonnary/widgets/paint_painter.dart';

class PaintingArea extends StatefulWidget {
  final Color initialColor;
  final bool canNotDraw;

  const PaintingArea({
    Key? key,
    this.initialColor = Colors.black,
    required this.canNotDraw,
  }) : super(key: key);

  @override
  _PaintingAreaState createState() => _PaintingAreaState();
}

class _PaintingAreaState extends State<PaintingArea> {
  List<Offset?> points = [];
  Map<String, List<Offset?>> allUserPoints = {};
  late Color selectedColor;
  double strokeWidth = 5.0;
  int paintKey = 0;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    listenForUpdates();
  }

  void listenForUpdates() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('rooms')
            .doc('commonRoom')
            .collection('drawings')
            .snapshots()
            .listen((snapshot) {
          Map<String, List<Offset?>> updatedPoints = {};
          for (var doc in snapshot.docs) {
            List<Offset?> userPoints = (doc.data()['points'] as List<dynamic>)
                .map((p) => Offset(p['x'].toDouble(), p['y'].toDouble()))
                .toList();
            updatedPoints[doc.id] = userPoints;
          }
          setState(() {
            allUserPoints = updatedPoints;
          });
        });
      }
    });
  }

  void savePoints() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && points.isNotEmpty) {
      final List<Map<String, dynamic>> pointsToSave = points
          .where((point) => point != null)
          .map((point) => {'x': point!.dx, 'y': point.dy})
          .toList();

      FirebaseFirestore.instance
          .collection('rooms')
          .doc('commonRoom')
          .collection('drawings')
          .add({
        'userId': user.uid,
        'points': pointsToSave,
        'createdAt': Timestamp.now(),
      });
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose your color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: !widget.canNotDraw
                ? (details) {
                    setState(() {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset point = box.globalToLocal(details.globalPosition);
                      points.add(point);
                    });
                  }
                : null,
            onPanEnd: (details) {
              if (!widget.canNotDraw) {
                setState(() {
                  points.add(null);
                });
                savePoints();
              }
            },
            child: CustomPaint(
              key: ValueKey(paintKey),
              painter: PaintPainter(
                  allUserPoints: allUserPoints,
                  color: selectedColor,
                  strokeWidth: strokeWidth),
              child: Container(height: MediaQuery.of(context).size.height),
            ),
          ),
          Positioned(
            top: 150,
            right: 10,
            child: FloatingActionButton(
              onPressed: () => _showColorPicker(context),
              tooltip: 'Change Color',
              child: Icon(Icons.color_lens),
            ),
          ),
        ],
      ),
    );
  }
}
