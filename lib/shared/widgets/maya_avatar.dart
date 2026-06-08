import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

enum MayaState { idle, listening, speaking, thinking }

class MayaAvatar extends StatefulWidget {
  const MayaAvatar({
    super.key,
    this.state = MayaState.idle,
    this.size = 80,
  });

  final MayaState state;
  final double size;

  @override
  State<MayaAvatar> createState() => _MayaAvatarState();
}

class _MayaAvatarState extends State<MayaAvatar>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _ringController;
  late AnimationController _thinkController;
  late AnimationController _waveController;

  late Animation<double> _idleScale;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _thinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _idleScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _ringScale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _ringController.dispose();
    _thinkController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRings(),
          _buildCore(),
        ],
      ),
    );
  }

  Widget _buildRings() {
    switch (widget.state) {
      case MayaState.listening:
        return AnimatedBuilder(
          animation: _ringController,
          builder: (_, __) => Container(
            width: widget.size * _ringScale.value,
            height: widget.size * _ringScale.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withOpacity(_ringOpacity.value),
                width: 2.5,
              ),
            ),
          ),
        );
      case MayaState.speaking:
        return AnimatedBuilder(
          animation: _ringController,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * _ringScale.value,
                height: widget.size * _ringScale.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blue.withOpacity(_ringOpacity.value * 0.8),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: widget.size * (_ringScale.value * 0.85),
                height: widget.size * (_ringScale.value * 0.85),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blue.withOpacity(_ringOpacity.value * 0.4),
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case MayaState.thinking:
        return AnimatedBuilder(
          animation: _thinkController,
          builder: (_, __) => Transform.rotate(
            angle: _thinkController.value * 2 * math.pi,
            child: Container(
              width: widget.size * 1.25,
              height: widget.size * 1.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandPurple.withOpacity(0.35),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  color: AppColors.brandPurple.withOpacity(0.5),
                  dashCount: 8,
                  radius: widget.size * 0.625,
                ),
              ),
            ),
          ),
        );
      case MayaState.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCore() {
    final isIdle = widget.state == MayaState.idle;
    return AnimatedBuilder(
      animation: isIdle ? _idleController : _waveController,
      builder: (_, __) {
        final scale = isIdle ? _idleScale.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradientForState(),
              boxShadow: [
                BoxShadow(
                  color: _glowColorForState().withOpacity(
                    widget.state == MayaState.speaking ? 0.45 : 0.25,
                  ),
                  blurRadius: widget.state == MayaState.speaking ? 28 : 16,
                  spreadRadius: widget.state == MayaState.speaking ? 4 : 0,
                ),
              ],
            ),
            child: Center(
              child: _buildInnerIcon(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInnerIcon() {
    switch (widget.state) {
      case MayaState.listening:
        return Icon(
          Icons.mic_rounded,
          color: Colors.white,
          size: widget.size * 0.42,
        );
      case MayaState.speaking:
        return AnimatedBuilder(
          animation: _waveController,
          builder: (_, __) => CustomPaint(
            size: Size(widget.size * 0.55, widget.size * 0.35),
            painter: _WaveformPainter(
              progress: _waveController.value,
              color: Colors.white,
            ),
          ),
        );
      case MayaState.thinking:
        return Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white.withOpacity(0.9),
          size: widget.size * 0.38,
        );
      case MayaState.idle:
        return Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white.withOpacity(0.85),
          size: widget.size * 0.38,
        );
    }
  }

  LinearGradient _gradientForState() {
    switch (widget.state) {
      case MayaState.listening:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MayaState.speaking:
        return const LinearGradient(
          colors: [AppColors.blue, Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MayaState.thinking:
        return const LinearGradient(
          colors: [AppColors.brandPurple, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MayaState.idle:
        return const LinearGradient(
          colors: [AppColors.blue, AppColors.brandPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _glowColorForState() {
    switch (widget.state) {
      case MayaState.listening:
        return const Color(0xFFEF4444);
      case MayaState.speaking:
        return AppColors.blue;
      case MayaState.thinking:
        return AppColors.brandPurple;
      case MayaState.idle:
        return AppColors.blue;
    }
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const barCount = 5;
    final barWidth = size.width / (barCount * 2 - 1);
    final heights = [0.4, 0.7, 1.0, 0.7, 0.4];

    for (int i = 0; i < barCount; i++) {
      final phaseOffset = i / barCount;
      final animatedHeight = heights[i] *
          (0.5 + 0.5 * math.sin((progress + phaseOffset) * 2 * math.pi));
      final barH = size.height * animatedHeight.clamp(0.2, 1.0);
      final x = i * barWidth * 2 + barWidth / 2;
      final top = (size.height - barH) / 2;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + barH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.dashCount,
    required this.radius,
  });

  final Color color;
  final int dashCount;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final step = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * step;
        final sweepAngle = step * 0.6;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}
