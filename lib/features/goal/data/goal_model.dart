import 'package:isar/isar.dart';

part 'goal_model.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  int currentProgress = 0;
  int totalSteps = 10;
  int pointsRewardTotal = 150;
  DateTime? targetDate;
  bool isCompleted = false;
  DateTime createdAt = DateTime.now();
  DateTime? completedAt;

  @ignore
  double get progressPercent {
    if (totalSteps == 0) return 0;
    return (currentProgress / totalSteps).clamp(0.0, 1.0);
  }

  @ignore
  int get progressPercent100 => (progressPercent * 100).round();
}