import 'dart:convert';
import 'dart:io';
import 'package:mecha_forge/lessons.dart';
import 'package:mecha_forge/submission.dart';

/// Generate the actual presentation document from the same lesson data as the app.
/// Run from the project root with: dart tool/generate_presentation.dart
void main() {
  final data = <String, Object>{
    'submission': {
      'thaiName': studentNameThai,
      'englishName': studentNameEnglish,
      'studentId': studentId,
      'instructor': instructorName,
      'instructorThai': instructorNameThai,
    },
    'steps': stepTitles,
    'labels': stepLabels,
    'lessons': [
      for (final l in lessons)
        {
          'id': l.id,
          'title': l.title,
          'english': l.english,
          'keyword': l.keyword,
          'intro': l.intro,
          'principle': l.principle,
          'firstPrompt': l.firstPrompt,
          'firstResult': l.firstResult,
          'conversation': l.conversation,
          'newPrompt': l.newPrompt,
          'newResult': l.newResult,
          'reflection': l.reflection,
        },
    ],
    'images': {
      for (final entry
          in {
            'zero': 'onyx-zero-simple.png',
            'hero': 'onyx-hero.png',
            'refined': 'onyx-refined-v2.png',
            'detail': 'onyx-detail.png',
            'mermaidZero': 'mermaid-zero.png',
            'mermaidRefined': 'mermaid-refined.png',
            'exampleWatch': 'ai-example-black-watch.png',
            'exampleCar': 'ai-example-black-car.png',
            'overleafZero': 'overleaf-zero-1.png',
            'overleafFew1': 'overleaf-few-1.png',
            'overleafFew2': 'overleaf-few-2.png',
            'notebookZero': 'notebooklm-zero-1.png',
            'notebookRefined': 'notebooklm-refined-1.png',
          }.entries)
        entry.key:
            'data:image/png;base64,${base64Encode(File('assets/images/${entry.value}').readAsBytesSync())}',
    },
  };
  final template = File('tool/presentation.template.html').readAsStringSync();
  final html = template
      .replaceAll('__ONYX_DATA__', jsonEncode(data).replaceAll('</', r'<\/'))
      .replaceAll(
        '__ONYX_FONT__',
        base64Encode(File('assets/fonts/NotoSansThai.ttf').readAsBytesSync()),
      );
  File('web/presentation.html').writeAsStringSync(html);
  Directory('output/pdf').createSync(recursive: true);
  File(
    'output/pdf/submission.json',
  ).writeAsStringSync(jsonEncode(data['submission']));
  Directory('web/downloads/pdfs').createSync(recursive: true);
  stdout.writeln(
    'Generated web/presentation.html: 33 slides including 30 learning pages.',
  );
}
