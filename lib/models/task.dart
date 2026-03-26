class Task {
  final String id;
  final String title;
  final String subjectId;
  final String date; // yyyy-MM-dd
  final bool completed;
  final bool carriedOver;
  final String? originalDate;
  final String? deadline; // yyyy-MM-dd, 마감일

  Task({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.date,
    this.completed = false,
    this.carriedOver = false,
    this.originalDate,
    this.deadline,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        subjectId: json['subjectId'],
        date: json['date'],
        completed: json['completed'] ?? false,
        carriedOver: json['carriedOver'] ?? false,
        originalDate: json['originalDate'],
        deadline: json['deadline'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'date': date,
        'completed': completed,
        'carriedOver': carriedOver,
        'originalDate': originalDate,
        'deadline': deadline,
      };

  Task copyWith({
    String? id,
    String? title,
    String? subjectId,
    String? date,
    bool? completed,
    bool? carriedOver,
    String? originalDate,
    Object? deadline = _sentinel,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        subjectId: subjectId ?? this.subjectId,
        date: date ?? this.date,
        completed: completed ?? this.completed,
        carriedOver: carriedOver ?? this.carriedOver,
        originalDate: originalDate ?? this.originalDate,
        deadline: deadline == _sentinel ? this.deadline : deadline as String?,
      );
}

const _sentinel = Object();
