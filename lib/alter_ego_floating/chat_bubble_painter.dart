import 'package:flutter/material.dart';

/// Bulle de conversation style iMessage avec pointe centrée
class ChatBubblePainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool pointDown; // true = pointe vers le bas, false = vers le haut

  ChatBubblePainter({
    this.backgroundColor = const Color(0xFF0B1020),
    this.borderColor = const Color(0xFFFFC300),
    this.borderWidth = 2.0,
    this.pointDown = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 18.0;
    const double tailWidth = 16.0;
    const double tailHeight = 10.0;

    final double bubbleTop = pointDown ? 0.0 : tailHeight;
    final double bubbleBottom =
        pointDown ? size.height - tailHeight : size.height;

    final RRect bubbleRect = RRect.fromLTRBR(
      0,
      bubbleTop,
      size.width,
      bubbleBottom,
      const Radius.circular(radius),
    );

    final Path bubblePath = Path()..addRRect(bubbleRect);

    final double centerX = size.width / 2;

    final Path tailPath = Path();
    if (pointDown) {
      // Pointe vers le bas (sous la bulle)
      tailPath.moveTo(centerX - tailWidth / 2, bubbleBottom);
      tailPath.lineTo(centerX, bubbleBottom + tailHeight);
      tailPath.lineTo(centerX + tailWidth / 2, bubbleBottom);
    } else {
      // Pointe vers le haut (au-dessus de la bulle)
      tailPath.moveTo(centerX - tailWidth / 2, bubbleTop);
      tailPath.lineTo(centerX, bubbleTop - tailHeight);
      tailPath.lineTo(centerX + tailWidth / 2, bubbleTop);
    }
    tailPath.close();

    final Paint fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // Remplissage
    canvas.drawPath(bubblePath, fillPaint);
    canvas.drawPath(tailPath, fillPaint);

    // Contour
    canvas.drawPath(bubblePath, strokePaint);
    canvas.drawPath(tailPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ChatBubblePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.pointDown != pointDown;
  }
}
