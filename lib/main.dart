import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'browser.dart';
import 'lessons.dart';
import 'learning_widgets.dart';
import 'submission.dart';
import 'tech_effects.dart';

const ink = Color(0xFF08090B);
const panel = Color(0xFF111317);
const edge = Color(0xFF292D33);
const muted = Color(0xFF959BA6);
const ice = Color(0xFFB5DCF0);
const paper = Color(0xFFECEDEA);

final visibleLessons = List<Lesson>.unmodifiable(lessons);

void main() {
  configureBrowserRoutes();
  runApp(const OnyxApp());
}

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ONYX-01 | หุ่นยนต์ต้นแบบแห่งอนาคต',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(
        primary: ice,
        surface: panel,
        onSurface: paper,
      ),
      fontFamily: 'Arial',
      fontFamilyFallback: const ['NotoSansThai'],
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 15, height: 1.8),
        bodyLarge: TextStyle(fontSize: 17, height: 1.8),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 2,
        activeTrackColor: ice,
        thumbColor: paper,
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 300),
      ),
    ),
    onGenerateRoute: (settings) {
      final segments = Uri.parse(settings.name ?? '/').pathSegments;
      Widget page = const HomePage();
      if (segments.isNotEmpty && segments.first == 'learn') {
        final index =
            segments.length > 1
                ? visibleLessons.indexWhere((l) => l.id == segments[1])
                : -1;
        if (index >= 0) {
          final step = segments.length > 2 ? int.tryParse(segments[2]) ?? 1 : 1;
          page = LessonPage(
            lesson: visibleLessons[index],
            step: step.clamp(1, 5) - 1,
          );
        } else {
          page = const LearningPage();
        }
      } else if (segments.isNotEmpty && segments.first == 'specs') {
        page = const LearningPage();
      } else if (segments.isNotEmpty && segments.first == 'presentation') {
        page = const LearningPage();
      } else if (segments.isNotEmpty) {
        page = const NotFoundPage();
      }
      return PageRouteBuilder<void>(
        settings: settings,
        pageBuilder:
            (_, animation, __) =>
                FadeTransition(opacity: animation, child: page),
        transitionDuration: const Duration(milliseconds: 200),
      );
    },
  );
}

void go(BuildContext context, String route) {
  Navigator.of(context).pushNamed(route);
}

class Shell extends StatelessWidget {
  final Widget child;
  final String active;
  const Shell({super.key, required this.child, this.active = ''});
  @override
  Widget build(BuildContext context) => Scaffold(
    endDrawer: Drawer(
      backgroundColor: ink,
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.all(24), child: Brand()),
            for (final item in [('ภาพรวม', '/'), ('รวมผลงาน', '/learn')])
              ListTile(
                title: Text(item.$1),
                trailing: const Icon(Icons.north_east, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  go(context, item.$2);
                },
              ),
            const Divider(),
            for (final l in visibleLessons)
              ListTile(
                title: Text(l.category),
                subtitle: Text(
                  l.english,
                  style: const TextStyle(fontSize: 10, color: muted),
                ),
                onTap: () {
                  Navigator.pop(context);
                  go(context, '/learn/${l.id}/1');
                },
              ),
          ],
        ),
      ),
    ),
    body: Column(
      children: [
        Container(
          height: 82,
          decoration: const BoxDecoration(
            color: ink,
            border: Border(bottom: BorderSide(color: edge)),
          ),
          child: LayoutBuilder(
            builder:
                (context, constraints) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 700 ? 22 : 48,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => go(context, '/'),
                        child: const Brand(),
                      ),
                      const Spacer(),
                      if (constraints.maxWidth > 1100) ...[
                        NavItem('หน้าแรก', '/', active == 'home'),
                        for (final lesson in visibleLessons) ...[
                          const SizedBox(width: 22),
                          NavItem(
                            lesson.category,
                            '/learn/${lesson.id}/1',
                            ModalRoute.of(context)?.settings.name?.startsWith(
                                  '/learn/${lesson.id}/',
                                ) ??
                                false,
                          ),
                        ],
                      ],
                      if (constraints.maxWidth <= 1100)
                        Builder(
                          builder:
                              (context) => IconButton(
                                tooltip: 'เปิดเมนู',
                                onPressed:
                                    () => Scaffold.of(context).openEndDrawer(),
                                icon: const Icon(Icons.menu),
                              ),
                        ),
                    ],
                  ),
                ),
          ),
        ),
        const SizedBox(height: 1, child: TechEffect(layer: TechLayer.rail)),
        Expanded(
          child: SelectionArea(
            child: SingleChildScrollView(
              key: ValueKey(ModalRoute.of(context)?.settings.name),
              child: Column(children: [child, const Footer()]),
            ),
          ),
        ),
      ],
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(border: Border.all(color: paper, width: 2)),
          child: Center(child: Container(width: 9, height: 9, color: paper)),
        ),
      ),
      const SizedBox(width: 15),
      const Text(
        'ONYX',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: 5,
        ),
      ),
      if (MediaQuery.sizeOf(context).width > 380) ...[
        const SizedBox(width: 9),
        const Text(
          'ROBOTICS',
          style: TextStyle(fontSize: 8, letterSpacing: 2, color: muted),
        ),
      ],
    ],
  );
}

