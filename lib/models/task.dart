class Task {
  final int id;
  final String title;
  bool completed;

  Task({required this.id, required this.title, this.completed = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
