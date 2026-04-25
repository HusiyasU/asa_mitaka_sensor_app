import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class GyroscopeScreen extends StatefulWidget {
  const GyroscopeScreen({super.key});

  @override
  State<GyroscopeScreen> createState() => _GyroscopeScreenState();
}

class _GyroscopeScreenState extends State<GyroscopeScreen>
    with TickerProviderStateMixin {
  double rx = 0, ry = 0, rz = 0;
  Timer? _timer;
  late AnimationController _spinController;
  final math.Random _random = math.Random();
  double _simTime = 0;

  // Rotation accumulator untuk visualisasi
  double _accX = 0, _accY = 0, _accZ = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _simTime += 0.08;
      setState(() {
        rx = math.sin(_simTime * 1.1) * 1.5 + (_random.nextDouble() - 0.5) * 0.3;
        ry = math.cos(_simTime * 0.7) * 1.2 + (_random.nextDouble() - 0.5) * 0.3;
        rz = math.sin(_simTime * 1.7) * 0.8 + (_random.nextDouble() - 0.5) * 0.2;

        _accX = (_accX + rx * 0.08) % (2 * math.pi);
        _accY = (_accY + ry * 0.08) % (2 * math.pi);
        _accZ = (_accZ + rz * 0.08) % (2 * math.pi);
      });
    });

    // --- UNTUK DEVICE NYATA: ---
    // import 'package:sensors_plus/sensors_plus.dart';
    // gyroscopeEventStream().listen((GyroscopeEvent event) {
    //   setState(() {
    //     rx = event.x; ry = event.y; rz = event.z;
    //     _accX = (_accX + rx * 0.016) % (2 * math.pi);
    //     _accY = (_accY + ry * 0.016) % (2 * math.pi);
    //     _accZ = (_accZ + rz * 0.016) % (2 * math.pi);
    //   });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _build3DVisualization(),
                    const SizedBox(height: 20),
                    _buildRotationDials(),
                    const SizedBox(height: 20),
                    _buildAngularVelocityBars(),
                    const SizedBox(height: 20),
                    _buildJudgmentQuote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD64045).withOpacity(0.5)),
                color: const Color(0xFF0F0F0F),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFFD64045), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GYROSCOPE',
                style: GoogleFonts.bebasNeue(
                  color: const Color(0xFFD64045),
                  fontSize: 20,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'War Spear — Rotasi & Orientasi',
                style: GoogleFonts.rajdhani(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text('🌀', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _build3DVisualization() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFD64045).withOpacity(0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grid
          CustomPaint(
            size: const Size(double.infinity, 260),
            painter: HexGridPainter(),
          ),
          // 3D Cube representation
          CustomPaint(
            size: const Size(200, 200),
            painter: Cube3DPainter(_accX, _accY, _accZ),
          ),
          // Labels
          const Positioned(
            top: 10,
            left: 10,
            child: Text(
              '3D ROTATION VIEW',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              'a=${(_accX * 180 / math.pi).toStringAsFixed(0)}° b=${(_accY * 180 / math.pi).toStringAsFixed(0)}° y=${(_accZ * 180 / math.pi).toStringAsFixed(0)}°',
              style: const TextStyle(
                color: Color(0xFFD64045),
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationDials() {
    return Row(
      children: [
        _buildDial('PITCH\nSumbu X', rx, const Color(0xFFD64045)),
        const SizedBox(width: 8),
        _buildDial('ROLL\nSumbu Y', ry, const Color(0xFFE8C547)),
        const SizedBox(width: 8),
        _buildDial('YAW\nSumbu Z', rz, const Color(0xFF4ECDC4)),
      ],
    );
  }

  Widget _buildDial(String label, double value, Color color) {
    final angle = value * math.pi / 3;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: DialPainter(angle, color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(3)}\nrad/s',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngularVelocityBars() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFD64045).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANGULAR VELOCITY',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 9,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          _velocityBar('X', rx, const Color(0xFFD64045)),
          const SizedBox(height: 8),
          _velocityBar('Y', ry, const Color(0xFFE8C547)),
          const SizedBox(height: 8),
          _velocityBar('Z', rz, const Color(0xFF4ECDC4)),
        ],
      ),
    );
  }

  Widget _velocityBar(String label, double value, Color color) {
    final normalized = (value.abs() / 2).clamp(0.0, 1.0);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: 8, color: color.withOpacity(0.1)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    height: 8,
                    width: normalized * constraints.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.5), color],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 55,
          child: Text(
            '${value.toStringAsFixed(3)}',
            style: TextStyle(color: color, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildJudgmentQuote() {
    final speed = (rx.abs() + ry.abs() + rz.abs());
    String quote;
    if (speed > 2.5) {
      quote = '"Perang sudah dimulai — rotasi di mana-mana!"';
    } else if (speed > 1.0) {
      quote = '"Yoru bergerak... waspada terhadap sekelilingmu."';
    } else {
      quote = '"Diam... tapi tetap siap menyerang kapan saja."';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFD64045).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'YORU — WAR DEVIL SPEAKS',
            style: TextStyle(
              color: Color(0xFFD64045),
              fontSize: 10,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: const TextStyle(
              color: Color(0xFFB0A890),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD64045).withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const r = 20.0;
    for (double y = 0; y < size.height + r; y += r * 1.5) {
      for (double x = 0; x < size.width + r; x += r * math.sqrt(3)) {
        _drawHex(canvas, Offset(x, y), r, paint);
        _drawHex(canvas, Offset(x + r * math.sqrt(3) / 2, y + r * 0.75), r, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class Cube3DPainter extends CustomPainter {
  final double ax, ay, az;
  Cube3DPainter(this.ax, this.ay, this.az);

  List<Offset> _project(List<List<double>> vertices) {
    return vertices.map((v) {
      // Rotate X
      final y1 = v[1] * math.cos(ax) - v[2] * math.sin(ax);
      final z1 = v[1] * math.sin(ax) + v[2] * math.cos(ax);
      // Rotate Y
      final x2 = v[0] * math.cos(ay) + z1 * math.sin(ay);
      final z2 = -v[0] * math.sin(ay) + z1 * math.cos(ay);
      // Rotate Z
      final x3 = x2 * math.cos(az) - y1 * math.sin(az);
      final y3 = x2 * math.sin(az) + y1 * math.cos(az);
      // Project
      final scale = 200 / (200 + z2);
      return Offset(x3 * scale * 40, y3 * scale * 40);
    }).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final verts = [
      [-1.0, -1.0, -1.0], [1.0, -1.0, -1.0], [1.0, 1.0, -1.0], [-1.0, 1.0, -1.0],
      [-1.0, -1.0, 1.0], [1.0, -1.0, 1.0], [1.0, 1.0, 1.0], [-1.0, 1.0, 1.0],
    ];

    final projected = _project(verts);

    final edges = [
      [0, 1], [1, 2], [2, 3], [3, 0],
      [4, 5], [5, 6], [6, 7], [7, 4],
      [0, 4], [1, 5], [2, 6], [3, 7],
    ];

    final edgePaint = Paint()
      ..color = const Color(0xFFD64045)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      canvas.drawLine(projected[edge[0]], projected[edge[1]], edgePaint);
    }

    // Vertices
    final dotPaint = Paint()..color = const Color(0xFFE8C547);
    for (final p in projected) {
      canvas.drawCircle(p, 3, dotPaint);
    }

    // Axis lines
    final axisProjected = _project([
      [2.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 2.0]
    ]);
    final origin = _project([[0.0, 0.0, 0.0]])[0];

    canvas.drawLine(origin, axisProjected[0],
        Paint()..color = const Color(0xFFD64045).withOpacity(0.6)..strokeWidth = 2);
    canvas.drawLine(origin, axisProjected[1],
        Paint()..color = const Color(0xFFE8C547).withOpacity(0.6)..strokeWidth = 2);
    canvas.drawLine(origin, axisProjected[2],
        Paint()..color = const Color(0xFF4ECDC4).withOpacity(0.6)..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(Cube3DPainter old) => true;
}

class DialPainter extends CustomPainter {
  final double angle;
  final Color color;
  DialPainter(this.angle, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc
    canvas.drawCircle(center, radius,
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.fill);

    canvas.drawCircle(center, radius,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Needle
    final needleEnd = Offset(
      center.dx + (radius - 5) * math.sin(angle),
      center.dy - (radius - 5) * math.cos(angle),
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(DialPainter old) => true;
}
