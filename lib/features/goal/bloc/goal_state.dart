import '../data/goal_model.dart';

abstract class GoalState {}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalLoaded extends GoalState {
  final List<Goal> goals;
  GoalLoaded(this.goals);
}

class GoalProgressUpdated extends GoalState {
  final List<Goal> goals;
  final int goalId;
  final bool isCompleted;
  final int pointsEarned;

  GoalProgressUpdated({
    required this.goals,
    required this.goalId,
    required this.isCompleted,
    required this.pointsEarned,
  });
}

class GoalError extends GoalState {
  final String message;
  GoalError(this.message);
}