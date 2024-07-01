// import 'package:flutter/material.dart';

// class BoundingBoxPainter extends CustomPainter {
//   final List<List<double>> boundingBoxes;
//   final double confidence;

//   BoundingBoxPainter({required this.boundingBoxes, required this.confidence});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (var box in boundingBoxes) {
//       final rect = Rect.fromLTRB(
//         box[0] * size.width / 900,
//         box[1] * size.height / 692,
//         box[2] * size.width / 900,
//         box[3] * size.height / 692,
//       );
//       canvas.drawRect(rect, paint);
//     }

//     final textPaint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;

//     const textStyle = TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: 'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
//         style: textStyle,
//       ),
//       textDirection: TextDirection.ltr,
//     );

//     for (var box in boundingBoxes) {
//       final rect = Rect.fromLTRB(
//         box[0] * size.width / 900,
//         box[1] * size.height / 692,
//         box[2] * size.width / 900,
//         box[3] * size.height / 692,
//       );
//       textPainter.layout();
//       textPainter.paint(
//         canvas,
//         Offset(rect.left, rect.top - 20), // Position the text above the box
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
