import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task_item.dart';

class TaskService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.json');
  }

  // Luu danh sach nhiem vu vao file JSON
  Future<void> saveTasks(List<TaskItem> tasks) async {
    final file = await _file;
    final data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await file.writeAsString(data);
  }

  // Doc danh sach nhiem vu da luu
  Future<List<TaskItem>> loadTasks() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(content) as List<dynamic>;
      return data
          .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
