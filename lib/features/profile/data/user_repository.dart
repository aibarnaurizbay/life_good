import 'package:isar/isar.dart';
import '../../../shared/isar_service.dart';
import 'user_profile_model.dart';

class UserRepository {
  Isar get _db => IsarService.instance;

  Future<UserProfile> getProfile() async {
    final profile = await _db.userProfiles.get(0);
    if (profile != null) return profile;
    final newProfile = UserProfile();
    await _db.writeTxn(() => _db.userProfiles.put(newProfile));
    return newProfile;
  }

  Future<void> save(UserProfile profile) async {
    await _db.writeTxn(() => _db.userProfiles.put(profile));
  }

  Future<UserProfile> addPoints(int points) async {
    return await _db.writeTxn(() async {
      final profile = await _db.userProfiles.get(0) ?? UserProfile();
      profile.totalPoints += points;
      profile.totalEarnedAllTime += points;

      // Проверяем повышение уровня
      while (profile.totalEarnedAllTime >=
          _pointsRequiredForLevel(profile.level + 1)) {
        profile.level += 1;
      }

      await _db.userProfiles.put(profile);
      return profile;
    });
  }

  Future<bool> spendPoints(int points) async {
    return await _db.writeTxn(() async {
      final profile = await _db.userProfiles.get(0) ?? UserProfile();

      // Проверяем хватает ли баллов
      if (profile.totalPoints < points) return false;

      profile.totalPoints -= points;
      await _db.userProfiles.put(profile);
      return true;
    });
  }

  Future<void> incrementStat(String stat) async {
    await _db.writeTxn(() async {
      final profile = await _db.userProfiles.get(0) ?? UserProfile();
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
      await _db.userProfiles.put(profile);
    });
  }

  int _pointsRequiredForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += i * 100;
    }
    return total;
  }
}