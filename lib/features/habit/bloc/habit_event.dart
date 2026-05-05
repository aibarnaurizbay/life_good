import '../data/habit_model.dart';

abstract class HabitEvent {}

class LoadHabitsEvent extends HabitEvent {}

class AddHabitEvent extends HabitEvent {
  final Habit habit;
  AddHabitEvent(this.habit);
}

class UpdateHabitEvent extends HabitEvent {
  final Habit habit;
  UpdateHabitEvent(this.habit);
}

class CompleteHabitEvent extends HabitEvent {
  final int id;
  CompleteHabitEvent(this.id);
}

class CancelHabitEvent extends HabitEvent {
  final int id;
  CancelHabitEvent(this.id);
}

class DeleteHabitEvent extends HabitEvent {
  final int id;
  DeleteHabitEvent(this.id);
}

class ArchiveHabitEvent extends HabitEvent {
  final int id;
  ArchiveHabitEvent(this.id);
}