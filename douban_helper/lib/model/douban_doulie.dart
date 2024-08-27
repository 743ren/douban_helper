import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_getter/html_getter.dart';

import '../base.dart';
import 'douban_book.dart';

class Doulie {
  String firstPageUrl;
  String? name;
  String? tag;
  int counter = 0;

  Doulie(this.firstPageUrl);

  void parseHtml(String html) {
    var document = parse(html);
    name = document.querySelector('#content > h1 > span')?.text.trim();

    if (name != null) {
      try {
        switch (name) {
          case '｜':
            tag = name!.split('｜')[1].trim().split(' ')[0].trim();
          case '|':
            tag = name!.split('|')[1].trim().split(' ')[0].trim();
        }
      } catch (e) {
        print('解析标签时出错: $e');
      }
      if (exclude_tags.contains(tag)) {
        tag = null;
      }
    }
    loadBooks(document);
  }

  void loadBooks(Document document) async {
    var items = document.getElementsByClassName('doulist-item');
    for (var item in items) {
      var title = item.getElementsByClassName('title');
      if (title.isNotEmpty) {
        var tagA = title[0].getElementsByTagName('a');
        if (tagA.isNotEmpty) {
          var bookUrl = tagA[0].attributes['href'];
          var book = await loadOneBook(bookUrl!);
          if (book != null) {
            counter++;
            print('---$name $counter');
            print('《${book.title}》获取成功');
            var dirName = tag ?? name;
          }

          break;
        }
      }
    }
  }

  Future<Book?> loadOneBook(String url) async {
    var html = await HttpGetter.request(url);
    if (html?.isNotEmpty??false) {
      return Book(url)..parseHtml(html!);
    }
    return null;
  }
}