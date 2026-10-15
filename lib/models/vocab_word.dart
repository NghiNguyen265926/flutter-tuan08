class VocabWord {
  String word;
  String meaning;
  DateTime createdAt;

  VocabWord({
    required this.word,
    required this.meaning,
    required this.createdAt,
  });

  // Chuyen doi tu vung sang Map de luu JSON
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Tao tu vung tu du lieu doc trong file JSON
  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
