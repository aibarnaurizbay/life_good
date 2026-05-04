import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/goal_repository.dart';
import '../../profile/data/user_repository.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final _goalRepo = GoalRepository();
  final _userRepo = UserRepository();

  GoalBloc() : super(GoalInitial()) {
    on<LoadGoalsEvent>(_onLoad);
    on<AddGoalEvent>(_onAdd);
    on<UpdateGoalEvent>(_onUpdate);
    on<IncrementGoalProgressEvent>(_onIncrement);
    on<DeleteGoalEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadGoalsEvent event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goals = await _goalRepo.getActive();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError('Не удалось загрузить цели: $e'));
    }
  }

  Future<void> _onAdd(AddGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await _goalRepo.save(event.goal);
      final goals = await _goalRepo.getActive();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError('Не удалось добавить цель: $e'));
    }
  }

  Future<void> _onUpdate(UpdateGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await _goalRepo.save(event.goal);
      final goals = await _goalRepo.getActive();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError('Не удалось обновить цель: $e'));
    }
  }

  Future<void> _onIncrement(
      IncrementGoalProgressEvent event, Emitter<GoalState> emit) async {
    try {
      final goal = await _goalRepo.getById(event.id);
      if (goal == null || goal.isCompleted) return;

      goal.currentProgress =
          (goal.currentProgress + event.steps).clamp(0, goal.totalSteps);

      int pointsEarned = 0;
      bool justCompleted = false;

      // Частичные баллы за каждый шаг
      final pointsPerStep =
          (goal.pointsRewardTotal / goal.totalSteps).round();
      pointsEarned += pointsPerStep * event.steps;

      // Бонус при полном выполнении
      if (goal.currentProgress >= goal.totalSteps) {
        goal.isCompleted = true;
        goal.completedAt = DateTime.now();
        justCompleted = true;
        // Добавляем бонус 20% за завершение
        pointsEarned += (goal.pointsRewardTotal * 0.2).round();
      }

      await _goalRepo.save(goal);
      await _userRepo.addPoints(pointsEarned);
      if (justCompleted) await _userRepo.incrementStat('goals');

      final goals = await _goalRepo.getActive();
      emit(GoalProgressUpdated(
        goals: goals,
        goalId: goal.id,
        isCompleted: justCompleted,
        pointsEarned: pointsEarned,
      ));
    } catch (e) {
      emit(GoalError('Не удалось обновить прогресс: $e'));
    }
  }

  Future<void> _onDelete(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await _goalRepo.delete(event.id);
      final goals = await _goalRepo.getActive();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError('Не удалось удалить цель: $e'));
    }
  }
}