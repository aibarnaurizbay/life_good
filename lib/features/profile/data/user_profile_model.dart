import 'package:isar/isar.dart';

part 'user_profile_model.g.dart';

@collection
class UserProfile {
  // singleton — всегда id = 0
  Id id = 0;

  String name = 'Герой';
  int totalPoints = 0;
  int totalEarnedAllTime = 0;
  int level = 1;
  int tasksCompleted = 0;
  int habitsCompleted = 0;
  int goalsCompleted = 0;
  DateTime createdAt = DateTime.now();

  @ignore
  int get pointsForNextLevel => level * 100;

  @ignore
  double get levelProgress {
    final pts = totalEarnedAllTime - _pointsForLevel(level - 1);
    return (pts / pointsForNextLevel).clamp(0.0, 1.0);
  }

  int _pointsForLevel(int lvl) {
    if (lvl <= 0) return 0;
    int total = 0;
    for (int i = 1; i <= lvl; i++) {
      total += i * 100;
    }
    return total;
  }
}