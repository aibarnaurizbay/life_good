import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'habit_model.dart';

class HabitRepository {
  Isar get _db => IsarService.instance;

  Future<List<Habit>> getAll() async {
    return _db.habits
        .filter()
        .isArchivedEqualTo(false)
        .findAll();
  }

  Future<List<Habit>> getTodayHabits() async {
    final all = await getAll();
    return all.where((h) => h.isScheduledToday).toList();
  }

  Future<Habit?> getById(int id) async {
    return _db.habits.get(id);
  }

  Future<int> save(Habit habit) async {
    return _db.writeTxn(() => _db.habits.put(habit));
  }

  Future<bool> delete(int id) async {
    return _db.writeTxn(() => _db.habits.delete(id));
  }

  Future<void> archiveHabit(int id) async {
    final habit = await getById(id);
    if (habit == null) return;
    habit.isArchived = true;
    await save(habit);
  }
}