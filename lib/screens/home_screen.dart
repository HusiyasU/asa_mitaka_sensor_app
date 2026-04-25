import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'accelerometer_screen.dart';
import 'gyroscope_screen.dart';
import 'proximity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildHeroSection(),
                const SizedBox(height: 24),
                _buildSensorGrid(),
                const Spacer(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: BackgroundPainter(_rotateController.value),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8C547), width: 1),
              color: const Color(0xFFE8C547).withOpacity(0.1),
            ),
            child: Text(
              'CHAINSAW MAN',
              style: GoogleFonts.bebasNeue(
                color: const Color(0xFFE8C547),
                fontSize: 13,
                letterSpacing: 4,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD64045), width: 1),
              color: const Color(0xFFD64045).withOpacity(0.1),
            ),
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return Text(
                  '● LIVE',
                  style: GoogleFonts.bebasNeue(
                    color: _glitchController.value > 0.5
                        ? const Color(0xFFD64045)
                        : const Color(0xFFFF6B6B),
                    fontSize: 13,
                    letterSpacing: 3,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Photo with manga-style frame
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(scale: _pulseAnim.value, child: child);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Container(
                      width: 178,
                      height: 178,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD64045)
                                .withOpacity(0.15 + _pulseController.value * 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Decorative outer ring
                Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8C547).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner border
                Container(
                  width: 162,
                  height: 162,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD64045).withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
                // Photo
                ClipOval(
                  child: Image.asset(
                    'assets/asa_mitaka.jpg',
                    width: 155,
                    height: 155,
                    fit: BoxFit.cover,
                    // Filter: slight dark overlay untuk kesan gelap
                    color: const Color(0xFF0A0A0A).withOpacity(0.15),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                // Corner cross decorations
                ..._buildCornerDecorations(),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Name
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE8C547), Color(0xFFFFD700), Color(0xFFE8C547)],
            ).createShader(bounds),
            child: Text(
              'ASA MITAKA',
              style: GoogleFonts.bebasNeue(
                color: Colors.white,
                fontSize: 36,
                letterSpacing: 10,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '戦争の悪魔 — WAR DEVIL',
            style: GoogleFonts.bebasNeue(
              color: const Color(0xFFD64045),
              fontSize: 15,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border.all(
                color: const Color(0xFFE8C547).withOpacity(0.25),
              ),
            ),
            child: Text(
              '"I\'ll survive no matter what it takes."',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFB0A890),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    const size = 14.0;
    const offset = 12.0;
    const color = Color(0xFFE8C547);
    final positions = [
      {'top': offset, 'left': offset},
      {'top': offset, 'right': offset},
      {'bottom': offset, 'left': offset},
      {'bottom': offset, 'right': offset},
    ];

    return positions.map((pos) {
      return Positioned(
        top: pos['top'],
        left: pos['left'],
        right: pos['right'],
        bottom: pos['bottom'],
        child: CustomPaint(
          size: const Size(size, size),
          painter: CornerPainter(
            flipX: pos.containsKey('right'),
            flipY: pos.containsKey('bottom'),
            color: color,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSensorGrid() {
    final sensors = [
      {
        'title': 'ACCELEROMETER',
        'subtitle': 'Gerakan & Gravitasi',
        'icon': '⚔️',
        'color': const Color(0xFFE8C547),
        'desc': 'Sensor gerak & akselerasi',
        'screen': const AccelerometerScreen(),
      },
      {
        'title': 'GYROSCOPE',
        'subtitle': 'Rotasi & Orientasi',
        'icon': '🌀',
        'color': const Color(0xFFD64045),
        'desc': 'Sensor rotasi sumbu XYZ',
        'screen': const GyroscopeScreen(),
      },
      {
        'title': 'PROXIMITY',
        'subtitle': 'Deteksi Jarak',
        'icon': '👁️',
        'color': const Color(0xFF4ECDC4),
        'desc': 'Sensor kedekatan objek',
        'screen': const ProximityScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SENSOR MODULES',
              style: GoogleFonts.bebasNeue(
                color: const Color(0xFF666666),
                fontSize: 13,
                letterSpacing: 5,
              ),
            ),
          ),
          ...sensors.map((s) => _buildSensorTile(s)),
        ],
      ),
    );
  }

  Widget _buildSensorTile(Map<String, dynamic> sensor) {
    final color = sensor['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => sensor['screen'] as Widget,
          transitionsBuilder: (c, anim, a2, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );
          },
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(sensor['icon'] as String,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor['title'] as String,
                    style: GoogleFonts.bebasNeue(
                      color: color,
                      fontSize: 16,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    sensor['subtitle'] as String,
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFFEAE8E4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sensor['desc'] as String,
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF666666),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 40, height: 1, color: const Color(0xFF333333)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'SENSOR DEVIL SYSTEM v1.0',
              style: GoogleFonts.bebasNeue(
                color: const Color(0xFF444444),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
          ),
          Container(width: 40, height: 1, color: const Color(0xFF333333)),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double progress;
  BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8C547).withOpacity(0.025)
      ..strokeWidth = 1;

    for (int i = -20; i < 40; i++) {
      final x = (i * 40.0) + (progress * 40) % 40;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }

    final cornerPaint = Paint()
      ..color = const Color(0xFFD64045).withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(16, 16, 60, 60), cornerPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width - 76, size.height - 76, 60, 60), cornerPaint);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}

class CornerPainter extends CustomPainter {
  final bool flipX, flipY;
  final Color color;
  CornerPainter({required this.flipX, required this.flipY, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final scaleX = flipX ? -1.0 : 1.0;
    final scaleY = flipY ? -1.0 : 1.0;

    canvas.save();
    canvas.translate(flipX ? size.width : 0, flipY ? size.height : 0);
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CornerPainter old) => false;
}
