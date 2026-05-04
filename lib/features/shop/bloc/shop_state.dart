import '../data/reward_model.dart';

abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<Reward> rewards;
  ShopLoaded(this.rewards);
}

class ShopPurchaseSuccess extends ShopState {
  final List<Reward> rewards;
  final Reward purchased;
  final int pointsSpent;

  ShopPurchaseSuccess({
    required this.rewards,
    required this.purchased,
    required this.pointsSpent,
  });
}

class ShopPurchaseFailed extends ShopState {
  final List<Reward> rewards;
  final String reason;

  ShopPurchaseFailed({required this.rewards, required this.reason});
}

class ShopError extends ShopState {
  final String message;
  ShopError(this.message);
}