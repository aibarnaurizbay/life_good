import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/reward_repository.dart';
import '../../profile/data/user_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final _rewardRepo = RewardRepository();
  final _userRepo = UserRepository();

  ShopBloc() : super(ShopInitial()) {
    on<LoadRewardsEvent>(_onLoad);
    on<AddRewardEvent>(_onAdd);
    on<PurchaseRewardEvent>(_onPurchase);
    on<DeleteRewardEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadRewardsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final rewards = await _rewardRepo.getAll();
      emit(ShopLoaded(rewards));
    } catch (e) {
      emit(ShopError('Не удалось загрузить магазин: $e'));
    }
  }

  Future<void> _onAdd(
      AddRewardEvent event, Emitter<ShopState> emit) async {
    try {
      await _rewardRepo.save(event.reward);
      final rewards = await _rewardRepo.getAll();
      emit(ShopLoaded(rewards));
    } catch (e) {
      emit(ShopError('Не удалось добавить награду: $e'));
    }
  }

  Future<void> _onPurchase(
      PurchaseRewardEvent event, Emitter<ShopState> emit) async {
    try {
      // 1. Получаем награду
      final reward = await _rewardRepo.getById(event.rewardId);
      if (reward == null) {
        final rewards = await _rewardRepo.getAll();
        emit(ShopPurchaseFailed(
            rewards: rewards, reason: 'Награда не найдена'));
        return;
      }

      // 2. Проверяем — заблокирована ли (куплена менее 3 сек назад)
      if (reward.isPurchased && reward.purchasedAt != null) {
        final diff = DateTime.now().difference(reward.purchasedAt!);
        if (diff.inSeconds < 3) {
          final rewards = await _rewardRepo.getAll();
          emit(ShopPurchaseFailed(
              rewards: rewards,
              reason:
                  'Подождите ${3 - diff.inSeconds} сек...'));
          return;
        }
      }

      // 3. Пытаемся списать баллы
      final success = await _userRepo.spendPoints(reward.cost);
      if (!success) {
        final rewards = await _rewardRepo.getAll();
        emit(ShopPurchaseFailed(
            rewards: rewards, reason: 'Недостаточно баллов'));
        return;
      }

      // 4. Отмечаем как купленную
      reward.isPurchased = true;
      reward.purchasedAt = DateTime.now();
      await _rewardRepo.save(reward);

      final rewards = await _rewardRepo.getAll();
      emit(ShopPurchaseSuccess(
        rewards: rewards,
        purchased: reward,
        pointsSpent: reward.cost,
      ));

      // 5. Через 3 секунды сбрасываем статус — можно купить снова
      await Future.delayed(const Duration(seconds: 3));

      if (isClosed) return;

      final rewardAfter = await _rewardRepo.getById(event.rewardId);
      if (rewardAfter == null) return;

      rewardAfter.isPurchased = false;
      rewardAfter.purchasedAt = null;
      await _rewardRepo.save(rewardAfter);

      final updatedRewards = await _rewardRepo.getAll();
      emit(ShopLoaded(updatedRewards));
    } catch (e) {
      final rewards = await _rewardRepo.getAll();
      emit(ShopPurchaseFailed(
          rewards: rewards, reason: 'Ошибка покупки: $e'));
    }
  }

  Future<void> _onDelete(
      DeleteRewardEvent event, Emitter<ShopState> emit) async {
    try {
      await _rewardRepo.delete(event.id);
      final rewards = await _rewardRepo.getAll();
      emit(ShopLoaded(rewards));
    } catch (e) {
      emit(ShopError('Не удалось удалить награду: $e'));
    }
  }
}