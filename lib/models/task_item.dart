class TaskItem {
  String title;
  String note;
  DateTime? remindAt;
  bool completed;

  TaskItem({
    required this.title,
    this.note = '',
    this.remindAt,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note,
      'remindAt': remindAt?.toIso8601String(),
      'completed': completed,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      remindAt: json['remindAt'] == null
          ? null
          : DateTime.parse(json['remindAt'] as String),
      completed: json['completed'] as bool? ?? false,
    );
  }
}
