class Todo {
  String title;
  DateTime time;

  // Khoi tao mot cong viec
  Todo({required this.title, required this.time});

  // Chuyen du lieu thanh mot dong de luu vao file todo.txt
  String toFileString() {
    return '$title|${time.toIso8601String()}';
  }

  // Doc mot dong trong file va chuyen thanh doi tuong Todo
  static Todo fromString(String line) {
    final parts = line.split('|');
    if (parts.length < 2) {
      throw FormatException('Dong du lieu Todo khong hop le');
    }

    return Todo(
      title: parts[0],
      time: DateTime.parse(parts[1]),
    );
  }
}
