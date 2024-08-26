import 'package:flutter/material.dart';
import 'package:html_getter/html_getter.dart';

import 'lang.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: lang['title']??'',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: lang['title']??''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  String result = '';

  @override
  void initState() {
    super.initState();
    _textEditingController.text = 'https://book.douban.com/subject/36331624/';
  }

  @override
  void dispose() {
    HttpGetter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _textEditingController,
          ),
          ElevatedButton(onPressed: () {
            HttpGetter.request(_textEditingController.text, (data) {
              if (data != null) {
                setState(() {
                  if (data.length > 400) {
                    result = data.substring(0, 400);
                  } else {
                    result = data;
                  }
                });
              } else {
                setState(() {
                  result = '加载失败';
                });
              }
            });
          }, child: const Text('加载')),
          Text(result??'', style: Theme.of(context).textTheme.bodyMedium,)
        ],
      ),
    );
  }
}
