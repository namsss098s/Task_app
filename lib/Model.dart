
class Task {
  String id;
  final String name;
  final String priority;
  final String status;
  final String description;
  final String repeat;
  final Set<String>? repeatDays; // Days of the week for repeating tasks
  final String tag; // Tag for categorizing the task

  Task({
    required this.id,
    required this.name,
    required this.priority,
    required this.status,
    required this.description,
    required this.repeat,
    this.repeatDays,
    required this.tag,
  });

  // Convert Task to JSON for storage or Firebase integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priority': priority,
      'status': status,
      'description': description,
      'repeat': repeat,
      'repeatDays': repeatDays?.toList(),
      'tag': tag,
    };
  }

  // Factory constructor to create a Task object from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      priority: json['priority'],
      status: json['status'],
      description: json['description'],
      repeat: json['repeat'],
      repeatDays: json['repeatDays'] != null
          ? Set<String>.from(json['repeatDays'])
          : null,
      tag: json['tag'],
    );
  }
}