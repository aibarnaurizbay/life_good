import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'reward_model.dart';

class RewardRepository {
  Isar get _db => IsarService.instance;

  Future<List<Reward>> getAll() async {
    return _db.rewards.where().findAll();
  }

  Future<List<Reward>> getAvailable() async {
    return _db.rewards
        .filter()
        .isPurchasedEqualTo(false)
        .findAll();
  }

  Future<Reward?> getById(int id) async {
    return _db.rewards.get(id);
  }

  Future<int> save(Reward reward) async {
    return _db.writeTxn(() => _db.rewards.put(reward));
  }

  Future<bool> delete(int id) async {
    return _db.writeTxn(() => _db.rewards.delete(id));
  }

  /// Сид-данные при первом запуске
  Future<void> seedDefaultRewards() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    final defaults = [
      Reward()
        ..title = 'Кино вечером'
        ..description = 'Посмотреть любимый фильм без чувства вины'
        ..cost = 50
        ..iconEmoji = '🎬'
        ..type = RewardType.virtual,
      Reward()
        ..title = 'Час видеоигр'
        ..description = 'Полноценная игровая сессия'
        ..cost = 40
        ..iconEmoji = '🎮'
        ..type = RewardType.virtual,
      Reward()
        ..title = 'Вкусный десерт'
        ..description = 'Побаловать себя чем-то вкусным'
        ..cost = 30
        ..iconEmoji = '🍰'
        ..type = RewardType.real,
      Reward()
        ..title = 'Выходной день'
        ..description = 'День полного отдыха без задач'
        ..cost = 200
        ..iconEmoji = '🏖️'
        ..type = RewardType.virtual,
      Reward()
        ..title = 'Новая книга'
        ..description = 'Купить давно желанную книгу'
        ..cost = 100
        ..iconEmoji = '📚'
        ..type = RewardType.real,
      Reward()
        ..title = 'Кофе в любимом кафе'
        ..description = 'Выбраться в кафе и насладиться моментом'
        ..cost = 60
        ..iconEmoji = '☕'
        ..type = RewardType.real,
    ];

    await _db.writeTxn(() async {
      for (final r in defaults) {
        await _db.rewards.put(r);
      }
    });
  }
}