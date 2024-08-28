import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_getter/html_getter.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

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
  Future<void> parseUrl() async {
    var html = await HttpGetter.request(url);
    if (html != null && html.isNotEmpty) {
      parseHtml(html);
    }
  }

  void parseHtml(String html) {
    Document document = parse(html);
    final titleElement = document.querySelector('meta[property="og:title"]');
    if (titleElement != null) {
      title = titleElement.attributes['content']?.trim() ?? '';
    }
    final authorElement = document.querySelector('meta[property="book:author"]');
    if (authorElement != null) {
      author = authorElement.attributes['content']?.trim() ?? '';
    }
    final isbnElement = document.querySelector('meta[property="book:isbn"]');
    if (isbnElement != null) {
      isbn = isbnElement.attributes['content']?.trim() ?? '';
    }
    final imageElement = document.querySelector('meta[property="og:image"]');
    if (imageElement != null) {
      image = imageElement.attributes['content']?.trim() ?? '';
    }
    final ratingElement = document.getElementsByClassName('rating_num');
    if (ratingElement.isNotEmpty) {
      rating = ratingElement[0].text.trim();
    }
    // <span class="pl">出版年:</span> 2016-6<br/>
    // 这种格式 2016-6 没有任何标签的，html 里没有对应的方法去取
    for (var pl in document.getElementsByClassName('pl')) {
      final text = pl.text.trim();
      final outerHtml = pl.outerHtml; // <span class="pl">出版年:</span>

      if (text.contains('副标题')) {
        subTitle = _getContent(html, outerHtml);
      }
      if (text.contains('原作名')) {
        originTitle = _getContent(html, outerHtml);
      }
      if (text.contains('出版年')) {
        publishYear = _getContent(html, outerHtml).substring(0,4);
      }
      if (text.contains('页数')) {
        pages = _getContent(html, outerHtml);
        if (pages != null && !RegExp(r'\d+').hasMatch(pages!)) {
          pages = null;
        }
      }

      var desElement = document.querySelectorAll('#link-report > span.all.hidden > div > div > p');
      if (desElement.isEmpty) {
        desElement = document.querySelectorAll('#link-report > div > div > p');
      }
      if (desElement.isNotEmpty) {
        description = desElement.map((e) => e.text).toList();
      }
    }
  }

  String _getContent(String html, String outerHtml) {
    int start = html.indexOf(outerHtml);
    int end = html.indexOf('<', start + outerHtml.length);
    return html.substring(start + outerHtml.length, end).trim();
  }

  Future<void> write(IOSink sink, String? tag) async {
    sink.writeln('---');
    sink.writeln('地址: "$url"');
    if (image != null) {
      sink.writeln('封面: "$image"');
    }
    sink.writeln('书名: "$title"');
    if (subTitle != null) {
      sink.writeln('副标题: "$subTitle"');
    }
    if (originTitle != null) {
      sink.writeln('原作名: "$originTitle"');
    }
    if (author != null) {
      sink.writeln('作者: "$author"');
    }
    if (isbn != null) {
      sink.writeln('ISBN: "$isbn"');
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
    var language = await _getLanguage();
    if (language != null) {
      sink.writeln('语言: [$language]');
    }
    sink.writeln('---\n');

    if (image != null) {
      sink.writeln('![${title}|400](${image})');
      sink.writeln();
    }
    if (description != null) {
      sink.writeln('## 简介\n');
      for (var desc in description!) {
        sink.writeln(desc);
        sink.writeln();
      }
    }
  }

  Future<String?> _getLanguage() async {
    if (author == null) {
      return null;
    }

    String? language;

    if (RegExp(r'\[美\]|\[英\]').hasMatch(author!)) {
      language = '英语';
    } else if (RegExp(r'\[法\]').hasMatch(author!)) {
      language = '法语';
    } else if (RegExp(r'\[德\]').hasMatch(author!)) {
      language = '德语';
    } else if (RegExp(r'\[俄\]').hasMatch(author!)) {
      language = '俄语';
    } else if (RegExp(r'\[日\]').hasMatch(author!)) {
      language = '日语';
    } else if (RegExp(r'\[韩\]').hasMatch(author!)) {
      language = '韩语';
    } else {
      if (originTitle != null) {
        try {
          await langdetect.initLangDetect();
          final lan = langdetect.detect(originTitle!);
          language = {
              'en': '英语',
              'fr': '法语',
              'de': '德语',
              'ru': '俄语',
              'ja': '日语',
              'ko': '韩语'
          }[lan];
        } catch (e) {
          print(e);
        }
      }
    }
    return language;
  }

}
