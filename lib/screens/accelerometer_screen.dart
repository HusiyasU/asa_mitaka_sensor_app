import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

// Simulated accelerometer data (ganti dengan sensors_plus package di produksi)
class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({super.key});

  @override
  State<AccelerometerScreen> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen>
    with TickerProviderStateMixin {
  double x = 0, y = 0, z = 9.8;
  Timer? _timer;
  late AnimationController _warController;
  List<Offset> _trail = [];
  final int _maxTrail = 30;
  double _intensity = 0;

  // Simulasi sensor (untuk demo tanpa hardware)
  final math.Random _random = math.Random();
  double _simTime = 0;

  @override
  void initState() {
    super.initState();
    _warController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Simulate accelerometer data
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _simTime += 0.1;
      setState(() {
        // Simulated movement with sine waves + noise
        x = math.sin(_simTime * 1.3) * 3 + (_random.nextDouble() - 0.5) * 0.5;
        y = math.cos(_simTime * 0.9) * 2 + (_random.nextDouble() - 0.5) * 0.5;
        z = 9.8 + math.sin(_simTime * 2) * 0.5 + (_random.nextDouble() - 0.5) * 0.3;

        _intensity = (x.abs() + y.abs()) / 10;
        _trail.add(Offset(x, y));
        if (_trail.length > _maxTrail) _trail.removeAt(0);
      });
    });

    // --- UNTUK DEVICE NYATA, gunakan kode ini: ---
    // import 'package:sensors_plus/sensors_plus.dart';
    // accelerometerEventStream().listen((AccelerometerEvent event) {
    //   setState(() {
    //     x = event.x; y = event.y; z = event.z;
    //     _intensity = (x.abs() + y.abs()) / 10;
    //     _trail.add(Offset(x, y));
    //     if (_trail.length > _maxTrail) _trail.removeAt(0);
    //   });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _warController.dispose();
    super.dispose();
  }

  Color get _intensityColor {
    if (_intensity > 0.6) return const Color(0xFFD64045);
    if (_intensity > 0.3) return const Color(0xFFE8C547);
    return const Color(0xFF4ECDC4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _warController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: WarBgPainter(_warController.value, _intensity),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildVisualization(),
                        const SizedBox(height: 20),
                        _buildAxisCards(),
                        const SizedBox(height: 20),
                        _buildTrailGraph(),
                        const SizedBox(height: 20),
                        _buildWarQuote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                border: Border.all(color: const Color(0xFFE8C547).withOpacity(0.5)),
                color: const Color(0xFF0F0F0F),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFFE8C547), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCELEROMETER',
                style: GoogleFonts.bebasNeue(
                  color: const Color(0xFFE8C547),
                  fontSize: 20,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'War Sense — Deteksi Gerakan',
                style: GoogleFonts.rajdhani(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '⚔️',
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFE8C547).withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Grid
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: GridPainter(),
          ),
          // Bubble indicator
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rings
                for (int i = 3; i >= 1; i--)
                  Container(
                    width: i * 50.0,
                    height: i * 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8C547).withOpacity(0.1 * i),
                      ),
                    ),
                  ),
                // Moving dot
                Transform.translate(
                  offset: Offset(
                    (x * 15).clamp(-70, 70),
                    (y * -15).clamp(-70, 70),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 20 + _intensity * 20,
                    height: 20 + _intensity * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _intensityColor.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: _intensityColor,
                          blurRadius: 12 + _intensity * 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Label
          const Positioned(
            top: 10,
            left: 10,
            child: Text(
              'XY PLANE',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisCards() {
    return Row(
      children: [
        _axisCard('X', x, const Color(0xFFD64045)),
        const SizedBox(width: 8),
        _axisCard('Y', y, const Color(0xFFE8C547)),
        const SizedBox(width: 8),
        _axisCard('Z', z, const Color(0xFF4ECDC4)),
      ],
    );
  }

  Widget _axisCard(String axis, double value, Color color) {
    final normalized = (value.abs() / 10).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              'AXIS $axis',
              style: GoogleFonts.bebasNeue(
                color: color,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'm/s²',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF555555),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 3,
                  width: normalized * 80,
                  color: color,
                ),
              ),
            ),
            Container(height: 3, color: color.withOpacity(0.15)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailGraph() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFE8C547).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOVEMENT TRAIL',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: TrailPainter(_trail),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarQuote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFD64045).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'WAR DEVIL PROTOKOL',
            style: TextStyle(
              color: Color(0xFFD64045),
              fontSize: 10,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _intensity > 0.5
                ? '"Gerakan terdeteksi — Asa siaga penuh!"'
                : '"Tetap waspada... Musuh bisa datang kapan saja."',
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

class WarBgPainter extends CustomPainter {
  final double progress;
  final double intensity;
  WarBgPainter(this.progress, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity > 0.3) {
      final paint = Paint()
        ..color = const Color(0xFFD64045).withOpacity(intensity * 0.05)
        ..strokeWidth = 1;
      for (int i = 0; i < 5; i++) {
        canvas.drawLine(
          Offset(0, size.height * i / 5 + progress * 20),
          Offset(size.width, size.height * i / 5 + progress * 20),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WarBgPainter old) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8C547).withOpacity(0.06)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(Offset(size.width * i / 10, 0),
          Offset(size.width * i / 10, size.height), paint);
      canvas.drawLine(Offset(0, size.height * i / 10),
          Offset(size.width, size.height * i / 10), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class TrailPainter extends CustomPainter {
  final List<Offset> trail;
  TrailPainter(this.trail);

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < trail.length; i++) {
      final t = i / trail.length;
      paint.color = const Color(0xFFE8C547).withOpacity(t * 0.8);
      final x1 = (trail[i - 1].dx + 5) / 10 * size.width;
      final x2 = (trail[i].dx + 5) / 10 * size.width;
      final y1 = size.height / 2 - trail[i - 1].dy * 8;
      final y2 = size.height / 2 - trail[i].dy * 8;
      canvas.drawLine(
        Offset(x1.clamp(0, size.width), y1.clamp(0, size.height)),
        Offset(x2.clamp(0, size.width), y2.clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TrailPainter old) => true;
}
