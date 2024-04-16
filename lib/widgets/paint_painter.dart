import 'package:flutter/material.dart';



class PaintPainter extends CustomPainter {
  final Map<String, List<Offset?>> allUserPoints;
  final Color color;
  final double strokeWidth;

  PaintPainter({required this.allUserPoints, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    allUserPoints.forEach((userId, points) {
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 0]!, paint);
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
