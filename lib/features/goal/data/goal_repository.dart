import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'goal_model.dart';

class GoalRepository {
  Isar get _db => IsarService.instance;

  Future<List<Goal>> getActive() async {
    return _db.goals
        .filter()
        .isCompletedEqualTo(false)
        .findAll();
  }

  Future<List<Goal>> getCompleted() async {
    return _db.goals
        .filter()
        .isCompletedEqualTo(true)
        .sortByCompletedAtDesc()
        .findAll();
  }

  Future<Goal?> getById(int id) async {
    return _db.goals.get(id);
  }

  Future<int> save(Goal goal) async {
    return _db.writeTxn(() => _db.goals.put(goal));
  }

  Future<bool> delete(int id) async {
    return _db.writeTxn(() => _db.goals.delete(id));
  }
}