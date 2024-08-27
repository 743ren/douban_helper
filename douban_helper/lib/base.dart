import 'model/douban_book.dart';
import 'model/douban_doulie.dart';

const exclude_tags = ['其它', '政法', '社科', '人际', '健康', '艺术', '文学', '临时'];

void parseUlr(String url) {
  if (url.contains('douban.com/doulist')) {
    Doulie(url).parseUrl();
  } else if (url.contains('book.douban.com/subject')) {
    Book(url).parseUrl();
  }
}