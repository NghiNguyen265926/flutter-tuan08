import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class FileService {
  // Lay thu muc luu du lieu rieng cua ung dung
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  // Tao duong dan file todo.txt
  Future<File> get _file async {
    final path = await _path;
    return File('$path/todo.txt');
  }

  // Ghi danh sach cong viec vao file
  Future<void> saveTodos(List<Todo> todos) async {
    final file = await _file;
    final data = todos.map((e) => e.toFileString()).join('\n');
    await file.writeAsString(data);
  }

  // Doc file va tra ve danh sach Todo
  Future<List<Todo>> loadTodos() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      return content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => Todo.fromString(line))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
