import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_getter/html_getter.dart';

import '../base.dart';
import 'douban_book.dart';
import 'package:save_file/save_file.dart';

class Doulie {
  String firstPageUrl;
  String? name;
  String? tag;
  int counter = 0;

  Doulie(this.firstPageUrl);

  Future<void> parseUrl() async {
    var html = await HttpGetter.request(firstPageUrl);
    if (html != null) {
      parseHtml(html);
    }
  }

  void parseHtml(String html) {
    var document = parse(html);
    name = document.querySelector('#content > h1 > span')?.text.trim();

    // 获取书单的名字
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
          var book = await Book(bookUrl!).parseUrl();
          if (book != null) {
            counter++;
            print('---$name $counter');
            print('《${book.title}》获取成功');
            var dirName = tag ?? name;
            if (dirName != null && book.title != null) {
              await save2Md(dirName, book.title!, (sink) async {
                book.write(sink, tag);
              });
              print('《${book.title}》写入文件成功');
            }
          }
        }
      }
    }

    _loadNextPageBooks(document);
  }

  /// 获取豆列下一页的 url
  String? _getNextPageUrl(Document document) {
    String? nextPageUrl;
    var paginator = document.getElementsByClassName('paginator');
    if (paginator.isNotEmpty) {
      var next = paginator[0].getElementsByClassName('next');
      if (next.isNotEmpty) {
        var tagA = next[0].getElementsByTagName('a');
        if (tagA.isNotEmpty) {
          nextPageUrl = tagA[0].attributes['href']!;
        }
      }
    }
    return nextPageUrl;
  }

  /// 递归加载下一页的书籍
  _loadNextPageBooks(Document document) async {
    var nextPageUrl = _getNextPageUrl(document);
    if (nextPageUrl != null) {
      var htmlNext = await HttpGetter.request(nextPageUrl);
      if (htmlNext != null) {
        var documentNext = parse(htmlNext);
        loadBooks(documentNext);
      }
    }
  }
}