import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/habit_repository.dart';
import '../../profile/data/user_repository.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final _habitRepo = HabitRepository();
  final _userRepo = UserRepository();

  HabitBloc() : super(HabitInitial()) {
    on<LoadHabitsEvent>(_onLoad);
    on<AddHabitEvent>(_onAdd);
    on<UpdateHabitEvent>(_onUpdate);
    on<CompleteHabitEvent>(_onComplete);
    on<CancelHabitEvent>(_onCancel);
    on<DeleteHabitEvent>(_onDelete);
    on<ArchiveHabitEvent>(_onArchive);
  }

  Future<void> _onLoad(
      LoadHabitsEvent event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Не удалось загрузить привычки: $e'));
    }
  }

  Future<void> _onAdd(
      AddHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await _habitRepo.save(event.habit);
      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Не удалось добавить привычку: $e'));
    }
  }

  Future<void> _onUpdate(
      UpdateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await _habitRepo.save(event.habit);
      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Не удалось обновить привычку: $e'));
    }
  }

  Future<void> _onComplete(
      CompleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final habit = await _habitRepo.getById(event.id);
      if (habit == null) return;
      if (habit.isCompletedToday) return;

      final wasYesterday = _wasCompletedYesterday(habit.lastCompletedAt);
      habit.currentStreak = wasYesterday ? habit.currentStreak + 1 : 1;
      habit.longestStreak = max(habit.longestStreak, habit.currentStreak);
      habit.lastCompletedAt = DateTime.now();

      int points = habit.pointsReward;
      final isStreakBonus = habit.currentStreak % 7 == 0;
      if (isStreakBonus) {
        points = (points * 1.5).round();
      }

      await _habitRepo.save(habit);
      await _userRepo.addPoints(points);
      await _userRepo.incrementStat('habits');

      final habits = await _habitRepo.getTodayHabits();
      emit(HabitCompleted(
        habits: habits,
        pointsEarned: points,
        streak: habit.currentStreak,
        isStreakBonus: isStreakBonus,
      ));
    } catch (e) {
      emit(HabitError('Не удалось выполнить привычку: $e'));
    }
  }

  Future<void> _onCancel(
      CancelHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final habit = await _habitRepo.getById(event.id);
      if (habit == null) return;
      if (!habit.isCompletedToday) return;

      // Сбрасываем выполнение
      habit.lastCompletedAt = null;

      // Уменьшаем streak
      if (habit.currentStreak > 0) {
        habit.currentStreak -= 1;
      }

      // Забираем баллы обратно
      await _habitRepo.save(habit);
      await _userRepo.spendPoints(habit.pointsReward);

      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Ошибка отмены: $e'));
    }
  }

  Future<void> _onDelete(
      DeleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await _habitRepo.delete(event.id);
      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Не удалось удалить привычку: $e'));
    }
  }

  Future<void> _onArchive(
      ArchiveHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await _habitRepo.archiveHabit(event.id);
      final habits = await _habitRepo.getTodayHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Не удалось архивировать привычку: $e'));
    }
  }

  bool _wasCompletedYesterday(DateTime? lastCompleted) {
    if (lastCompleted == null) return false;
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1));
    return lastCompleted.year == yesterday.year &&
        lastCompleted.month == yesterday.month &&
        lastCompleted.day == yesterday.day;
  }
}