import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/isar_service.dart';
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

  Future<void> _onLoad(LoadRewardsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final rewards = await _rewardRepo.getAll();
      emit(ShopLoaded(rewards));
    } catch (e) {
      emit(ShopError('Не удалось загрузить магазин: $e'));
    }
  }

  Future<void> _onAdd(AddRewardEvent event, Emitter<ShopState> emit) async {
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
      // Атомарная транзакция: проверка + списание + смена статуса
      await IsarService.instance.writeTxn(() async {
        final reward = await _rewardRepo.getById(event.rewardId);
        final user = await _userRepo.getProfile();

        if (reward == null) throw Exception('Награда не найдена');
        if (reward.isPurchased) throw Exception('already_owned');
        if (user.totalPoints < reward.cost) throw Exception('insufficient_funds');

        user.totalPoints -= reward.cost;
        reward.isPurchased = true;
        reward.purchasedAt = DateTime.now();

        await _rewardRepo.save(reward);
        await _userRepo.save(user);
      });

      final reward = await _rewardRepo.getById(event.rewardId);
      final rewards = await _rewardRepo.getAll();

      emit(ShopPurchaseSuccess(
        rewards: rewards,
        purchased: reward!,
        pointsSpent: reward.cost,
      ));
    } on Exception catch (e) {
      final rewards = await _rewardRepo.getAll();
      final msg = e.toString();

      if (msg.contains('insufficient_funds')) {
        emit(ShopPurchaseFailed(
          rewards: rewards,
          reason: 'Недостаточно баллов',
        ));
      } else if (msg.contains('already_owned')) {
        emit(ShopPurchaseFailed(
          rewards: rewards,
          reason: 'Награда уже куплена',
        ));
      } else {
        emit(ShopError('Ошибка покупки: $e'));
      }
    }
  }

  Future<void> _onDelete(DeleteRewardEvent event, Emitter<ShopState> emit) async {
    try {
      await _rewardRepo.delete(event.id);
      final rewards = await _rewardRepo.getAll();
      emit(ShopLoaded(rewards));
    } catch (e) {
      emit(ShopError('Не удалось удалить награду: $e'));
    }
  }
}