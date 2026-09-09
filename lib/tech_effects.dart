import 'dart:math' as math;
import 'package:flutter/material.dart';

const _cyan = Color(0xFF81D8FF);

enum TechLayer { atmosphere, eyes, rail }

/// Decorative paint only: never blocks links, selection or accessibility.
class TechEffect extends StatefulWidget {
  final TechLayer layer;
  final Alignment alignment;
  const TechEffect({
    super.key,
    required this.layer,
    this.alignment = Alignment.center,
  });

  @override
  State<TechEffect> createState() => _TechEffectState();
}

class _TechEffectState extends State<TechEffect>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  bool foreground = true;
  bool motion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMotion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    updateMotion();
  }

  void updateMotion() {
    if (!mounted) return;
    final next =
        foreground &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (next == motion) return;
    motion = next;
    if (motion) {
      clock.repeat();
    } else {
      clock.stop();
      clock.value = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: ClipRect(
          child: CustomPaint(
            painter: _TechPainter(clock, widget.layer, widget.alignment),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
}

class _TechPainter extends CustomPainter {
  final Animation<double> clock;
  final TechLayer layer;
  final Alignment alignment;
  _TechPainter(this.clock, this.layer, this.alignment) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = clock.value;
    final pulse = .5 - .5 * math.cos(t * math.pi * 4);
    if (layer == TechLayer.eyes) {
      // Coordinates in the original 1672 × 941 hero asset. Use the same
      // cover geometry and alignment as Image.asset, including mobile crop.
      final scale = math.max(size.width / 1672, size.height / 941);
      final offset = alignment.alongOffset(
        Offset(size.width - 1672 * scale, size.height - 941 * scale),
      );
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.scale(scale);
      for (final points in [
        [
          const Offset(1230, 123),
          const Offset(1249, 138),
          const Offset(1252, 145),
          const Offset(1236, 137),
        ],
        [
          const Offset(1272, 141),
          const Offset(1292, 130),
          const Offset(1287, 142),
          const Offset(1273, 147),
        ],
      ]) {
        final path = Path()..addPolygon(points, true);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(
              0xFF10202D,
            ).withValues(alpha: (1 - pulse) * .45),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = _cyan.withValues(alpha: .12 + pulse * .65)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = _cyan.withValues(alpha: .10 + pulse * .65)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFE4F8FF).withValues(alpha: pulse * .8),
        );
      }
      canvas.restore();
      return;
    }
    if (layer == TechLayer.rail) {
      final x = (t * 1.4 - .2) * size.width;
      final rect = Rect.fromLTWH(x - 120, 0, 240, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              _cyan.withValues(alpha: .8),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
      return;
    }

    final mobile = size.width < 760;
    final center = Offset(size.width * (mobile ? .62 : .79), size.height * .43);
    final radius = mobile ? 150.0 : 240.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _cyan.withValues(alpha: .025 + pulse * .025),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Fine HUD arcs and calibrated ticks, concentrated on the robot side.
    final line =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7;
    line.color = _cyan.withValues(alpha: .10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -.4,
      1.8,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 12),
      2.7,
      1.0,
      false,
      line,
    );
    line.color = _cyan.withValues(alpha: .22);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 12),
      t * math.pi * 2,
      .24,
      false,
      line,
    );
    for (var i = 0; i < 36; i++) {
      final angle = i * math.pi / 18;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius + 21),
        center + direction * (radius + (i % 3 == 0 ? 28 : 24)),
        line,
      );
    }

    // Subtle rising particles: deterministic positions, no random flicker.
    for (var i = 0; i < (mobile ? 16 : 30); i++) {
      final x = ((i * .6180339) % 1) * size.width;
      final y = (1 - ((i * .173 + t) % 1)) * size.height;
      final shimmer = .5 + .5 * math.sin(t * math.pi * 2 + i);
      final alpha =
          (mobile || x < size.width * .43 ? .14 : .36) *
          shimmer *
          math.sin(math.pi * y / size.height);
      final paint = Paint()..color = _cyan.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 1.6 : .8, paint);
      if (i % 7 == 0) {
        canvas.drawLine(
          Offset(x - 4, y),
          Offset(x + 4, y),
          paint..strokeWidth = .5,
        );
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), paint);
      }
    }

    final scanY = size.height * t;
    final scan = Rect.fromLTWH(
      size.width * (mobile ? .15 : .47),
      scanY,
      size.width * .65,
      1,
    );
    canvas.drawRect(
      scan,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            _cyan.withValues(alpha: .18),
            Colors.transparent,
          ],
        ).createShader(scan),
    );
    // Low-contrast perspective grid below the content.
    final grid =
        Paint()
          ..color = _cyan.withValues(alpha: .065)
          ..strokeWidth = .6;
    for (var i = 0; i < 9; i++) {
      final y = size.height * (.83 + .17 * math.pow(i / 8, 1.8));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var i = -4; i <= 8; i++) {
      canvas.drawLine(
        Offset(size.width * .5 + i * 48, size.height * .83),
        Offset(size.width * .5 + i * 180, size.height),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(_TechPainter old) =>
      old.layer != layer || old.alignment != alignment || old.clock != clock;
}

/// Keyboard focus and pointer hover share the same neon treatment.
class NeonHover extends StatefulWidget {
  final Widget child;
  const NeonHover({super.key, required this.child});
  @override
  State<NeonHover> createState() => _NeonHoverState();
}

class _NeonHoverState extends State<NeonHover> {
  bool hovered = false;
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    final active = hovered || focused;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (value) => setState(() => focused = value),
        child: AnimatedContainer(
          duration:
              MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: _cyan.withValues(alpha: active ? .19 : 0),
                blurRadius: active ? 25 : 0,
                spreadRadius: active ? 1 : 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
