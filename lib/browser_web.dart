import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:flutter_web_plugins/url_strategy.dart';

void configureBrowserRoutes() => usePathUrlStrategy();

void viewLink(String path) {
  web.window.open(
    Uri.parse(web.document.baseURI).resolve(path).toString(),
    '_blank',
    'noopener,noreferrer',
  );
}

void openLink(String path) {
  final uri = Uri.parse(web.document.baseURI).resolve(path).toString();
  if (path.startsWith('downloads/')) {
    final anchor =
        web.HTMLAnchorElement()
          ..href = uri
          ..download = Uri.parse(path).pathSegments.last;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return;
  }
  web.window.open(uri, '_blank', 'noopener,noreferrer');
}

void saveText(String name, String content) {
  final blob = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final a =
      web.HTMLAnchorElement()
        ..href = url
        ..download = name;
  web.document.body?.append(a);
  a.click();
  a.remove();
  Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
}
