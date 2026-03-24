import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveFilePermanently(File file) async {
  final dir = await getApplicationDocumentsDirectory();
  final target = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
  final saved = await file.copy(target.path);
  return saved.path;
}
