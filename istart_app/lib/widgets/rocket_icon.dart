import 'package:flutter/material.dart';

/// Custom outlined rocket icon painted with Canvas.
/// [filled] = true → accent color fill (voted state)
/// [filled] = false → outlined (unvoted state)
class RocketIcon extends StatelessWidget {
  const RocketIcon({
    super.key,
    required this.color,
    this.size = 18,
    this.filled = false,
  });

  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RocketPainter(color: color, filled: filled),
    );
  }
}

class _RocketPainter extends CustomPainter {
  _RocketPainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    // Rocket body (teardrop pointing up)
    final body = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.75, h * 0.05, w * 0.88, h * 0.28, w * 0.88, h * 0.50)
      ..lineTo(w * 0.88, h * 0.62)
      ..cubicTo(w * 0.88, h * 0.72, w * 0.78, h * 0.78, w * 0.5, h * 0.82)
      ..cubicTo(w * 0.22, h * 0.78, w * 0.12, h * 0.72, w * 0.12, h * 0.62)
      ..lineTo(w * 0.12, h * 0.50)
      ..cubicTo(w * 0.12, h * 0.28, w * 0.25, h * 0.05, w * 0.5, h * 0.05)
      ..close();
    canvas.drawPath(body, paint);

    // Left fin
    final leftFin = Path()
      ..moveTo(w * 0.12, h * 0.62)
      ..lineTo(w * 0.01, h * 0.82)
      ..lineTo(w * 0.22, h * 0.76)
      ..close();
    canvas.drawPath(leftFin, paint);

    // Right fin
    final rightFin = Path()
      ..moveTo(w * 0.88, h * 0.62)
      ..lineTo(w * 0.99, h * 0.82)
      ..lineTo(w * 0.78, h * 0.76)
      ..close();
    canvas.drawPath(rightFin, paint);

    // Window (always filled with a slightly lighter circle)
    final windowPaint = Paint()
      ..color = filled ? color.withOpacity(0.25) : color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.42), w * 0.13, windowPaint);

    if (!filled) {
      // Window ring outline
      final windowOutline = Paint()
        ..color = color
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(
          Offset(w * 0.5, h * 0.42), w * 0.13, windowOutline);
    }

    // Flame (only when voted / filled)
    if (filled) {
      final flamePaint = Paint()
        ..color = Colors.orange.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      final flame = Path()
        ..moveTo(w * 0.5, h * 0.84)
        ..cubicTo(
            w * 0.38, h * 0.90, w * 0.34, h * 1.0, w * 0.5, h * 0.98)
        ..cubicTo(
            w * 0.66, h * 1.0, w * 0.62, h * 0.90, w * 0.5, h * 0.84)
        ..close();
      canvas.drawPath(flame, flamePaint);
    }
  }

  @override
  bool shouldRepaint(_RocketPainter old) =>
      old.color != color || old.filled != filled;
}