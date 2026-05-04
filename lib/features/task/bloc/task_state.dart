import '../data/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  TaskLoaded(this.tasks);
}

class TaskCompleted extends TaskState {
  final List<Task> tasks;
  final int pointsEarned;

  TaskCompleted({required this.tasks, required this.pointsEarned});
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}