import 'dart:io';

import 'package:html_getter/html_getter.dart';

class Book {
  String url;
  String? title;
  String? author;
  String? isbn;
  String? image;
  String? rating;
  String? subTitle;
  String? originTitle;
  String? publishYear;
  String? pages;
  List<String>? description;

  Book(this.url);

  /// 解析一本书
  Future<Book?> parseUrl() async {
    var html = await HttpGetter.request(url);
    if (html != null) {
      return parseHtml(html);
    }
    return null;
  }

  Book? parseHtml(String html) {
    // TODO
    return null;
  }

  void write(IOSink sink, String? tag) {
    sink.writeln('---');
    sink.writeln('地址: $url');
    if (image != null) {
      sink.writeln('封面: $image');
    }
    sink.writeln('书名: $title');
    if (subTitle != null) {
      sink.writeln('副标题: $subTitle');
    }
    if (originTitle != null) {
      sink.writeln('原作名: $originTitle');
    }
    if (author != null) {
      sink.writeln('作者: $author');
    }
    if (isbn != null) {
      sink.writeln('ISBN: $isbn');
    }
    if (rating != null) {
      sink.writeln('评分: $rating');
    }
    if (pages != null) {
      sink.writeln('页数: $pages');
    }
    if (publishYear != null) {
      sink.writeln('出版年: $publishYear');
    }
    if (tag != null) {
      sink.writeln('tags: [$tag]');
    } else {
      sink.writeln('tags: ');
    }
    // TODO
  }


}
