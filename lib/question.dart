class Question {
  String text;
  List<String> options;

  Question({required this.text, required this.options});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'],
      options: List<String>.from(map['options']),
    );
  }
}
