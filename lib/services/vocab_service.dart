import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vocab_word.dart';

class VocabService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/vocabulary.json');
  }

  // Luu danh sach tu vung vao file vocabulary.json
  Future<void> saveWords(List<VocabWord> words) async {
    final file = await _file;
    final data = jsonEncode(words.map((e) => e.toJson()).toList());
    await file.writeAsString(data);
  }

  // Doc danh sach tu vung tu file
  Future<List<VocabWord>> loadWords() async {
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
          .map((item) => VocabWord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
