// In-Class Activity 06 — Drawing with Flutter
// Student: Nour Khoulani
// Date: September 30, 2026

import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmileyApp());
}

enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8;
  FaceType faceType = FaceType.classic;

  // Tap cycles through the 3 faces
  void cycleFace() {
    setState(() {
      int next = (faceType.index + 1) % FaceType.values.length;
      faceType = FaceType.values[next];
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Face changed to ${faceType.name}')),
      );
  }

  // Long press randomizes mood
  void randomizeFace() {
    setState(() {
      mood = Random().nextDouble();
      faceType =
          FaceType.values[Random().nextInt(FaceType.values.length)];
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Face randomized!')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pink Smiley Painter'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: cycleFace,
                onLongPress: randomizeFace,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: SmileyPainter(
                    mood: mood,
                    faceType: faceType,
                  ),
                ),
              ),
            ),
          ),

          Text(
            'Face: ${faceType.name}',
            style: const TextStyle(fontSize: 18),
          ),

          Text(
            'Mood: ${mood.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),

          Slider(
            value: mood,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                mood = value;
              });
            },
          ),

          DropdownButton<FaceType>(
            value: faceType,
            items: FaceType.values.map((face) {
              return DropdownMenuItem(
                value: face,
                child: Text(face.name),
              );
            }).toList(),
            onChanged: (face) {
              if (face != null) {
                setState(() {
                  faceType = face;
                });
              }
            },
          ),

          const SizedBox(height: 10),

          const Text(
            'Tap face to change • Long press to randomize',
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  final double mood;
  final FaceType faceType;

  SmileyPainter({
    required this.mood,
    required this.faceType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.shortestSide * 0.4;

    // -------------------------
    // FACE COLOR
    // -------------------------

    Color faceColor;

    if (mood < 0.35) {
      faceColor = Colors.pink.shade100;
    } else if (mood <= 0.7) {
      faceColor = Colors.pink.shade200;
    } else {
      faceColor = Colors.pink.shade400;
    }

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // -------------------------
    // BORDER
    // -------------------------

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // -------------------------
    // EYES
    // -------------------------

    final eyePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final eyeY = center.dy - radius * 0.20;
    final eyeDistance = radius * 0.35;

    if (faceType == FaceType.sleepy) {
      // Closed sleepy eyes
      canvas.drawLine(
        Offset(center.dx - eyeDistance - 12, eyeY),
        Offset(center.dx - eyeDistance + 12, eyeY),
        eyePaint,
      );

      canvas.drawLine(
        Offset(center.dx + eyeDistance - 12, eyeY),
        Offset(center.dx + eyeDistance + 12, eyeY),
        eyePaint,
      );
    } else {
      // Normal eyes
      double eyeSize =
          faceType == FaceType.surprised ? 20 : 15;

      canvas.drawCircle(
        Offset(center.dx - eyeDistance, eyeY),
        eyeSize,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(center.dx + eyeDistance, eyeY),
        eyeSize,
        eyePaint,
      );
    }

    // -------------------------
    // MOUTH
    // -------------------------

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Surprised face = round mouth
    if (faceType == FaceType.surprised) {
      canvas.drawCircle(
        Offset(
          center.dx,
          center.dy + radius * 0.30,
        ),
        radius * 0.18,
        mouthPaint,
      );
      return;
    }

    final mouthRect = Rect.fromCenter(
      center: Offset(
        center.dx,
        center.dy + radius * 0.18,
      ),
      width: radius,
      height: radius * (0.4 + mood * 0.5),
    );

    // Sad
    if (mood < 0.35) {
      final frownRect =
          mouthRect.translate(0, radius * 0.25);

      canvas.drawArc(
        frownRect,
        1.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    }

    // Neutral / happy
    else {
      canvas.drawArc(
        mouthRect,
        0.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType;
  }
}