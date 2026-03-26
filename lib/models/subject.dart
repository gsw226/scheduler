import 'dart:ui';

class Subject {
  final String id;
  final String name;
  final Color color;

  Subject({required this.id, required this.name, required this.color});

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  Subject copyWith({String? id, String? name, Color? color}) => Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
}
