import '../data/reward_model.dart';

abstract class ShopEvent {}

class LoadRewardsEvent extends ShopEvent {}

class AddRewardEvent extends ShopEvent {
  final Reward reward;
  AddRewardEvent(this.reward);
}

class PurchaseRewardEvent extends ShopEvent {
  final int rewardId;
  PurchaseRewardEvent(this.rewardId);
}

class DeleteRewardEvent extends ShopEvent {
  final int id;
  DeleteRewardEvent(this.id);
}