import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../features/habit/data/habit_model.dart';
import '../features/task/data/task_model.dart';
import '../features/goal/data/goal_model.dart';
import '../features/shop/data/reward_model.dart';
import '../features/profile/data/user_profile_model.dart';

class IsarService {
  static late Isar instance;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    instance = await Isar.open(
      [
        HabitSchema,
        TaskSchema,
        GoalSchema,
        RewardSchema,
        UserProfileSchema,
      ],
      directory: dir.path,
    );
  }
}