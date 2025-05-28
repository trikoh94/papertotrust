library ocr_web_service;

import 'dart:js' as js;
import 'dart:js_util';

Future<String> recognizeTextWeb(String imageUrl, {String lang = 'jpn'}) async {
  final promise = js.context.callMethod('tesseractOcr', [imageUrl, lang]);
  final text = await promiseToFuture(promise);
  return text as String;
}
