import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'user_profile_model.dart';

class UserRepository {
  Isar get _db => IsarService.instance;

  Future<UserProfile> getProfile() async {
    final profile = await _db.userProfiles.get(0);
    if (profile != null) return profile;

    // Создаём профиль при первом запуске
    final newProfile = UserProfile();
    await _db.writeTxn(() => _db.userProfiles.put(newProfile));
    return newProfile;
  }

  Future<void> save(UserProfile profile) async {
    await _db.writeTxn(() => _db.userProfiles.put(profile));
  }

  /// Начислить баллы и обновить уровень
  Future<UserProfile> addPoints(int points) async {
    final profile = await getProfile();
    profile.totalPoints += points;
    profile.totalEarnedAllTime += points;

    // Проверяем повышение уровня
    while (profile.totalEarnedAllTime >=
        _pointsRequiredForLevel(profile.level + 1)) {
      profile.level += 1;
    }

    await save(profile);
    return profile;
  }

  /// Списать баллы (покупка в магазине)
  Future<bool> spendPoints(int points) async {
    final profile = await getProfile();
    if (profile.totalPoints < points) return false;
    profile.totalPoints -= points;
    await save(profile);
    return true;
  }

  Future<void> incrementStat(String stat) async {
    final profile = await getProfile();
    switch (stat) {
      case 'habits':
        profile.habitsCompleted++;
        break;
      case 'tasks':
        profile.tasksCompleted++;
        break;
      case 'goals':
        profile.goalsCompleted++;
        break;
    }
    await save(profile);
  }

  int _pointsRequiredForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += i * 100;
    }
    return total;
  }
}