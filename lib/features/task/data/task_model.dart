import 'package:isar/isar.dart';

part 'task_model.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  DateTime? deadline;

  // 1=низкий, 2=средний, 3=высокий
  int priority = 1;

  bool isCompleted = false;
  DateTime? completedAt;
  int pointsReward = 20;
  DateTime createdAt = DateTime.now();

  @ignore
  bool get isOverdue {
    if (isCompleted || deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  @ignore
  String get priorityLabel {
    switch (priority) {
      case 3:
        return 'Высокий';
      case 2:
        return 'Средний';
      default:
        return 'Низкий';
    }
  }
}