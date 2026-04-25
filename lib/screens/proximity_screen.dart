import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class ProximityScreen extends StatefulWidget {
  const ProximityScreen({super.key});

  @override
  State<ProximityScreen> createState() => _ProximityScreenState();
}

class _ProximityScreenState extends State<ProximityScreen>
    with TickerProviderStateMixin {
  double _distance = 30.0; // cm
  bool _isNear = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final math.Random _random = math.Random();
  double _simTime = 0;
  final List<double> _history = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _simTime += 0.2;
      setState(() {
        // Simulate proximity: cycles between near and far
        _distance = 15 + 20 * (0.5 + 0.5 * math.sin(_simTime * 0.5)) +
            _random.nextDouble() * 3;
        _isNear = _distance < 15;

        _history.add(_distance);
        if (_history.length > 50) _history.removeAt(0);
      });
    });

    // --- UNTUK DEVICE NYATA: ---
    // import 'package:sensors_plus/sensors_plus.dart';
    // proximityEventStream().listen((ProximityEvent event) {
    //   setState(() {
    //     _distance = event.proximity;
    //     _isNear = event.proximity < 5;
    //     _history.add(_distance);
    //     if (_history.length > 50) _history.removeAt(0);
    //   });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (_distance < 10) return const Color(0xFFD64045);
    if (_distance < 20) return const Color(0xFFE8C547);
    return const Color(0xFF4ECDC4);
  }

  String get _statusText {
    if (_distance < 10) return 'BAHAYA — SANGAT DEKAT';
    if (_distance < 20) return 'WASPADA — MENDEKAT';
    return 'AMAN — JARAK JAUH';
  }

  String get _asaQuote {
    if (_distance < 10) {
      return '"Dia sudah terlalu dekat!\nYoru — ambil kendali sekarang!"';
    } else if (_distance < 20) {
      return '"Ada yang mendekat...\nTetap tenang, Asa."';
    } else {
      return '"Tidak ada ancaman di sekitar sini.\nNamun jangan lengah."';
    }
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
                    _buildRadarVisualization(),
                    const SizedBox(height: 20),
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildDistanceInfo(),
                    const SizedBox(height: 20),
                    _buildHistoryGraph(),
                    const SizedBox(height: 20),
                    _buildAsaResponse(),
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
                border:
                    Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.5)),
                color: const Color(0xFF0F0F0F),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF4ECDC4), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROXIMITY',
                style: GoogleFonts.bebasNeue(
                  color: const Color(0xFF4ECDC4),
                  fontSize: 20,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'Battlefield Radar — Deteksi Jarak',
                style: GoogleFonts.rajdhani(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text('👁️', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildRadarVisualization() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar sweep
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(double.infinity, 280),
                painter: RadarPainter(
                  _waveController.value,
                  _distance,
                  _statusColor,
                ),
              );
            },
          ),
          // Center indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = _isNear
                  ? 1.0 + _pulseController.value * 0.3
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor,
                        blurRadius: 20 + _pulseController.value * 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Distance label
          Positioned(
            bottom: 12,
            child: Text(
              '${_distance.toStringAsFixed(1)} cm',
              style: TextStyle(
                color: _statusColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          const Positioned(
            top: 10,
            left: 10,
            child: Text(
              'PROXIMITY RADAR',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.08),
        border: Border.all(color: _statusColor.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isNear
                      ? _statusColor
                          .withOpacity(0.5 + _pulseController.value * 0.5)
                      : _statusColor,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            _statusText,
            style: TextStyle(
              color: _statusColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo() {
    return Row(
      children: [
        _infoCard('JARAK', '${_distance.toStringAsFixed(1)} cm',
            const Color(0xFF4ECDC4)),
        const SizedBox(width: 10),
        _infoCard('STATUS', _isNear ? 'DEKAT' : 'JAUH',
            _isNear ? const Color(0xFFD64045) : const Color(0xFF4ECDC4)),
        const SizedBox(width: 10),
        _infoCard('MAX RANGE', '40.0 cm', const Color(0xFF666666)),
      ],
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryGraph() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISTANCE HISTORY',
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: ProximityHistoryPainter(_history),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsaResponse() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '● ',
                style: TextStyle(color: _statusColor, fontSize: 10),
              ),
              const Text(
                'ASA MITAKA RESPONDS',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _asaQuote,
            style: const TextStyle(
              color: Color(0xFFB0A890),
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double sweep;
  final double distance;
  final Color color;
  RadarPainter(this.sweep, this.distance, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 20;

    // Concentric rings
    for (int i = 1; i <= 4; i++) {
      final r = maxRadius * i / 4;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(0xFF4ECDC4).withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      // Range labels
      final rangeText = '${(10 * i).toStringAsFixed(0)}cm';
      final tp = TextPainter(
        text: TextSpan(
          text: rangeText,
          style: TextStyle(
            color: const Color(0xFF4ECDC4).withOpacity(0.3),
            fontSize: 7,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx + r - 20, center.dy + 2));
    }

    // Cross lines
    final crossPaint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.1)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius),
        Offset(center.dx, center.dy + maxRadius), crossPaint);
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy),
        Offset(center.dx + maxRadius, center.dy), crossPaint);

    // Sweep line
    final sweepAngle = sweep * 2 * math.pi;
    final sweepEnd = Offset(
      center.dx + maxRadius * math.cos(sweepAngle - math.pi / 2),
      center.dy + maxRadius * math.sin(sweepAngle - math.pi / 2),
    );
    canvas.drawLine(
      center,
      sweepEnd,
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2,
    );

    // Sweep trail
    final path = Path();
    path.moveTo(center.dx, center.dy);
    final trailRect = Rect.fromCircle(center: center, radius: maxRadius);
    path.arcTo(trailRect, sweepAngle - math.pi / 2 - 0.5,
        0.5, false);
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Object dot
    final objRadius = (distance / 40).clamp(0.0, 1.0) * maxRadius;
    canvas.drawCircle(
      Offset(center.dx + objRadius * math.cos(sweepAngle - math.pi / 2),
          center.dy + objRadius * math.sin(sweepAngle - math.pi / 2)),
      5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(RadarPainter old) => true;
}

class ProximityHistoryPainter extends CustomPainter {
  final List<double> history;
  ProximityHistoryPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final path = Path();
    const maxDist = 40.0;

    for (int i = 0; i < history.length; i++) {
      final x = size.width * i / (history.length - 1);
      final y = size.height * (1 - (history[i] / maxDist).clamp(0, 1));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.05)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ProximityHistoryPainter old) => true;
}
