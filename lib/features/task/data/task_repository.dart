import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'task_model.dart';

class TaskRepository {
  Isar get _db => IsarService.instance;

  Future<List<Task>> getAll() async {
    return _db.tasks
        .filter()
        .isCompletedEqualTo(false)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<List<Task>> getCompleted() async {
    return _db.tasks
        .filter()
        .isCompletedEqualTo(true)
        .sortByCompletedAtDesc()
        .findAll();
  }

  Future<Task?> getById(int id) async {
    return _db.tasks.get(id);
  }

  Future<int> save(Task task) async {
    return _db.writeTxn(() => _db.tasks.put(task));
  }

  Future<bool> delete(int id) async {
    return _db.writeTxn(() => _db.tasks.delete(id));
  }
}