import '../data/habit_model.dart';

abstract class HabitState {}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  HabitLoaded(this.habits);
}

class HabitCompleted extends HabitState {
  final List<Habit> habits;
  final int pointsEarned;
  final int streak;
  final bool isStreakBonus;

  HabitCompleted({
    required this.habits,
    required this.pointsEarned,
    required this.streak,
    this.isStreakBonus = false,
  });
}

class HabitError extends HabitState {
  final String message;
  HabitError(this.message);
}