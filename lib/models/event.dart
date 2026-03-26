class Event {
  final String id;
  final String title;
  final String date; // yyyy-MM-dd
  final String? time; // HH:mm (선택)
  final String? note;
  final bool completed;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.note,
    this.completed = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'],
        date: json['date'],
        time: json['time'],
        note: json['note'],
        completed: json['completed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'note': note,
        'completed': completed,
      };

  Event copyWith({
    String? id,
    String? title,
    String? date,
    Object? time = _sentinel,
    Object? note = _sentinel,
    bool? completed,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        time: time == _sentinel ? this.time : time as String?,
        note: note == _sentinel ? this.note : note as String?,
        completed: completed ?? this.completed,
      );
}

const _sentinel = Object();
