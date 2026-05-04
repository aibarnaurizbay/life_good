import 'package:isar/isar.dart';

part 'habit_model.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  // 'daily' | 'weekly' | 'custom'
  String frequency = 'daily';

  // для custom: [1,2,3] = пн,вт,ср (1=пн, 7=вс)
  List<int> customDays = [];

  int pointsReward = 10;
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastCompletedAt;
  bool isArchived = false;
  DateTime createdAt = DateTime.now();

  @ignore
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }

  @ignore
  bool get isScheduledToday {
    if (frequency == 'daily') return true;
    if (frequency == 'weekly') {
      return DateTime.now().weekday == 1; // понедельник
    }
    if (frequency == 'custom') {
      return customDays.contains(DateTime.now().weekday);
    }
    return true;
  }
}