class NavItem extends StatelessWidget {
  final String text, route;
  final bool selected;
  const NavItem(this.text, this.route, this.selected, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => go(context, route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? paper : muted,
          fontSize: 10,
          letterSpacing: 1.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(border: Border.all(color: edge)),
    child: Text(
      text,
      style: const TextStyle(fontSize: 9, letterSpacing: 1.6, color: muted),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 5, height: 5, color: ice),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 2.5,
            color: ice,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool primary;
  final IconData icon;
  const ActionButton(
    this.text,
    this.onTap, {
    super.key,
    this.primary = false,
    this.icon = Icons.north_east,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: NeonHover(
      child: Material(
        color: primary ? paper : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: primary ? Colors.white : Colors.white10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: primary ? paper : edge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary ? ink : paper,
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Icon(icon, size: 17, color: primary ? ink : paper),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class ContentWidth extends StatelessWidget {
  final Widget child;
  final double vertical;
  const ContentWidth({super.key, required this.child, this.vertical = 70});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1440),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 700 ? 22 : 64,
          vertical: vertical,
        ),
        child: child,
      ),
    ),
  );
}

class RobotImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;
  final Alignment alignment;
  const RobotImage({
    super.key,
    this.asset = 'onyx-hero.png',
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$asset',
    fit: fit,
    alignment: alignment,
    semanticLabel: 'ONYX-01 หุ่นยนต์ต้นแบบเกราะดำ ภาพแนวคิดสร้างด้วย AI',
    errorBuilder:
        (_, __, ___) => Container(
          color: panel,
          child: const Center(
            child: Text(
              'ONYX–01 / VISUAL OFFLINE',
              style: TextStyle(color: muted),
            ),
          ),
        ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Shell(
    active: 'home',
    child: Column(
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final mobile = c.maxWidth < 760;
            return SizedBox(
              height: mobile ? 820 : 720,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: mobile ? 0 : 28,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RobotImage(
                          alignment:
                              mobile
                                  ? const Alignment(.6, 0)
                                  : Alignment.topCenter,
                        ),
                        TechEffect(
                          layer: TechLayer.eyes,
                          alignment:
                              mobile
                                  ? const Alignment(.6, 0)
                                  : Alignment.topCenter,
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin:
                              mobile
                                  ? Alignment.bottomCenter
                                  : Alignment.centerLeft,
                          end:
                              mobile
                                  ? Alignment.topCenter
                                  : Alignment.centerRight,
                          colors:
                              mobile
                                  ? [
                                    ink,
                                    ink.withValues(alpha: .65),
                                    Colors.transparent,
                                  ]
                                  : [
                                    ink,
                                    ink.withValues(alpha: .86),
                                    ink.withValues(alpha: .08),
                                    Colors.transparent,
                                  ],
                          stops: mobile ? [0, .42, .85] : [0, .24, .57, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [ink, Colors.transparent],
                          stops: const [0, .24],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: TechEffect(layer: TechLayer.atmosphere),
                  ),
                  Positioned(
                    left: mobile ? 22 : 64,
                    top: mobile ? 34 : 58,
                    child: const Eyebrow(
                      'PROJECT 001  /  ENGINEERED TO EVOLVE',
                    ),
                  ),
                  Positioned(
                    left: mobile ? 22 : 64,
                    right: mobile ? 22 : null,
                    top: mobile ? 410 : 160,
                    child: SizedBox(
                      width: mobile ? null : 570,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEYOND\nHUMAN LIMITS.',
                            style: TextStyle(
                              fontSize: mobile ? 43 : 70,
                              height: 1.03,
                              letterSpacing: -2.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'ONYX–01',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 9,
                              color: ice,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 350,
                            child: Text(
                              'นิยามใหม่ของหุ่นยนต์แปลงร่าง\nจากจินตนาการ สู่ต้นแบบแห่งอนาคต',
                              style: TextStyle(
                                color: muted,
                                fontSize: 15,
                                height: 1.9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ActionButton(
                                'สำรวจผลงาน',
                                () => go(context, '/learn'),
                                primary: true,
                              ),
                              ActionButton(
                                'เปิดดู PDF ทุกหัวข้อ',
                                () => viewLink(
                                  'downloads/pdfs/onyx-complete.pdf',
                                ),
                                icon: Icons.open_in_new,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!mobile)
                    Positioned(
                      right: 56,
                      top: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Tag('PROTOTYPE / ONYX–01'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: ice,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CONCEPT SYSTEM ONLINE',
                                style: TextStyle(
                                  fontSize: 8,
                                  letterSpacing: 1.4,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (!mobile)
                    const Positioned(
                      right: 55,
                      bottom: 78,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '01 / BLACK EDITION',
                            style: TextStyle(fontSize: 11, letterSpacing: 2),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'AI-GENERATED CONCEPT',
                            style: TextStyle(
                              fontSize: 8,
                              color: muted,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Positioned(
                    left: 64,
                    bottom: 25,
                    child: Text(
                      'SCROLL TO DISCOVER     ↓',
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 3,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SubmissionInfo(),
        const StatsStrip(),
        ContentWidth(
          child: LayoutBuilder(
            builder:
                (context, c) => Flex(
                  direction: c.maxWidth < 700 ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: c.maxWidth < 700 ? c.maxWidth : c.maxWidth * .46,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow('ONE PROTOTYPE. FIVE PERSPECTIVES.'),
                          SizedBox(height: 24),
                          Text(
                            'หุ่นยนต์หนึ่งตัว\nเรียนรู้ได้หกด้าน',
                            style: TextStyle(
                              fontSize: 35,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (c.maxWidth < 700)
                      const SizedBox(height: 24)
                    else
                      const Spacer(),
                    SizedBox(
                      width: c.maxWidth < 700 ? c.maxWidth : c.maxWidth * .44,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ONYX–01 เป็นหุ่นยนต์ต้นแบบในจินตนาการที่ใช้เป็นหัวข้อร่วมของงานทั้ง 5 ด้าน ตั้งแต่การสร้างภาพและกราฟ ไปจนถึงการเขียนเอกสารและสไลด์ แต่ละหัวข้อแสดงให้เห็นว่าการปรับคำสั่งช่วยให้ได้ผลลัพธ์ที่ชัดเจนขึ้นอย่างไร',
                            style: TextStyle(color: muted, height: 2),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'EDUCATIONAL CONCEPT  /  NOT A COMMERCIAL PRODUCT',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.4,
                              color: ice,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: edge),
              bottom: BorderSide(color: edge),
            ),
          ),
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  'THE MAKING OF ONYX',
                  'สำรวจทุกมิติของต้นแบบ',
                  '06 MODULES / 30 LEARNING PAGES',
                ),
                const SizedBox(height: 36),
                const LessonGrid(),
              ],
            ),
          ),
        ),
        ContentWidth(
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 760;
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('DESIGNED IN DETAIL'),
                  const SizedBox(height: 24),
                  const Text(
                    'ความมืด\nที่มีรายละเอียด',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'เกราะดำหลายชั้น เส้นแสงสีเย็น และโครงสร้างกลไก\nทุกองค์ประกอบสร้างเอกลักษณ์ให้ ONYX–01',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 28),
                  ActionButton(
                    'ดูการออกแบบด้วย AI',
                    () => go(context, '/learn/visual/4'),
                  ),
                ],
              );
              return Flex(
                direction: narrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: narrow ? c.maxWidth : c.maxWidth * .52,
                    height: 420,
                    child: const RobotImage(asset: 'onyx-detail.png'),
                  ),
                  SizedBox(width: narrow ? 0 : 64, height: narrow ? 32 : 0),
                  if (narrow) text else Expanded(child: text),
                ],
              );
            },
          ),
        ),
        Container(
          color: panel,
          child: ContentWidth(
            vertical: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('FROM PROMPT TO PROTOTYPE'),
                const SizedBox(height: 18),
                const Text(
                  'ผลลัพธ์ที่ดี เริ่มจากคำถามที่ชัดเจน',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ดูคำสั่งเริ่มต้น วิธีปรับโจทย์ และสิ่งที่ได้เรียนรู้จากแต่ละหัวข้อ',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 24),
                ActionButton(
                  'เปิดแฟ้มการเรียนรู้',
                  () => go(context, '/learn'),
                  primary: true,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: edge),
        bottom: BorderSide(color: edge),
      ),
    ),
    child: ContentWidth(
      vertical: 30,
      child: LayoutBuilder(
        builder:
            (context, c) => Wrap(
              runSpacing: 26,
              children: [
                for (final stat in [
                  ('01', 'PROTOTYPE', 'หุ่นยนต์ต้นแบบหนึ่งเดียว'),
                  ('2.4', 'kWh / CONCEPT', 'พลังงานแบตเตอรี่สมมติ'),
                  ('06', 'PERSPECTIVES', 'มุมมองการเรียนรู้'),
                  ('30', 'LEARNING PAGES', 'หน้าบันทึกการทดลอง'),
                ])
                  SizedBox(
                    width: c.maxWidth / (c.maxWidth < 650 ? 2 : 4),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.$1,
                            style: const TextStyle(
                              fontSize: 40,
                              height: 1.1,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            stat.$2,
                            style: const TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.8,
                              color: ice,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.$3,
                            style: const TextStyle(fontSize: 11, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  final String eyebrow, title, detail;
  const SectionHeading(this.eyebrow, this.title, this.detail, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Eyebrow(eyebrow),
      const SizedBox(height: 16),
      Text(
        title,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        detail,
        style: const TextStyle(fontSize: 9, letterSpacing: 2, color: muted),
      ),
    ],
  );
}

class LessonGrid extends StatelessWidget {
  const LessonGrid({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final columns =
          c.maxWidth > 1000
              ? 3
              : c.maxWidth > 620
              ? 2
              : 1;
      final width = (c.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (var i = 0; i < visibleLessons.length; i++)
            SizedBox(width: width, child: LessonCard(index: i)),
        ],
      );
    },
  );
}

class LessonCard extends StatefulWidget {
  final int index;
  const LessonCard({super.key, required this.index});
  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final l = visibleLessons[widget.index];
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration:
            MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 240),
        decoration: BoxDecoration(
          color: hover ? const Color(0xFF191D23) : panel,
          border: Border.all(color: hover ? const Color(0xFF81D8FF) : edge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF81D8FF).withValues(alpha: hover ? .12 : 0),
              blurRadius: hover ? 26 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => go(context, '/learn/${l.id}/1'),
            onFocusChange: (value) => setState(() => hover = value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 190, child: ModuleVisual(index: widget.index)),
                Padding(
                  padding: const EdgeInsets.all(23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '0${widget.index + 1} / ${l.english}',
                            style: const TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.5,
                              color: ice,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.north_east, size: 17),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: Text(
                          l.intro,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: edge, height: 1),
                      const SizedBox(height: 14),
                      Text(
                        '05 PAGES  /  EXPLORE PROCESS',
                        style: const TextStyle(
                          fontSize: 9,
                          color: muted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModuleVisual extends StatelessWidget {
  final int index;
  const ModuleVisual({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return const SizedBox.expand(
        child: RobotImage(
          asset: 'onyx-detail.png',
          alignment: Alignment(0, -.4),
        ),
      );
    }
    if (index == 1) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CustomPaint(
          painter: EnergyPainter(speed: 28),
          child: SizedBox.expand(),
        ),
      );
    }
    if (index == 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FlowPreview(compact: true),
        ),
      );
    }
    if (index == 3) {
      return Center(
        child: Transform.rotate(
          angle: -.07,
          child: SizedBox(
            width: 160,
            height: 150,
            child: Image.asset(
              'assets/images/overleaf-zero-1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    if (index == 4) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: edge)),
          child: Stack(
            children: [
              const Positioned.fill(child: RobotImage()),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [ink, Colors.transparent]),
                ),
              ),
              const Positioned(
                left: 18,
                top: 18,
                child: Text(
                  'MEET\nONYX–01.',
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                bottom: 12,
                child: Text(
                  'STORYBOARD / 01',
                  style: TextStyle(fontSize: 7, letterSpacing: 2, color: ice),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: edge)),
        child: Column(
          children: [
            Container(
              height: 18,
              color: edge,
              padding: const EdgeInsets.only(left: 8),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 4, color: muted),
                  SizedBox(width: 4),
                  Icon(Icons.circle, size: 4, color: muted),
                  SizedBox(width: 4),
                  Icon(Icons.circle, size: 4, color: muted),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: RobotImage()),
                  const Positioned(
                    left: 14,
                    top: 20,
                    child: Text(
                      'BEYOND\nHUMAN LIMITS.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});
  @override
  Widget build(BuildContext context) => Shell(
    active: 'learn',
    child: ContentWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            'THE LEARNING ARCHIVE',
            'จากคำสั่งแรก สู่ผลลัพธ์ที่ชัดเจน',
            '6 DISCIPLINES × 5 STEPS / PROMPT ENGINEERING',
          ),
          const SizedBox(height: 24),
          const Text(
            'เลือกหัวข้อที่สนใจ แล้วอ่านคำสั่ง ผลลัพธ์ และบันทึกการปรับปรุงทีละขั้น แต่ละหัวข้อมี 5 หน้า พร้อมไฟล์ PDF ให้ดาวน์โหลด',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 24),
          const Notice(
            'รวมภาพ AI กราฟ Desmos ผังงาน Mermaid เอกสาร Overleaf และสไลด์ NotebookLM พร้อมผลงานจริงทั้ง Zero-shot และ Few-shot และกระบวนการสร้างเว็บไซต์',
          ),
          const SizedBox(height: 36),
          const LessonGrid(),
          const SizedBox(height: 40),
          ActionButton(
            'ดาวน์โหลดบันทึกทั้ง 30 หน้า',
            () => saveText('onyx-learning-archive.md', exportArchive()),
            icon: Icons.download,
          ),
        ],
      ),
    ),
  );
}

String exportArchive() =>
    '# ONYX-01 — Prompt learning archive\n\n${visibleLessons.map((l) => '## ${l.title}\n\nKeyword: ${l.keyword}\n\n### 1. Zero-shot\n${l.principle}\n\n${l.firstPrompt}\n\n### 2. First output\n${l.firstResult}\n\n### 3. Few-shot\n${l.conversation}\n\n${l.newPrompt}\n\n### 4. Refined output\n${l.newResult}\n\n### 5. Reflection\n${l.reflection}\n').join('\n')}';

class LessonPage extends StatelessWidget {
  final Lesson lesson;
  final int step;
  const LessonPage({super.key, required this.lesson, required this.step});
  @override
  Widget build(BuildContext context) {
    final number = visibleLessons.indexOf(lesson) + 1;
    return Shell(
      active: 'learn',
      child: ContentWidth(
        vertical: 42,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => go(context, '/learn'),
              icon: const Icon(Icons.west, size: 14),
              label: const Text(
                'กลับสู่แฟ้มการเรียนรู้',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 28),
            Eyebrow('MODULE 0$number / ${lesson.english}'),
            const SizedBox(height: 14),
            Text(
              lesson.category,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Text(lesson.intro, style: const TextStyle(color: muted)),
            const SizedBox(height: 20),
            ChapterDownloads(lesson: lesson),
            const SizedBox(height: 28),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DropdownButtonFormField<String>(
                initialValue: lesson.id,
                decoration: const InputDecoration(
                  labelText: 'ข้ามไปหัวข้ออื่น',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: [
                  for (var i = 0; i < visibleLessons.length; i++)
                    DropdownMenuItem(
                      value: visibleLessons[i].id,
                      child: Text(
                        '0${i + 1} / ${visibleLessons[i].category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null && id != lesson.id) {
                    go(context, '/learn/$id/1');
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 5; i++)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: step == i ? paper : Colors.transparent,
                      foregroundColor: step == i ? ink : muted,
                      side: const BorderSide(color: edge),
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    onPressed:
                        () => go(context, '/learn/${lesson.id}/${i + 1}'),
                    child: Text(
                      '0${i + 1}  ${stepTitles[i]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 34),
            LayoutBuilder(
              builder: (context, c) {
                final sidebar = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('RESEARCH NOTES'),
                    const SizedBox(height: 18),
                    const Text(
                      'KEYWORDS',
                      style: TextStyle(
                        color: muted,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(lesson.keyword, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 24),
                    const Text(
                      'DELIVERABLE',
                      style: TextStyle(
                        color: muted,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      lesson.sourceLabel,
                      () => openLink(lesson.source),
                      icon: Icons.download,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PAGE ${((number - 1) * 5 + step + 1).toString().padLeft(2, '0')} / ${visibleLessons.length * 5}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: ice,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'ข้อมูลหุ่นยนต์ทั้งหมดเป็นแนวคิดสมมติสำหรับการศึกษา',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                );
                final body = Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(c.maxWidth < 700 ? 20 : 34),
                  decoration: BoxDecoration(
                    color: panel,
                    border: Border.all(color: edge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '0${step + 1} / ${stepLabels[step]}',
                        style: const TextStyle(
                          color: ice,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        stepTitles[step],
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (step == 0) ...[
                        Text(
                          lesson.principle,
                          style: const TextStyle(color: muted),
                        ),
                        const SizedBox(height: 24),
                        PromptBox(lesson.firstPrompt),
                      ],
                      if (step == 1) ...[
                        Text(lesson.firstResult),
                        const SizedBox(height: 24),
                        ResultView(lesson: lesson, refined: false),
                      ],
                      if (step == 2) ...[
                        Text(
                          lesson.conversation,
                          style: const TextStyle(color: muted, height: 2),
                        ),
                        if (lesson.id == 'visual') ...[
                          const SizedBox(height: 24),
                          const VisualPromptExamples(),
                        ],
                        const SizedBox(height: 24),
                        PromptBox(lesson.newPrompt),
                      ],
                      if (step == 3) ...[
                        Text(lesson.newResult),
                        const SizedBox(height: 24),
                        ResultView(lesson: lesson, refined: true),
                      ],
                      if (step == 4) ...[
                        ComparisonTable(index: number - 1),
                        const SizedBox(height: 24),
                        Text(
                          lesson.reflection,
                          style: const TextStyle(height: 2),
                        ),
                      ],
                    ],
                  ),
                );
                if (c.maxWidth < 1050) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [body, const SizedBox(height: 28), sidebar],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: body),
                    const SizedBox(width: 36),
                    SizedBox(width: 300, child: sidebar),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (step > 0)
                  ActionButton(
                    'ก่อนหน้า',
                    () => go(context, '/learn/${lesson.id}/$step'),
                    icon: Icons.west,
                  ),
                if (step < 4)
                  ActionButton(
                    'ถัดไป: ${stepTitles[step + 1]}',
                    () => go(context, '/learn/${lesson.id}/${step + 2}'),
                    primary: true,
                    icon: Icons.east,
                  ),
                if (step == 4 && number < visibleLessons.length)
                  ActionButton(
                    'หัวข้อถัดไป',
                    () => go(context, '/learn/${visibleLessons[number].id}/1'),
                    primary: true,
                    icon: Icons.east,
                  ),
                if (step == 4 && number == visibleLessons.length)
                  ActionButton(
                    'กลับสู่แฟ้มการเรียนรู้',
                    () => go(context, '/learn'),
                    primary: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PromptBox extends StatelessWidget {
  final String text;
  const PromptBox(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: ink, border: Border.all(color: edge)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROMPT / INPUT',
              style: TextStyle(fontSize: 9, letterSpacing: 2, color: ice),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'คัดลอกคำสั่ง',
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () async {
                try {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('คัดลอกคำสั่งแล้ว')),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'คัดลอกอัตโนมัติไม่ได้ กรุณาเลือกข้อความและคัดลอกด้วยตนเอง',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SelectableText(
          text,
          style: const TextStyle(
            fontSize: 13,
            height: 1.9,
            color: Color(0xFFC7CDD4),
          ),
        ),
      ],
    ),
  );
}

class VisualPromptExamples extends StatelessWidget {
  const VisualPromptExamples({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final width =
          compact ? constraints.maxWidth : (constraints.maxWidth - 16) / 2;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final example in const [
            (
              'ตัวอย่างที่ 1 / นาฬิกาสีดำ',
              'พื้นผิวดำด้านและแสงขอบสีเงิน',
              'ai-example-black-watch.png',
            ),
            (
              'ตัวอย่างที่ 2 / รถสปอร์ตสีดำ',
              'มุมกล้องต่ำ รายละเอียดโลหะ และแสงฟ้าอ่อน',
              'ai-example-black-car.png',
            ),
          ])
            SizedBox(
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: ink,
                  border: Border.all(color: edge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.asset(
                        'assets/images/${example.$3}',
                        fit: BoxFit.cover,
                        semanticLabel: example.$1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            example.$1,
                            style: const TextStyle(
                              color: ice,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            example.$2,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 11,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class Notice extends StatelessWidget {
  final String text;
  const Notice(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      color: Color(0xFF151D23),
      border: Border(left: BorderSide(color: ice, width: 2)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFFB2C5D2),
        height: 1.9,
      ),
    ),
  );
}

class ResultView extends StatelessWidget {
  final Lesson lesson;
  final bool refined;
  const ResultView({super.key, required this.lesson, required this.refined});
  @override
  Widget build(BuildContext context) {
    switch (lesson.id) {
      case 'visual':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: refined ? 16 / 9 : 4 / 5,
              child: RobotImage(
                asset: refined ? 'onyx-refined-v2.png' : 'onyx-zero-simple.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            ActionButton(
              'เปิดภาพต้นฉบับ',
              () => openLink(
                'assets/assets/images/${refined ? 'onyx-refined-v2.png' : 'onyx-zero-simple.png'}',
              ),
            ),
          ],
        );
      case 'math':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnergyLab(refined: refined),
            const SizedBox(height: 18),
            PromptBox(refined ? lesson.newPrompt : lesson.firstPrompt),
            const SizedBox(height: 18),
            const Text(
              'สมการประกอบ',
              style: TextStyle(color: ice, fontSize: 10, letterSpacing: 1.8),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ink,
                border: Border.all(color: edge),
              ),
              child: SelectableText(
                refined
                    ? 'b=2400\np(x)=200+0.5x^2\nt(x)=b/p(x)\ny=t(x)\na=20\n(a,t(a))'
                    : 'y=12-0.15x',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFC8E8F8),
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ActionButton(
              refined
                  ? 'เปิดกราฟรอบปรับปรุงใน Desmos'
                  : 'เปิดกราฟ Zero-shot ใน Desmos',
              () => openLink(refined ? desmosRefinedUrl : desmosZeroShotUrl),
              icon: Icons.open_in_new,
            ),
          ],
        );
      case 'systems':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 720),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Image.asset(
                'assets/images/${refined ? 'mermaid-refined.png' : 'mermaid-zero.png'}',
                fit: BoxFit.contain,
                semanticLabel:
                    refined
                        ? 'ผังงาน Mermaid รอบปรับปรุงของ ONYX-01'
                        : 'ผังงาน Mermaid รอบแรกของ ONYX-01',
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              'เปิดภาพผลลัพธ์ Mermaid',
              () => viewLink(
                'downloads/${refined ? 'mermaid_ex.png' : 'mermaid_zero.png'}',
              ),
              icon: Icons.open_in_new,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'ดาวน์โหลดโค้ดต้นฉบับ',
              () => openLink(
                'downloads/onyx-system${refined ? '' : '-zero'}.mmd',
              ),
              icon: Icons.download,
            ),
          ],
        );
      case 'document':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final asset
                in refined
                    ? ['overleaf-few-1.png', 'overleaf-few-2.png']
                    : ['overleaf-zero-1.png']) ...[
              Image.asset('assets/images/$asset', fit: BoxFit.contain),
              const SizedBox(height: 18),
            ],
            ActionButton(
              refined
                  ? 'เปิด PDF รอบปรับปรุงจาก Overleaf · 2 หน้า'
                  : 'เปิด PDF Zero-shot จาก Overleaf · 1 หน้า',
              () => viewLink(
                'downloads/${refined ? 'onyx_few.pdf' : 'onyx_zero.pdf'}',
              ),
              primary: true,
              icon: Icons.picture_as_pdf,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'ดาวน์โหลด PDF จาก Overleaf',
              () => openLink(
                'downloads/${refined ? 'onyx_few.pdf' : 'onyx_zero.pdf'}',
              ),
              icon: Icons.download,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'เปิดฉบับอ่านบนเว็บ',
              () => openLink(
                'dossier.html?version=${refined ? 'refined' : 'zero'}',
              ),
              primary: true,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'ดาวน์โหลดไฟล์ .tex',
              () => openLink(
                'downloads/onyx-dossier${refined ? '' : '-zero'}.tex',
              ),
              icon: Icons.download,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'เปิดผลงาน Overleaf',
              () => viewLink(
                'downloads/${refined ? 'onyx_few.pdf' : 'onyx_zero.pdf'}',
              ),
            ),
          ],
        );
      case 'slides':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/${refined ? 'notebooklm-refined-1.png' : 'notebooklm-zero-1.png'}',
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            ActionButton(
              refined
                  ? 'เปิด PDF Few-shot · 9 หน้า'
                  : 'เปิด PDF Zero-shot · 6 หน้า',
              () => viewLink(
                refined
                    ? 'downloads/onyx_notebooklm_few.pdf'
                    : 'downloads/onyx_notebooklm_zero.pdf',
              ),
              primary: true,
              icon: Icons.picture_as_pdf,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'ดาวน์โหลด PDF ผลลัพธ์',
              () => openLink(
                refined
                    ? 'downloads/onyx_notebooklm_few.pdf'
                    : 'downloads/onyx_notebooklm_zero.pdf',
              ),
              icon: Icons.download,
            ),
          ],
        );
      case 'github':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ink,
                border: Border.all(color: edge),
              ),
              child: SelectableText(
                refined
                    ? 'ONYX-01\nหน้าแรก → เลือกหัวข้อ → อ่านผลงาน\n\n6 หัวข้อ · 30 หน้า\nภาพ AI · Desmos · Mermaid\nLaTeX · NotebookLM · GitHub\n\nเปิดภาพ กราฟ และเอกสารจากแต่ละหัวข้อ'
                    : 'ONYX-01\nหุ่นยนต์แปลงร่างเกราะดำ\n\nชื่อรุ่น · คำแนะนำ · ตารางข้อมูลพื้นฐาน\nเว็บไซต์ต้นแบบหน้าเดียว',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFC8E8F8),
                  height: 1.9,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ActionButton(
              refined ? 'เปิดเว็บไซต์รอบปรับปรุง' : 'เปิดเว็บต้นแบบรอบแรก',
              () {
                if (refined) {
                  go(context, '/');
                } else {
                  openLink('first-website.html');
                }
              },
              primary: true,
            ),
            const SizedBox(height: 12),
            ActionButton(
              'ดาวน์โหลดขั้นตอน GitHub Pages',
              () => openLink(lesson.source),
              icon: Icons.download,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

double runtimeAt(double speed) => 2400 / (200 + .5 * speed * speed);

class EnergyLab extends StatefulWidget {
  final bool refined;
  const EnergyLab({super.key, this.refined = true});
  @override
  State<EnergyLab> createState() => _EnergyLabState();
}

class _EnergyLabState extends State<EnergyLab> {
  double speed = 20;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: ink, border: Border.all(color: edge)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('ENERGY SIMULATION'),
        const SizedBox(height: 22),
        Wrap(
          spacing: 30,
          runSpacing: 12,
          children: [
            Text(
              '${speed.round()} km/h',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
            ),
            Text(
              '${(widget.refined ? runtimeAt(speed) : 12 - .15 * speed).toStringAsFixed(2)} h',
              key: const ValueKey('runtime'),
              style: const TextStyle(
                fontSize: 26,
                color: ice,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          width: double.infinity,
          child: CustomPaint(
            painter: EnergyPainter(
              speed: speed,
              refined: widget.refined,
              labels: true,
            ),
          ),
        ),
        Slider(
          value: speed,
          min: 0,
          max: 60,
          divisions: 60,
          label: '${speed.round()} km/h',
          semanticFormatterCallback: (v) => '${v.round()} กิโลเมตรต่อชั่วโมง',
          onChanged: (v) => setState(() => speed = v),
        ),
        const Text(
          'เลื่อนเพื่อปรับความเร็ว  /  0–60 km/h',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        const SizedBox(height: 8),
        Text(
          widget.refined
              ? 'E = 2,400 Wh  ·  P(v) = 200 + 0.5v² W\nt(v) = E / P(v)  ·  แบบจำลองสมมติเพื่อการศึกษา'
              : 't(v) = 12 − 0.15v  ·  แบบเส้นตรงสมมติรอบแรก',
          style: const TextStyle(fontSize: 11, color: muted),
        ),
      ],
    ),
  );
}

class EnergyPainter extends CustomPainter {
  final double speed;
  final bool refined, labels;
  const EnergyPainter({
    required this.speed,
    this.refined = true,
    this.labels = false,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      labels ? 33 : 0,
      14,
      size.width - 12,
      size.height - (labels ? 28 : 8),
    );
    final grid =
        Paint()
          ..color = edge
          ..strokeWidth = .7;
    void label(String s, Offset point) {
      final p = TextPainter(
        text: TextSpan(
          text: s,
          style: const TextStyle(color: muted, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p.paint(canvas, point);
    }

    for (var i = 0; i <= 4; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
      if (labels) label('${12 - i * 3}', Offset(7, y - 6));
    }
    for (var i = 0; i <= 3; i++) {
      final x = rect.left + rect.width * i / 3;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), grid);
      if (labels) label('${i * 20}', Offset(x - 5, rect.bottom + 9));
    }
    Offset point(double v) => Offset(
      rect.left + v / 60 * rect.width,
      rect.bottom - (refined ? runtimeAt(v) : 12 - .15 * v) / 12 * rect.height,
    );
    final line = Path()..moveTo(point(0).dx, point(0).dy);
    for (var v = 1; v <= 120; v++) {
      final p = point(v / 2);
      line.lineTo(p.dx, p.dy);
    }
    final fill =
        Path.from(line)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ice.withValues(alpha: .16), ice.withValues(alpha: 0)],
        ).createShader(rect),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = ice
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final dot = point(speed);
    canvas.drawLine(
      dot,
      Offset(dot.dx, rect.bottom),
      Paint()..color = ice.withValues(alpha: .4),
    );
    canvas.drawCircle(dot, 10, Paint()..color = ice.withValues(alpha: .12));
    canvas.drawCircle(dot, 4, Paint()..color = paper);
    if (labels) {
      label('h', const Offset(8, 0));
      label('km/h', Offset(rect.right - 27, rect.bottom + 9));
    }
  }

  @override
  bool shouldRepaint(covariant EnergyPainter old) =>
      speed != old.speed || refined != old.refined || labels != old.labels;
}

class FlowPreview extends StatelessWidget {
  final bool compact, refined;
  const FlowPreview({super.key, this.compact = false, this.refined = true});
  @override
  Widget build(BuildContext context) {
    Widget node(String s, {bool decision = false}) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 18,
        vertical: compact ? 5 : 10,
      ),
      decoration: BoxDecoration(
        color: decision ? const Color(0xFF172730) : ink,
        border: Border.all(color: decision ? const Color(0xFF698B9C) : edge),
      ),
      child: Text(
        s,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: compact ? 9 : 12,
          color: decision ? ice : paper,
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        node('SENSORS'),
        const Icon(Icons.south, size: 19, color: muted),
        node(
          refined ? 'BATTERY / OBSTACLE CHECK' : 'PROCESSOR',
          decision: refined,
        ),
        const Icon(Icons.south, size: 19, color: muted),
        if (refined)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: node('STOP / REPLAN')),
              const SizedBox(width: 14),
              Flexible(child: node('MOVE / FEEDBACK')),
            ],
          )
        else
          node('MOTION'),
        if (!compact) ...[
          const SizedBox(height: 16),
          const Text(
            'ภาพสรุปบนเว็บ • เปิด Mermaid ด้านล่างเพื่อดูเงื่อนไขและเส้นเชื่อมครบ',
            style: TextStyle(color: muted, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

const slideTitles = [
  'MEET ONYX–01.',
  'SCULPTED IN BLACK.',
  'ENERGY HAS LIMITS.',
  'SENSE. DECIDE. MOVE.',
  'BETTER PROMPTS.',
  'A CONCEPT. A BEGINNING.',
];
const slideCopy = [
  'หุ่นยนต์แปลงร่างต้นแบบสำหรับโครงงานการเรียนรู้',
  'เกราะดำซ้อนชั้น ดวงตาสีขาวอมฟ้า และภาพอ้างอิงตัวเดียว',
  'ที่ 20 km/h: P = 400 W และ t = 6 h ตามแบบจำลองสมมติ',
  'ตรวจแบตเตอรี่และสิ่งกีดขวางก่อนเคลื่อนไหว',
  'จาก zero-shot สู่ few-shot: เพิ่มตัวอย่าง เงื่อนไข และเกณฑ์ตรวจ',
  'ภาพและสเปกเป็นแนวคิด ยังไม่มีหุ่นยนต์หรือผลทดสอบจริง',
];

class SlidePreview extends StatefulWidget {
  const SlidePreview({super.key});
  @override
  State<SlidePreview> createState() => _SlidePreviewState();
}

class _SlidePreviewState extends State<SlidePreview> {
  int slide = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 1.6,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ink,
            border: Border.all(color: edge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONYX / STORYBOARD 0${slide + 1}',
                style: const TextStyle(
                  color: ice,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  slideTitles[slide],
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slideCopy[slide],
                style: const TextStyle(fontSize: 12, color: muted),
              ),
              const Spacer(),
              const Text(
                'LOCAL PREVIEW · NOT A NOTEBOOKLM OUTPUT',
                style: TextStyle(fontSize: 7, color: muted, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'สไลด์ก่อนหน้า',
            onPressed: slide > 0 ? () => setState(() => slide--) : null,
            icon: const Icon(Icons.west, size: 17),
          ),
          Text(
            '${slide + 1} / 6',
            style: const TextStyle(color: muted, fontSize: 11),
          ),
          IconButton(
            tooltip: 'สไลด์ถัดไป',
            onPressed: slide < 5 ? () => setState(() => slide++) : null,
            icon: const Icon(Icons.east, size: 17),
          ),
        ],
      ),
    ],
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => Shell(
    child: ContentWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('404 / SIGNAL LOST'),
          const SizedBox(height: 25),
          const Text('ไม่พบหน้าที่ต้องการ', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 25),
          ActionButton('กลับหน้าแรก', () => go(context, '/'), primary: true),
        ],
      ),
    ),
  );
}

class SubmissionInfo extends StatelessWidget {
  const SubmissionInfo({super.key});

  @override
  Widget build(BuildContext context) => ContentWidth(
    vertical: 30,
    child: Wrap(
      spacing: 80,
      runSpacing: 24,
      children: const [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('จัดทำโดย', style: TextStyle(color: muted, fontSize: 11)),
            SizedBox(height: 8),
            Text(studentNameThai, style: TextStyle(fontSize: 20, color: paper)),
            SizedBox(height: 6),
            Text(
              studentNameEnglish,
              style: TextStyle(fontSize: 13, color: ice),
            ),
            SizedBox(height: 6),
            Text(
              'รหัสนักศึกษา $studentId',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เสนอ', style: TextStyle(color: muted, fontSize: 11)),
            SizedBox(height: 8),
            Text(
              instructorNameThai,
              style: TextStyle(fontSize: 18, color: paper),
            ),
            SizedBox(height: 6),
            Text(instructorName, style: TextStyle(fontSize: 13, color: ice)),
            SizedBox(height: 8),
            Text(
              instructorRoleThai,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ],
    ),
  );
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: edge)),
    ),
    child: ContentWidth(
      vertical: 38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brand(),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              InkWell(
                onTap: () => go(context, '/learn'),
                child: const Text(
                  'แฟ้มการเรียนรู้',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Divider(color: edge),
          const SizedBox(height: 12),
          const Text(
            '$studentNameThai · $studentNameEnglish · $studentId',
            style: TextStyle(fontSize: 11, color: muted, height: 1.8),
          ),
          const SizedBox(height: 8),
          const Text(
            'เสนอ $instructorNameThai · $instructorRoleThai',
            style: TextStyle(fontSize: 10, color: muted, height: 1.8),
          ),
        ],
      ),
    ),
  );
}
