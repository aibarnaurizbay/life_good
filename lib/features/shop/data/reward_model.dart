import 'package:isar/isar.dart';

part 'reward_model.g.dart';

enum RewardType { virtual, real }

@collection
class Reward {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  late int cost;

  @Enumerated(EnumType.name)
  RewardType type = RewardType.virtual;

  bool isPurchased = false;
  DateTime? purchasedAt;
  String iconEmoji = '🎁';
  DateTime createdAt = DateTime.now();
}