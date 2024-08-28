library save_file;

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<String> save2Md(String dirName, String fileName, Future<void> Function(IOSink sink) sinkWrite) async {
  var dir = await getApplicationDocumentsDirectory();
  var saveFile = await File(join(dir.path, dirName, '$fileName.md'));

  bool fileExist = await saveFile.exists();
  if (fileExist) {
    await saveFile.delete();
  }
  bool dirExist = await saveFile.parent.exists();
  if (!dirExist) {
    await saveFile.parent.create(recursive: true);
  }
  var sink = saveFile.openWrite();
  await sinkWrite(sink);
  await sink.flush();
  await sink.close();
  return saveFile.path;
}