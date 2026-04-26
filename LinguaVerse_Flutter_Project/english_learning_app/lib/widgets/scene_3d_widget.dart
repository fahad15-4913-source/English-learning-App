import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../theme/app_theme.dart';

class Scene3DWidget extends StatefulWidget {
  final String sceneType;
  final VoidCallback onComplete;

  const Scene3DWidget({
    super.key,
    required this.sceneType,
    required this.onComplete,
  });

  @override
  State<Scene3DWidget> createState() => _Scene3DWidgetState();
}

class _Scene3DWidgetState extends State<Scene3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  int _dialogStep = 0;
  double _rotationX = 0;
  double _rotationY = 0;
  Offset? _lastPanPosition;

  final List<Map<String, String>> _dialogLines = [];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _loadDialog();
  }

  void _loadDialog() {
    switch (widget.sceneType) {
      case 'RESTAURANT_SCENE':
        _dialogLines.addAll([
          {'speaker': 'Waiter', 'text': 'Good evening! Welcome to The Golden Fork. How many in your party?'},
          {'speaker': 'You', 'text': 'Good evening! A table for two, please.'},
          {'speaker': 'Waiter', 'text': 'Right this way. Here are your menus. Can I start you off with something to drink?'},
          {'speaker': 'You', 'text': 'Could I have a glass of water, please?'},
          {'speaker': 'Waiter', 'text': 'Of course. Are you ready to order, or would you like a few more minutes?'},
          {'speaker': 'You', 'text': 'I\'d like the grilled salmon with vegetables, please.'},
          {'speaker': 'Waiter', 'text': 'Excellent choice! I\'ll have that right out for you.'},
        ]);
        break;
      case 'AIRPORT_SCENE':
        _dialogLines.addAll([
          {'speaker': 'Agent', 'text': 'Good morning! May I see your passport and boarding pass?'},
          {'speaker': 'You', 'text': 'Good morning! Here you go.'},
          {'speaker': 'Agent', 'text': 'Are you checking any bags today?'},
          {'speaker': 'You', 'text': 'Yes, I have one suitcase to check.'},
          {'speaker': 'Agent', 'text': 'Please place it on the scale. Your gate is B12. Boarding begins at 2:15 PM.'},
          {'speaker': 'You', 'text': 'Thank you! Where is gate B12?'},
          {'speaker': 'Agent', 'text': 'Go through security, then turn right. It\'s at the end of the terminal. Have a great flight!'},
        ]);
        break;
      default:
        _dialogLines.addAll([
          {'speaker': 'Guide', 'text': 'Welcome to the 3D conversation practice!'},
          {'speaker': 'You', 'text': 'Hello! I\'m ready to practice.'},
          {'speaker': 'Guide', 'text': 'Great! Let\'s begin with some basic phrases.'},
          {'speaker': 'You', 'text': 'How do I get to the nearest subway station?'},
          {'speaker': 'Guide', 'text': 'Go straight for two blocks, then turn left. You\'ll see it on your right.'},
        ]);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 3D Scene
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _rotationY += details.delta.dx * 0.01;
              _rotationX += details.delta.dy * 0.01;
              _rotationX = _rotationX.clamp(-0.5, 0.5);
            });
          },
          child: Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: _getSceneGradient(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // 3D Environment
                  _build3DEnvironment(),

                  // Drag hint
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white60, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Drag to look around',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Scene label
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.view_in_ar,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _getSceneLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Conversation dialog
        Expanded(
          child: _buildConversation(),
        ),
      ],
    );
  }

  Widget _build3DEnvironment() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(double.infinity, 280),
          painter: _Scene3DPainter(
            sceneType: widget.sceneType,
            rotationX: _rotationX,
            rotationY: _rotationY + _rotationController.value * 0.1,
            bounceValue: _bounceController.value,
            floatValue: _floatController.value,
          ),
        );
      },
    );
  }

  LinearGradient _getSceneGradient() {
    switch (widget.sceneType) {
      case 'RESTAURANT_SCENE':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        );
      case 'AIRPORT_SCENE':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF3B4371)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF1E3C72)],
        );
    }
  }

  String _getSceneLabel() {
    switch (widget.sceneType) {
      case 'RESTAURANT_SCENE':
        return '3D Restaurant';
      case 'AIRPORT_SCENE':
        return '3D Airport';
      default:
        return '3D Scene';
    }
  }

  Widget _buildConversation() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: min(_dialogStep + 1, _dialogLines.length),
            itemBuilder: (context, index) {
              final line = _dialogLines[index];
              final isUser = line['speaker'] == 'You';
              return _buildChatBubble(
                speaker: line['speaker']!,
                text: line['text']!,
                isUser: isUser,
                isLatest: index == _dialogStep,
              );
            },
          ),
        ),

        // Next / Complete button
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_dialogStep < _dialogLines.length - 1) {
                  setState(() => _dialogStep++);
                } else {
                  widget.onComplete();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _dialogStep < _dialogLines.length - 1
                    ? AppTheme.primaryBlue
                    : AppTheme.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _dialogStep < _dialogLines.length - 1
                    ? 'Continue Conversation'
                    : 'Complete Scene',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble({
    required String speaker,
    required String text,
    required bool isUser,
    required bool isLatest,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withOpacity(0.2),
              ),
              child: const Center(
                child: Text('🤵', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primaryBlue
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speaker,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : null,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.2),
              ),
              child: const Center(
                child: Text('🧑‍🎓', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3D Scene Painter
// ─────────────────────────────────────────────
class _Scene3DPainter extends CustomPainter {
  final String sceneType;
  final double rotationX;
  final double rotationY;
  final double bounceValue;
  final double floatValue;

  _Scene3DPainter({
    required this.sceneType,
    required this.rotationX,
    required this.rotationY,
    required this.bounceValue,
    required this.floatValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (sceneType) {
      case 'RESTAURANT_SCENE':
        _paintRestaurant(canvas, size);
        break;
      case 'AIRPORT_SCENE':
        _paintAirport(canvas, size);
        break;
      default:
        _paintDefaultScene(canvas, size);
    }
  }

  void _paintRestaurant(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Floor (perspective grid)
    _drawPerspectiveFloor(canvas, size, const Color(0xFF2A1A0A));

    // Table (3D box)
    final tablePaint = Paint()..color = const Color(0xFF8B6914);
    final tableTop = Paint()..color = const Color(0xFFA07C28);
    final tableX = cx + rotationY * 30;
    final tableY = cy + 40;

    // Table legs
    canvas.drawRect(
      Rect.fromLTWH(tableX - 60, tableY, 8, 40),
      tablePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(tableX + 52, tableY, 8, 40),
      tablePaint,
    );

    // Table top
    final tablePath = Path()
      ..moveTo(tableX - 80, tableY - 5)
      ..lineTo(tableX + 80, tableY - 5)
      ..lineTo(tableX + 70, tableY + 5)
      ..lineTo(tableX - 70, tableY + 5)
      ..close();
    canvas.drawPath(tablePath, tableTop);

    // Plates
    final platePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tableX - 25, tableY - 10), width: 36, height: 18),
      platePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tableX + 25, tableY - 10), width: 36, height: 18),
      platePaint,
    );

    // Candle with glow
    final candlePaint = Paint()..color = const Color(0xFFFFE4B5);
    canvas.drawRect(
      Rect.fromLTWH(tableX - 3, tableY - 30, 6, 20),
      candlePaint,
    );

    // Flame (animated)
    final flamePaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final flameOffset = sin(bounceValue * pi) * 3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(tableX, tableY - 35 + flameOffset),
        width: 8,
        height: 12,
      ),
      flamePaint,
    );

    // Ambient glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFF8C00).withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(tableX, tableY - 35), 40, glowPaint);

    // Chairs
    _drawChair(canvas, tableX - 100, tableY + 10, false);
    _drawChair(canvas, tableX + 100, tableY + 10, true);

    // Wine glasses
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tableX - 40, tableY - 15), width: 12, height: 8),
      glassPaint,
    );
    canvas.drawLine(
      Offset(tableX - 40, tableY - 11),
      Offset(tableX - 40, tableY - 2),
      glassPaint,
    );

    // Floating characters
    _drawCharacter(canvas, tableX - 100, cy - 10 + floatValue * 5,
        '🤵', 'Waiter');
    _drawCharacter(canvas, tableX + 100, cy + 5, '🧑‍🎓', 'You');

    // Windows with city lights
    for (int i = 0; i < 3; i++) {
      final wx = 60.0 + i * (size.width - 120) / 2;
      final windowPaint = Paint()
        ..color = const Color(0xFF1A237E).withOpacity(0.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(wx, 20, 50, 70),
          const Radius.circular(4),
        ),
        windowPaint,
      );
      // Stars/lights
      final starPaint = Paint()..color = Colors.yellow.withOpacity(0.5);
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(wx + 10 + j * 15, 40 + j * 12),
          1.5,
          starPaint,
        );
      }
    }
  }

  void _paintAirport(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Floor
    _drawPerspectiveFloor(canvas, size, const Color(0xFF37474F));

    // Counter
    final counterPaint = Paint()..color = const Color(0xFF546E7A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 100, cy + 20, 200, 60),
        const Radius.circular(6),
      ),
      counterPaint,
    );

    // Counter top
    final counterTopPaint = Paint()..color = const Color(0xFF78909C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 105, cy + 15, 210, 12),
        const Radius.circular(3),
      ),
      counterTopPaint,
    );

    // Monitor
    final monitorPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 20, cy - 20, 40, 35),
        const Radius.circular(3),
      ),
      monitorPaint,
    );
    // Screen glow
    final screenPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 16, cy - 16, 32, 27),
        const Radius.circular(2),
      ),
      screenPaint,
    );

    // Gate sign
    final signPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 40, 25, 80, 30),
        const Radius.circular(4),
      ),
      signPaint,
    );

    // Departure board lines
    for (int i = 0; i < 3; i++) {
      final linePaint = Paint()
        ..color = Colors.green.withOpacity(0.4)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(cx - 30, 35 + i * 8.0),
        Offset(cx + 30, 35 + i * 8.0),
        linePaint,
      );
    }

    // Characters
    _drawCharacter(canvas, cx - 80, cy - 30 + floatValue * 3,
        '👩‍✈️', 'Agent');
    _drawCharacter(canvas, cx + 80, cy - 20, '🧑‍🎓', 'You');

    // Luggage
    final luggagePaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 60, cy + 40, 30, 25),
        const Radius.circular(4),
      ),
      luggagePaint,
    );

    // Plane through window
    final planePaint = Paint()..color = Colors.white.withOpacity(0.3);
    final planeX = size.width * 0.85 + sin(rotationY * 5) * 20;
    final planeY = 60.0 + floatValue * 10;
    final planePath = Path()
      ..moveTo(planeX, planeY)
      ..lineTo(planeX + 20, planeY + 5)
      ..lineTo(planeX, planeY + 10)
      ..lineTo(planeX + 5, planeY + 5)
      ..close();
    canvas.drawPath(planePath, planePaint);
  }

  void _paintDefaultScene(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawPerspectiveFloor(canvas, size, const Color(0xFF1A237E));

    // Buildings
    for (int i = 0; i < 5; i++) {
      final bx = 30.0 + i * (size.width - 60) / 4;
      final bHeight = 80.0 + (i % 3) * 40;
      final buildingPaint = Paint()
        ..color = Color.lerp(
              const Color(0xFF1A237E),
              const Color(0xFF283593),
              i / 4,
            ) ??
            const Color(0xFF1A237E);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, cy - bHeight / 2, 40, bHeight),
          const Radius.circular(3),
        ),
        buildingPaint,
      );

      // Windows
      final windowPaint = Paint()..color = Colors.amber.withOpacity(0.3);
      for (int r = 0; r < (bHeight / 15).floor(); r++) {
        for (int c = 0; c < 2; c++) {
          canvas.drawRect(
            Rect.fromLTWH(
              bx + 8 + c * 16,
              cy - bHeight / 2 + 8 + r * 15,
              8, 6,
            ),
            windowPaint,
          );
        }
      }
    }

    // Characters
    _drawCharacter(canvas, cx - 60, cy + 20 + floatValue * 3,
        '🧑‍🏫', 'Guide');
    _drawCharacter(canvas, cx + 60, cy + 30, '🧑‍🎓', 'You');
  }

  void _drawPerspectiveFloor(Canvas canvas, Size size, Color color) {
    final floorPaint = Paint()..color = color.withOpacity(0.4);
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Floor plane
    final floorPath = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    // Perspective grid lines
    for (int i = 0; i < 8; i++) {
      final y = size.height * 0.6 + i * (size.height * 0.4) / 7;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    // Vanishing point lines
    final vanishY = size.height * 0.3;
    for (int i = 0; i < 6; i++) {
      final x = i * size.width / 5;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(size.width / 2, vanishY),
        gridPaint,
      );
    }
  }

  void _drawChair(Canvas canvas, double x, double y, bool flipped) {
    final chairPaint = Paint()..color = const Color(0xFF5D4037);
    final dir = flipped ? -1.0 : 1.0;

    // Seat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 15, y, 30, 6),
        const Radius.circular(2),
      ),
      chairPaint,
    );
    // Back
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + dir * 10, y - 25, 5, 25),
        const Radius.circular(2),
      ),
      chairPaint,
    );
    // Legs
    canvas.drawRect(Rect.fromLTWH(x - 12, y + 6, 3, 20), chairPaint);
    canvas.drawRect(Rect.fromLTWH(x + 9, y + 6, 3, 20), chairPaint);
  }

  void _drawCharacter(
      Canvas canvas, double x, double y, String emoji, String label) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 30), width: 30, height: 10),
      shadowPaint,
    );

    // Character circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 20, bgPaint);

    // Label
    final labelSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(x - labelPainter.width / 2, y + 25),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
