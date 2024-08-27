import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'model/douban_book.dart';
import 'model/douban_doulie.dart';

/// 解析 html
void htmlParse(String url, String html) {
  if (url.contains('douban.com/doulist')) {
    Doulie(url).parseHtml(html);
  } else if (url.contains('book.douban.com/subject')) {
    Book(url).parseHtml(html);
  }
}