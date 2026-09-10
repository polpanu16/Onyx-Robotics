import 'dart:io';
import 'package:mecha_forge/lessons.dart';

/// Run after building web. Real route entry files support direct links on Pages.
void main() {
  final root = Directory('build/web');
  final source = File('${root.path}/index.html');
  if (!source.existsSync()) throw StateError('Build the website first.');
  final routes = [
    'learn',
    'specs',
    'presentation',
    for (final lesson in lessons)
      for (var step = 1; step <= 5; step++) 'learn/${lesson.id}/$step',
  ];
  for (final route in routes) {
    final target = File('${root.path}/$route/index.html');
    target.parent.createSync(recursive: true);
    source.copySync(target.path);
  }
  source.copySync('${root.path}/404.html');
  stdout.writeln(
    'Prepared ${routes.length} clean URL entries and a not-found page.',
  );
}
