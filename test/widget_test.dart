import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mecha_forge/main.dart';
import 'package:mecha_forge/lessons.dart';

void main() {
  test('energy model agrees with reference calculations', () {
    expect(runtimeAt(0), 12);
    expect(runtimeAt(20), 6);
    expect(runtimeAt(40), 2.4);
    expect(runtimeAt(60), 1.2);
  });

  testWidgets('changing speed updates the visible runtime', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: EnergyLab()),
      ),
    );
    expect(find.text('6.00 h'), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(40);
    await tester.pump();
    expect(find.text('2.40 h'), findsOneWidget);
  });

  testWidgets('mobile menu opens archive and a lesson', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const OnyxApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('เปิดเมนู'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('รวมผลงาน'));
    await tester.pumpAndSettle();
    expect(find.text('จากคำสั่งแรก สู่ผลลัพธ์ที่ชัดเจน'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('เปิดเมนู'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'NotebookLM'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all 30 lesson pages lay out on narrow mobile screens', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final lesson in lessons) {
      for (var step = 0; step < 5; step++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: LessonPage(lesson: lesson, step: step),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${lesson.id} step ${step + 1}',
        );
      }
    }
  });
}
