import '../data/goal_model.dart';

abstract class GoalEvent {}

class LoadGoalsEvent extends GoalEvent {}

class AddGoalEvent extends GoalEvent {
  final Goal goal;
  AddGoalEvent(this.goal);
}

class UpdateGoalEvent extends GoalEvent {
  final Goal goal;
  UpdateGoalEvent(this.goal);
}

class IncrementGoalProgressEvent extends GoalEvent {
  final int id;
  final int steps; // сколько шагов добавить, по умолчанию 1
  IncrementGoalProgressEvent(this.id, {this.steps = 1});
}

class DeleteGoalEvent extends GoalEvent {
  final int id;
  DeleteGoalEvent(this.id);
}