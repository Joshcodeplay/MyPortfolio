import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  DateTime dueDate;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  String category;

  Task({
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
    this.category = 'General',
  }) : 
    id = DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now();
}